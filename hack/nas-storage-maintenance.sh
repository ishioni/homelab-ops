#!/usr/bin/env bash
set -euo pipefail

readonly DEFAULT_STORAGE_CLASSES=("dcsi-iscsi" "dcsi-nfs" "nfs")
readonly DEFAULT_OPERATORS=(
  "monitor/kube-prometheus-stack-operator"
)
readonly DEFAULT_STATE_NAMESPACE="kube-system"
readonly DEFAULT_STATE_CONFIGMAP="nas-storage-maintenance-state"
readonly WAIT_TIMEOUT_SECONDS="${WAIT_TIMEOUT_SECONDS:-300}"
readonly WAIT_INTERVAL_SECONDS="${WAIT_INTERVAL_SECONDS:-5}"

MODE=""
KUBECTL_BIN="${KUBECTL:-kubectl}"
STATE_NAMESPACE="${DEFAULT_STATE_NAMESPACE}"
STATE_CONFIGMAP="${DEFAULT_STATE_CONFIGMAP}"
STATE_NAMESPACE_OVERRIDE=""
STATE_CONFIGMAP_OVERRIDE=""
NO_WAIT="false"
DRY_RUN="false"
STORAGE_CLASSES=()
OPERATORS=()

log() {
  printf '[%s] %s\n' "$(date +'%Y-%m-%dT%H:%M:%S%z')" "$*" >&2
}

usage() {
  cat <<'EOF'
Usage:
  nas-storage-maintenance.sh plan [options]
  nas-storage-maintenance.sh down [options]
  nas-storage-maintenance.sh up [options]

Modes:
  plan   Discover workloads that use the target NAS-backed PVCs and print a plan.
  down   Save current replica counts and scale down workloads in phases:
         operators -> deployments -> statefulsets.
  up     Restore workloads from saved state in reverse:
         statefulsets -> deployments -> operators.

Options:
  --storageclass <name>      Target a storage class (repeatable).
                             Defaults: dcsi-iscsi, dcsi-nfs, nfs.
  --operator <namespace/name>
                             Deployment to scale before statefulsets (repeatable).
                             Default: monitor/kube-prometheus-stack-operator.
  --state-namespace <name>   Namespace for the state ConfigMap.
                             Default: kube-system.
  --state-configmap <name>   Name of the state ConfigMap.
                             Default: nas-storage-maintenance-state.
  --dry-run                  Print what would happen without applying changes.
  --no-wait                  Do not wait for workloads to finish scaling.
  -h, --help                 Show this help.

Examples:
  nas-storage-maintenance.sh plan
  nas-storage-maintenance.sh down
  nas-storage-maintenance.sh up
  nas-storage-maintenance.sh down --operator monitor/kube-prometheus-stack-operator
EOF
}

require_bin() {
  local bin
  for bin in "$@"; do
    if ! command -v "$bin" >/dev/null 2>&1; then
      log "Missing required binary: $bin"
      exit 1
    fi
  done
}

json_array_or_empty() {
  if [[ $# -eq 0 ]]; then
    printf '[]\n'
    return
  fi

  printf '%s\n' "$@" | jq -R . | jq -s .
}

parse_args() {
  if [[ $# -lt 1 ]]; then
    usage
    exit 1
  fi

  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
    exit 0
  fi

  MODE="$1"
  shift

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --storageclass)
        STORAGE_CLASSES+=("$2")
        shift 2
        ;;
      --operator)
        OPERATORS+=("$2")
        shift 2
        ;;
      --state-namespace)
        STATE_NAMESPACE_OVERRIDE="$2"
        shift 2
        ;;
      --state-configmap)
        STATE_CONFIGMAP_OVERRIDE="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN="true"
        shift
        ;;
      --no-wait)
        NO_WAIT="true"
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        log "Unknown argument: $1"
        usage
        exit 1
        ;;
    esac
  done

  if [[ ${#STORAGE_CLASSES[@]} -eq 0 ]]; then
    STORAGE_CLASSES=("${DEFAULT_STORAGE_CLASSES[@]}")
  fi

  if [[ ${#OPERATORS[@]} -eq 0 ]]; then
    OPERATORS=("${DEFAULT_OPERATORS[@]}")
  fi

  if [[ -n "$STATE_NAMESPACE_OVERRIDE" ]]; then
    STATE_NAMESPACE="$STATE_NAMESPACE_OVERRIDE"
  fi

  if [[ -n "$STATE_CONFIGMAP_OVERRIDE" ]]; then
    STATE_CONFIGMAP="$STATE_CONFIGMAP_OVERRIDE"
  fi

  case "$MODE" in
    plan|down|up) ;;
    *)
      log "Unknown mode: $MODE"
      usage
      exit 1
      ;;
  esac
}

kc() {
  "$KUBECTL_BIN" "$@"
}

storage_classes_json() {
  json_array_or_empty "${STORAGE_CLASSES[@]}"
}

operators_json() {
  local valid=()
  local entry

  for entry in "${OPERATORS[@]}"; do
    if [[ "$entry" == */* ]]; then
      valid+=("$entry")
    else
      log "Ignoring invalid operator reference '$entry' (expected namespace/name)"
    fi
  done

  json_array_or_empty "${valid[@]}"
}

fetch_discovery_json() {
  local sc_json
  sc_json="$(storage_classes_json)"

  kc get pods,pvc,rs,deploy,sts -A -o json | jq --argjson storageClasses "$sc_json" '
    . as $root
    | [
        $root.items[]
        | select(.kind == "Deployment")
        | {key: (.metadata.namespace + "/" + .metadata.name), value: (.spec.replicas // 1)}
      ] | from_entries as $deployReplicas
    | [
        $root.items[]
        | select(.kind == "StatefulSet")
        | {key: (.metadata.namespace + "/" + .metadata.name), value: (.spec.replicas // 1)}
      ] | from_entries as $stsReplicas
    | [
        $root.items[]
        | select(.kind == "ReplicaSet")
        | {key: (.metadata.namespace + "/" + .metadata.name), value: (((.metadata.ownerReferences // []) | map(select(.kind == "Deployment") | .name) | first) // null)}
      ] | from_entries as $rsToDeploy
    | [
        $root.items[]
        | select(.kind == "PersistentVolumeClaim")
        | select((.spec.storageClassName // "") as $sc | $storageClasses | index($sc))
        | {
            namespace: .metadata.namespace,
            pvc: .metadata.name,
            storageClassName: .spec.storageClassName,
            volumeName: (.spec.volumeName // null),
            accessModes: (.status.accessModes // [])
          }
      ] as $targetPvcList
    | ($targetPvcList | map({key: (.namespace + "/" + .pvc), value: .}) | from_entries) as $targetPvcs
    | [
        $root.items[]
        | select(.kind == "Pod")
        | . as $pod
        | [
            (.spec.volumes // [])[]?
            | select(has("persistentVolumeClaim"))
            | .persistentVolumeClaim.claimName as $claim
            | ($targetPvcs[$pod.metadata.namespace + "/" + $claim] // empty)
          ] as $matchedPvcs
        | select(($matchedPvcs | length) > 0)
        | {
            namespace: .metadata.namespace,
            pod: .metadata.name,
            pvcs: ($matchedPvcs | map({namespace, pvc, storageClassName})),
            ownerKind: (((.metadata.ownerReferences // [])[0]?.kind) // "Pod"),
            ownerName: (((.metadata.ownerReferences // [])[0]?.name) // .metadata.name)
          }
      ] as $podsUsingTargetStorage
    | {
        storageClasses: $storageClasses,
        pvcCount: ($targetPvcList | length),
        podCount: ($podsUsingTargetStorage | length),
        pvcs: ($targetPvcList | sort_by(.namespace, .pvc)),
        pods: ($podsUsingTargetStorage | sort_by(.namespace, .pod)),
        deployments: (
          $podsUsingTargetStorage
          | map(
              if .ownerKind == "Deployment" then
                {namespace: .namespace, name: .ownerName, replicas: ($deployReplicas[.namespace + "/" + .ownerName] // 1)}
              elif .ownerKind == "ReplicaSet" and ($rsToDeploy[.namespace + "/" + .ownerName] != null) then
                {namespace: .namespace, name: $rsToDeploy[.namespace + "/" + .ownerName], replicas: ($deployReplicas[.namespace + "/" + $rsToDeploy[.namespace + "/" + .ownerName]] // 1)}
              else empty end
            )
          | unique_by(.namespace, .name)
          | sort_by(.namespace, .name)
        ),
        statefulsets: (
          $podsUsingTargetStorage
          | map(select(.ownerKind == "StatefulSet") | {namespace: .namespace, name: .ownerName, replicas: ($stsReplicas[.namespace + "/" + .ownerName] // 1)})
          | unique_by(.namespace, .name)
          | sort_by(.namespace, .name)
        ),
        unsupportedOwners: (
          $podsUsingTargetStorage
          | map(select(.ownerKind != "Deployment" and .ownerKind != "ReplicaSet" and .ownerKind != "StatefulSet") | {namespace: .namespace, kind: .ownerKind, name: .ownerName})
          | unique_by(.namespace, .kind, .name)
          | sort_by(.namespace, .kind, .name)
        )
      }
  '
}

fetch_operator_state_json() {
  local operators_json_value
  operators_json_value="$(operators_json)"

  if [[ "$operators_json_value" == "[]" ]]; then
    printf '[]\n'
    return
  fi

  kc get deploy -A -o json | jq --argjson operators "$operators_json_value" '
    [
      $operators[] as $operator
      | ($operator | split("/")) as $parts
      | .items[]
      | select(.metadata.namespace == $parts[0] and .metadata.name == $parts[1])
      | {
          namespace: .metadata.namespace,
          name: .metadata.name,
          replicas: (.spec.replicas // 1)
        }
    ]
    | unique_by(.namespace, .name)
    | sort_by(.namespace, .name)
  '
}

print_plan() {
  local discovery_json operator_json
  discovery_json="$1"
  operator_json="$2"

  jq -r --arg stateNamespace "$STATE_NAMESPACE" --arg stateConfigMap "$STATE_CONFIGMAP" --argjson operators "$operator_json" '
    def fmt_items(items):
      if (items | length) == 0 then
        ["  (none)"]
      else
        items | map("  - " + .namespace + "/" + .name + " (replicas=" + ((.replicas // 0) | tostring) + ")")
      end;

    [
      "Target storage classes: " + (.storageClasses | join(", ")),
      "State storage: ConfigMap " + $stateNamespace + "/" + $stateConfigMap,
      "",
      "PVCs:",
      (if (.pvcs | length) == 0 then "  (none)" else (.pvcs | map("  - " + .namespace + "/" + .pvc + " [" + .storageClassName + "]") | join("\n")) end),
      "",
      "Operator deployments to scale first:",
      (if ($operators | length) == 0 then "  (none)" else ($operators | map("  - " + .namespace + "/" + .name + " (replicas=" + (.replicas | tostring) + ")") | join("\n")) end),
      "",
      "Deployments to scale:",
      (fmt_items(.deployments) | join("\n")),
      "",
      "StatefulSets to scale:",
      (fmt_items(.statefulsets) | join("\n")),
      "",
      "Unsupported PVC-using owners (manual handling may be required):",
      (if (.unsupportedOwners | length) == 0 then "  (none)" else (.unsupportedOwners | map("  - " + .namespace + "/" + .name + " [" + .kind + "]") | join("\n")) end)
    ] | join("\n")
  ' <<<"$discovery_json"
}

wait_for_scaled_replicas() {
  local kind="$1" namespace="$2" name="$3" expected="$4"

  if [[ "$NO_WAIT" == "true" ]]; then
    return
  fi

  local started now observed ready
  started="$(date +%s)"

  while true; do
    observed="$(kc -n "$namespace" get "$kind" "$name" -o json | jq -r '.spec.replicas // 0')"
    ready="$(kc -n "$namespace" get "$kind" "$name" -o json | jq -r '.status.readyReplicas // 0')"

    if [[ "$observed" == "$expected" ]]; then
      if [[ "$expected" == "0" ]]; then
        if [[ "$ready" == "0" ]]; then
          return
        fi
      else
        if [[ "$ready" == "$expected" ]]; then
          return
        fi
      fi
    fi

    now="$(date +%s)"
    if (( now - started >= WAIT_TIMEOUT_SECONDS )); then
      log "Timed out waiting for $kind/$namespace/$name to reach replicas=$expected (spec=$observed ready=$ready)"
      exit 1
    fi

    sleep "$WAIT_INTERVAL_SECONDS"
  done
}

scale_workload() {
  local kind="$1" namespace="$2" name="$3" replicas="$4"

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] scale $kind $namespace/$name -> $replicas"
    return
  fi

  log "Scaling $kind $namespace/$name -> $replicas"
  kc -n "$namespace" scale "$kind" "$name" --replicas "$replicas"
}

scale_phase() {
  local kind="$1"
  local target_replicas="$2"
  local items_json="$3"

  local -a items=()
  local item namespace name replicas

  while IFS= read -r item; do
    items+=("$item")
  done < <(jq -c '.[]?' <<<"$items_json")

  if [[ ${#items[@]} -eq 0 ]]; then
    return
  fi

  log "Scaling ${#items[@]} $kind workload(s) in parallel"

  for item in "${items[@]}"; do
    namespace="$(jq -r '.namespace' <<<"$item")"
    name="$(jq -r '.name' <<<"$item")"
    replicas="$target_replicas"

    if [[ "$target_replicas" == "__from_item__" ]]; then
      replicas="$(jq -r '.replicas' <<<"$item")"
    fi

    scale_workload "$kind" "$namespace" "$name" "$replicas"
  done

  if [[ "$NO_WAIT" == "true" || "$DRY_RUN" == "true" ]]; then
    return
  fi

  log "Waiting for ${#items[@]} $kind workload(s)"

  for item in "${items[@]}"; do
    namespace="$(jq -r '.namespace' <<<"$item")"
    name="$(jq -r '.name' <<<"$item")"
    replicas="$target_replicas"

    if [[ "$target_replicas" == "__from_item__" ]]; then
      replicas="$(jq -r '.replicas' <<<"$item")"
    fi

    wait_for_scaled_replicas "$kind" "$namespace" "$name" "$replicas"
  done
}

save_state_configmap() {
  local state_json="$1"

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] would store state in ConfigMap $STATE_NAMESPACE/$STATE_CONFIGMAP"
    return
  fi

  local tmp_file
  tmp_file="$(mktemp)"
  printf '%s\n' "$state_json" > "$tmp_file"

  if ! kc get namespace "$STATE_NAMESPACE" >/dev/null 2>&1; then
    kc create namespace "$STATE_NAMESPACE" >/dev/null
  fi

  kc -n "$STATE_NAMESPACE" create configmap "$STATE_CONFIGMAP" \
    --from-file=state.json="$tmp_file" \
    --dry-run=client -o yaml | kc apply -f - >/dev/null

  rm -f "$tmp_file"
}

load_state_configmap() {
  kc -n "$STATE_NAMESPACE" get configmap "$STATE_CONFIGMAP" -o json | jq -r '.data["state.json"]'
}

build_state_json() {
  local discovery_json="$1"
  local operator_json="$2"
  local storage_json
  storage_json="$(storage_classes_json)"

  jq -n \
    --arg generatedAt "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --arg mode "$MODE" \
    --arg stateNamespace "$STATE_NAMESPACE" \
    --arg stateConfigMap "$STATE_CONFIGMAP" \
    --argjson storageClasses "$storage_json" \
    --argjson operators "$operator_json" \
    --argjson discovery "$discovery_json" '
      {
        generatedAt: $generatedAt,
        stateNamespace: $stateNamespace,
        stateConfigMap: $stateConfigMap,
        storageClasses: $storageClasses,
        operators: $operators,
        deployments: ($discovery.deployments // []),
        statefulsets: ($discovery.statefulsets // []),
        pvcs: ($discovery.pvcs // [])
      }
    '
}

run_plan() {
  local discovery_json operator_json
  discovery_json="$(fetch_discovery_json)"
  operator_json="$(fetch_operator_state_json)"
  print_plan "$discovery_json" "$operator_json"
}

run_down() {
  local discovery_json operator_json state_json
  discovery_json="$(fetch_discovery_json)"
  operator_json="$(fetch_operator_state_json)"

  print_plan "$discovery_json" "$operator_json"

  if [[ "$(jq -r '(.deployments | length) + (.statefulsets | length)' <<<"$discovery_json")" == "0" ]]; then
    log "No deployments or statefulsets found using target storage classes."
  fi

  state_json="$(build_state_json "$discovery_json" "$operator_json")"
  save_state_configmap "$state_json"

  scale_phase deployment 0 "$operator_json"
  scale_phase deployment 0 "$(jq -c '.deployments' <<<"$discovery_json")"
  scale_phase statefulset 0 "$(jq -c '.statefulsets' <<<"$discovery_json")"

  log "Scale-down complete."
}

run_up() {
  local state_json
  state_json="$(load_state_configmap)"

  jq -e . >/dev/null <<<"$state_json"

  log "Restoring workloads from ConfigMap $STATE_NAMESPACE/$STATE_CONFIGMAP"

  scale_phase statefulset __from_item__ "$(jq -c '.statefulsets' <<<"$state_json")"
  scale_phase deployment __from_item__ "$(jq -c '.deployments' <<<"$state_json")"
  scale_phase deployment __from_item__ "$(jq -c '.operators' <<<"$state_json")"

  log "Restore complete."
}

main() {
  parse_args "$@"
  require_bin "$KUBECTL_BIN" jq

  case "$MODE" in
    plan)
      run_plan
      ;;
    down)
      run_down
      ;;
    up)
      run_up
      ;;
  esac
}

main "$@"

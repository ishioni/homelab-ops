set default-list
set lazy
set positional-arguments
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

[doc('Apply local Flux Kustomization')]
[script]
apply-ks ns ks:
    just kube render-local-ks "{{ ns }}" "{{ ks }}" | kubectl apply --server-side --force-conflicts --field-manager=kustomize-controller -f -

[doc('Browse a PVC')]
[script]
browse-pvc namespace claim:
    kubectl browse-pvc -n {{ namespace }} -i mirror.gcr.io/alpine:latest {{ claim }}

[doc('Delete local Flux Kustomization')]
[script]
delete-ks ns ks:
    just kube render-local-ks "{{ ns }}" "{{ ks }}" | kubectl delete -f -

[doc('Open a shell on a node')]
[script]
node-shell node:
    kubectl debug node/{{ node }} -n default -it --image="mirror.gcr.io/alpine:latest" --profile sysadmin
    kubectl delete pod -n default -l app.kubernetes.io/managed-by=kubectl-debug

[doc('Prune pods in Failed, Pending, or Succeeded state')]
[script]
prune-pods:
    for phase in Failed Pending Succeeded; do
        kubectl delete pods -A --field-selector status.phase="$phase" --ignore-not-found=true
    done

[doc("Plan NAS-backed workload shutdown (discovers PVC users on dcsi-iscsi/dcsi-nfs)")]
[script]
nas-plan *args:
    ../hack/nas-storage-maintenance.sh plan {{ args }}

[doc("Scale down NAS-backed workloads: operators -> deployments -> statefulsets")]
[script]
nas-down *args:
    ../hack/nas-storage-maintenance.sh down {{ args }}

[doc("Restore NAS-backed workloads in reverse: statefulsets -> deployments -> operators")]
[script]
nas-up *args:
    ../hack/nas-storage-maintenance.sh up {{ args }}

[doc('Sync ExternalSecrets')]
[script]
sync-es:
    kubectl get es --no-headers -A | while read -r ns name _; do
        kubectl -n "$ns" annotate --field-manager flux-client-side-apply --overwrite es "$name" force-sync="$(date +%s)"
    done

[doc('Sync GitRepositories')]
[script]
sync-git:
    kubectl get gitrepo --no-headers -A | while read -r ns name _; do
        kubectl -n "$ns" annotate --field-manager flux-client-side-apply --overwrite gitrepo "$name" reconcile.fluxcd.io/requestedAt="$(date +%s)"
    done

[doc('Sync HelmReleases')]
[script]
sync-hr:
    kubectl get hr --no-headers -A | while read -r ns name _; do
        kubectl -n "$ns" annotate --field-manager flux-client-side-apply --overwrite hr "$name" reconcile.fluxcd.io/requestedAt="$(date +%s)" reconcile.fluxcd.io/forceAt="$(date +%s)"
    done

[doc('Sync Kustomizations')]
[script]
sync-ks:
    kubectl get ks --no-headers -A | while read -r ns name _; do
        kubectl -n "$ns" annotate --field-manager flux-client-side-apply --overwrite ks "$name" reconcile.fluxcd.io/requestedAt="$(date +%s)"
    done

[doc('Sync OCIRepositories')]
[script]
sync-oci:
    kubectl get ocirepo --no-headers -A | while read -r ns name _; do
        kubectl -n "$ns" annotate --field-manager flux-client-side-apply --overwrite ocirepo "$name" reconcile.fluxcd.io/requestedAt="$(date +%s)"
    done

[doc('View a secret')]
[script]
view-secret namespace secret:
    kubectl view-secret -n {{ namespace }} {{ secret }}

[doc('Trigger Kopiur Snapshotpolicy')]
[script]
snapshot-kopiur ns name:
    kopiur -n "{{ ns }}" snapshot now --policy "{{ name }}"

[doc('Trigger all Kopiur Snapshotpolicies')]
[script]
snapshot-kopiur-all:
    kubectl get snapshotpolicies.kopiur.home-operations.com --no-headers -A | while read -r ns name _; do
      just kube snapshot-kopiur "$ns" "$name"
    done

[private]
render-local-ks ns ks:
    flate build ks --namespace "{{ ns }}" --output yaml "{{ ks }}"

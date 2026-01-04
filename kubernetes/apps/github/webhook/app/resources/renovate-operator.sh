#!/usr/bin/env bash
set -euo pipefail
set -x
# Incoming arguments
JOB=${1:-}
NAMESPACE=${2:-}
PROJECT=${3:-}

# URL encode the project name
PROJECT=$(echo "${PROJECT}" | jq -Rr @uri)
echo ${JOB}
echo ${NAMESPACE}
echo ${PROJECT}
echo "Number of arguments: $#"
echo "All arguments (\$@): [$@]"
echo "All arguments individually:"
for i in "$@"; do
  echo "  [$i]"
done

curl -s -X POST \
  "http://renovate-operator-webhook.github.svc.cluster.local:8082/webhook/v1/schedule?job=${JOB}&namespace=${NAMESPACE}&project=${PROJECT}"

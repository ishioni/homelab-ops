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

curl -s -X POST \
  "http://renovate-operator-webhook.github.svc.cluster.local:8082/webhook/v1/schedule?job=${JOB}&namespace=${NAMESPACE}&project=${PROJECT}"

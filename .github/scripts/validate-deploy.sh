#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

BIN_DIR=$(cat .bin_dir)

export PATH="${BIN_DIR}:${PATH}"

source "${SCRIPT_DIR}/validation-functions.sh"

if ! command -v oc 1> /dev/null 2> /dev/null; then
  echo "oc cli not found" >&2
  exit 1
fi

if ! command -v kubectl 1> /dev/null 2> /dev/null; then
  echo "kubectl cli not found" >&2
  exit 1
fi

if ! command -v ibmcloud 1> /dev/null 2> /dev/null; then
  echo "ibmcloud cli not found" >&2
  exit 1
fi

echo "******************************"
echo " show gitops-output.json content"
echo "******************************"
echo ""
echo "******************************"
ROOT_PATH=$(pwd)
echo "ROOT_PATH: $ROOT_PATH"
cat $ROOT_PATH/gitops-output.json
echo ""
echo "******************************"

export KUBECONFIG=$(cat .kubeconfig)

NAMESPACE=$(cat .namespace)
echo "NAMESPACE: $NAMESPACE"
COMPONENT_NAME=$(jq -r '.name // "terraform-gitops-watson-nlp"' gitops-output.json)
echo "COMPONENT_NAME: $COMPONENT_NAME"
BRANCH=$(jq -r '.branch // "main"' gitops-output.json)
echo "BRANCH: $BRANCH"
SERVER_NAME=$(jq -r '.server_name // "default"' gitops-output.json)
echo "SERVER_NAME: $SERVER_NAME"
LAYER=$(jq -r '.layer_dir // "2-services"' gitops-output.json)
echo "LAYER: $LAYER"
TYPE=$(jq -r '.type // "base"' gitops-output.json)
echo "TYPE: $TYPE"

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

set -e

validate_gitops_content "${NAMESPACE}" "${LAYER}" "${SERVER_NAME}" "${TYPE}" "${COMPONENT_NAME}" "values.yaml"
#validate_gitops_content "${NAMESPACE}" "${LAYER}" "${SERVER_NAME}" "${TYPE}" "${COMPONENT_NAME}" "templates/deployment.yaml"
#validate_gitops_content "${NAMESPACE}" "${LAYER}" "${SERVER_NAME}" "${TYPE}" "${COMPONENT_NAME}" "templates/service.yaml"
check_k8s_namespace "${NAMESPACE}"
check_k8s_resource "${NAMESPACE}" "deployment" "watson-nlp-watson-nlp"
check_k8s_resource "${NAMESPACE}" "service" "watson-nlp-watson-nlp"
cd ..
rm -rf .testrepo

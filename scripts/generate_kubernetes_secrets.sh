#!/usr/bin/env bash
set -e
SCRIPTPATH=$(dirname $(realpath -s $0))
cd $SCRIPTPATH/../security
pwd
PASSWORD=$1
CLUSTER=$(kubectl config current-context)

if [[ -z $PASSWORD ]]; then
  echo "Password not set"
  exit 1
fi
if [[ -z "${OPENSEARCH_NAMESPACE}" ]]; then
  echo "OPENSEARCH_NAMESPACE is not defined"
  exit 1
fi
if [[ -z "${OPENSEARCH_RELEASE}" ]]; then
  echo "OPENSEARCH_RELEASE is not defined"
  exit 1
fi

echo "Generating kubernetes secrets for current cluster '$CLUSTER', release '${OPENSEARCH_RELEASE}', namespace '${OPENSEARCH_NAMESPACE}'"
read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  HASH=$(docker run opensearchproject/opensearch /bin/bash -c "export JAVA_HOME=/usr/share/opensearch/jdk; bash /usr/share/opensearch/plugins/opensearch-security/tools/hash.sh -p $PASSWORD")
  echo "Generating secrets for certificates"
  helm template ${OPENSEARCH_RELEASE} --set opensearch.security.password.hash="$HASH" --set env.cluster=$CLUSTER --show-only templates/opensearch-cert-secrets.yaml . | kubectl apply -n ${OPENSEARCH_NAMESPACE} -f -
  echo "generate kubernetes secret for config files"
  helm template ${OPENSEARCH_RELEASE} --set opensearch.security.password.hash="$HASH" --set env.cluster=$CLUSTER --show-only templates/opensearch-config-secrets.yaml . | kubectl apply -n ${OPENSEARCH_NAMESPACE} -f -
fi

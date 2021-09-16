#!/bin/bash
set -e
CLUSTER=$(kubectl config current-context)
OPENSEARCH_DIR=$(pwd)
VALUES_FILE=$1

if [[ -z $CLUSTER ]]; then
  echo "Cluster is not set"
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

if [ ! -f $VALUES_FILE ]; then
  echo "$VALUES_FILE does not exist"
  exit 1
fi

echo "current OPENSEARCH dir ${OPENSEARCH_DIR}"
echo "deploying Opensearch with release name: ${OPENSEARCH_RELEASE} to cluster: $CLUSTER, namespace: ${OPENSEARCH_NAMESPACE} and value file: $VALUES_FILE"
read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  cd $OPENSEARCH_DIR
  pwd
  kubectl config use-context $CLUSTER
  kubens ${OPENSEARCH_NAMESPACE}
  helm upgrade --install ${OPENSEARCH_RELEASE} -f $VALUES_FILE .
fi

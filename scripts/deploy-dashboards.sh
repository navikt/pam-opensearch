#!/bin/bash
set -e
CLUSTER=$(kubectl config current-context)
DASHBOARDS_DIR=$(pwd)
VALUES_FILE=$1

if [[ -z $CLUSTER ]]; then
  echo "Cluster is not set"
  exit 1
fi
if [[ -z "${DASHBOARDS_NAMESPACE}" ]]; then
  echo "DASHBOARDS_NAMESPACE is not defined"
  exit 1
fi
if [[ -z "${DASHBOARDS_RELEASE}" ]]; then
  echo "DASHBOARDS_RELEASE is not defined"
  exit 1
fi

if [ ! -f $VALUES_FILE ]; then
  echo "$VALUES_FILE does not exist"
  exit 1
fi

echo "current DASHBOARDS dir ${DASHBOARDS_DIR}"
echo "deploying DASHBOARDS with release name: ${DASHBOARDS_RELEASE} to cluster: $CLUSTER, namespace: ${DASHBOARDS_NAMESPACE} and value file: $VALUES_FILE"
read -p "Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  cd $DASHBOARDS_DIR
  pwd
  kubectl config use-context $CLUSTER
  kubens ${DASHBOARDS_NAMESPACE}
  helm upgrade --install ${DASHBOARDS_RELEASE} -f $VALUES_FILE .
fi

#! /usr/bin/env bash

echo -n "Enter a Kernbernetes cluster ID [kernbernetes]: "
read CLUSTER_ID

# aws
export AWS_SSH_KEY=$(realpath secrets/Kernbernetes.pem)
export KUBERNETES_PROVIDER=aws
export KUBE_AWS_INSTANCE_PREFIX=${CLUSTER_ID:-kernbernetes}
export KUBE_AWS_ZONE=us-west-1a
export KUBE_OS_DISTRIBUTION=jessie

# spin down kube
echo "Stopping Kernbernetes cluster on AWS..."
echo "Using SSH key at $AWS_SSH_KEY"
cd build/kubernetes && ./cluster/kube-down.sh

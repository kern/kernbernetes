#! /usr/bin/env bash

set -e
set -u

echo -n "Enter a Kernbernetes cluster ID [kernbernetes]: "
read CLUSTER_ID

# aws
export AWS_DEFAULT_PROFILE=kernbernetes
export AWS_S3_BUCKET=kernbernetes-kube
export AWS_S3_REGION=us-west-2
export AWS_SSH_KEY=$(realpath secrets/keys/kernbernetes.pem)
export KUBERNETES_PROVIDER=aws
export KUBE_AWS_INSTANCE_PREFIX=${CLUSTER_ID:-kernbernetes}
export KUBE_AWS_ZONE=us-west-2a
export KUBE_OS_DISTRIBUTION=jessie
export MASTER_SIZE=t2.micro
export NODE_SIZE=m4.large
export NUM_NODES=1

# kubernetes & docker
export KUBE_CONTAINER_RUNTIME=docker
export DOCKER_STORAGE=aufs
export EXTRA_DOCKER_OPTS=
export KUBE_RUNTIME_CONFIG=
export KUBE_ENABLE_INSECURE_REGISTRY=true

# disk sizes
export MASTER_DISK_TYPE=gp2
export MASTER_DISK_SIZE=16
export MASTER_ROOT_DISK_TYPE=gp2
export MASTER_ROOT_DISK_SIZE=8
export NODE_ROOT_DISK_TYPE=gp2
export NODE_ROOT_DISK_SIZE=32

# monitoring & logging
export KUBE_ENABLE_CLUSTER_MONITORING=influxdb
export KUBE_ENABLE_CLUSTER_UI=true
export KUBE_ENABLE_CLUSTER_LOGGING=false
export KUBE_ENABLE_NODE_LOGGING=false
export KUBE_LOGGING_DESTINATION=none

# networking
export CLUSTER_IP_RANGE=10.244.0.0/16
export DNS_SERVER_IP=10.0.0.10
export KUBE_ENABLE_CLUSTER_DNS=true
export KUBE_ENABLE_NODE_PUBLIC_IP=true
export MASTER_IP_RANGE=10.246.0.0/24
export MASTER_RESERVED_IP=
export NON_MASQUERADE_CIDR=10.0.0.0/8
export SERVICE_CLUSTER_IP_RANGE=10.0.0.0/16

# run kubernetes run!
echo "Starting Kernbernetes cluster on AWS..."
echo "Using SSH key at $AWS_SSH_KEY"
cd build/kubernetes && ./cluster/kube-up.sh

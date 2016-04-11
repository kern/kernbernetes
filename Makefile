.PHONY: all FORCE \
	start-cluster stop-cluster \
	namespace filepizza \
	context nodes pods all-pods secrets all-secrets rc all-rc deployments all-deployments services all-services

KUBERNETES_VERSION ?= v1.2.0
KUBERNETES_URL ?= https://storage.googleapis.com/kubernetes-release/release/$(KUBERNETES_VERSION)/kubernetes.tar.gz

CONTEXT ?= aws_kernbernetes
NAMESPACE ?= default

all: filepizza

FORCE:

# =============================================================================
# cluster management

build:
	@ mkdir -p build

build/kubernetes.tar.gz: | build
	@ curl -L -o build/kubernetes.tar.gz $(KUBERNETES_URL)

build/kubernetes: build/kubernetes.tar.gz
	@ cd build && tar zxfv kubernetes.tar.gz

start-cluster: secrets/Kernbernetes.pem.pub | build/kubernetes
	@ ./scripts/start-cluster.sh | tee log/start-cluster-$(shell date "+%Y-%m-%d-%H-%M-%S").log

stop-cluster: secrets/Kernbernetes.pem.pub | build/kubernetes
	@ ./scripts/stop-cluster.sh | tee log/stop-cluster-$(shell date "+%Y-%m-%d-%H-%M-%S").log

filepizza: secrets/all.yaml objects/filepizza.yaml

context:
	@ kubectl config use-context $(CONTEXT) --namespace=$(NAMESPACE) > /dev/null

# =============================================================================
# secret management

secrets/Kernbernetes.pem:
	@ echo "secrets/Kernbernetes.pem was not found!" && exit 1

secrets/Kernbernetes.pem.pub: secrets/Kernbernetes.pem
	@ echo "Generating public key for secrets/Kernbernetes.pem"
	@ chmod 600 secrets/Kernbernetes.pem
	@ ssh-keygen -y -f secrets/Kernbernetes.pem > secrets/Kernbernetes.pem.pub

secrets/all.yaml: context
	@ if [[ ! -e secrets/all.yaml ]]; then echo "secrets/all.yaml was not found!"; exit 1; fi
	@ kubectl apply -f secrets/all.yaml

# =============================================================================
# object management

%.yaml: context
	@ kubectl apply -f $@

nodes: context
	@ kubectl get nodes

pods: context
	@ kubectl get pods

all-pods: context
	@ kubectl --all-namespaces=true get pods

secrets: context
	@ kubectl get secrets

all-secrets: context
	@ kubectl --all-namespaces=true get secrets

rc: context
	@ kubectl get rc

all-rc: context
	@ kubectl --all-namespaces=true get rc

deployments: context
	@ kubectl get deployments

all-deployments: context
	@ kubectl --all-namespaces=true get deployments

services: context
	@ kubectl get services

all-services: context
	@ kubectl --all-namespaces=true get services

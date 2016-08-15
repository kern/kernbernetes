# =============================================================================
# config

KUBERNETES_VERSION ?= v1.3.5
KUBERNETES_URL ?= https://storage.googleapis.com/kubernetes-release/release/$(KUBERNETES_VERSION)/kubernetes.tar.gz

CONTEXT ?= aws_kernbernetes
NAMESPACE ?= kernbernetes

.PHONY: all
all: up-ext

# =============================================================================
# kubernetes

.PHONY: start-cluster
start-cluster: secrets/keys/kernbernetes.pem.pub | build/kubernetes
	@ ./scripts/start-cluster.sh | tee log/start-cluster-$(shell date "+%Y-%m-%d-%H-%M-%S").log

.PHONY: stop-cluster
stop-cluster: secrets/keys/kernbernetes.pem.pub | build/kubernetes
	@ ./scripts/stop-cluster.sh | tee log/stop-cluster-$(shell date "+%Y-%m-%d-%H-%M-%S").log

.PHONY: context
context:
	@ kubectl config use-context $(CONTEXT) --namespace=$(NAMESPACE) > /dev/null

build:
	@ mkdir -p build

build/kubernetes.tar.gz: | build
	@ curl -L -o build/kubernetes.tar.gz $(KUBERNETES_URL)

build/kubernetes: build/kubernetes.tar.gz
	@ cd build && tar zxfv kubernetes.tar.gz

%.yaml: context
	@ kubectl apply -f $@

# =============================================================================
# secrets

secrets/keys/%.pem:
	@ echo "$@ was not found! It's (hopefully) stored in 1Password. :)" && exit 1

secrets/keys/%.pem.pub: secrets/keys/%.pem
	@ echo "Generating public key for $< at $@"
	@ chmod 600 $<
	@ ssh-keygen -y -f $< > $@

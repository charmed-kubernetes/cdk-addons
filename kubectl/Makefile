ifndef KUBE_VERSION
$(error Aborting, KUBE_VERSION is not set.)
endif

kubectl_$(KUBE_VERSION)_amd64.snap: snapcraft.yaml kubectl_$(KUBE_VERSION)
	@mkdir -p build
	@cp kubectl_$(KUBE_VERSION) build/kubectl
	@printf "\nBuilding kubectl snap version $(KUBE_VERSION)...\n"
	@snapcraft

snapcraft.yaml: kubectl.yaml
	@sed -e s/KUBE_VERSION/$(KUBE_VERSION)/g kubectl.yaml > snapcraft.yaml

kubectl_$(KUBE_VERSION):
	@if [ ! -e kubectl_$(KUBE_VERSION) ]; then \
		printf "\nDownloading kubectl...\n"; \
		curl  -o kubectl_$(KUBE_VERSION) -LO https://storage.googleapis.com/kubernetes-release/release/v$(KUBE_VERSION)/bin/linux/amd64/kubectl; \
	fi
	@chmod +x kubectl_$(KUBE_VERSION)

clean: snapcraft.yaml
	@echo Cleaning kubectl...
	@mkdir -p build
	@snapcraft clean > /dev/null
	@rm -rf build > /dev/null 2>&1 | true
	@rm *.snap > /dev/null 2>&1 | true
	@rm snapcraft.yaml > /dev/null 2>&1 | true

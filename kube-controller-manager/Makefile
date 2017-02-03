ifndef KUBE_VERSION
$(error Aborting, KUBE_VERSION is not set.)
endif

kube-controller-manager_$(KUBE_VERSION)_amd64.snap: snapcraft.yaml kube-controller-manager_$(KUBE_VERSION)
	@mkdir -p build
	@cp kube-controller-manager_$(KUBE_VERSION) build/kube-controller-manager
	@cp kube-controller-manager-daemon build
	@printf "\nBuilding kube-controller-manager snap version $(KUBE_VERSION)...\n"
	@snapcraft

snapcraft.yaml: kube-controller-manager.yaml
	@sed -e s/KUBE_VERSION/${KUBE_VERSION}/g kube-controller-manager.yaml > snapcraft.yaml

kube-controller-manager_$(KUBE_VERSION):
	@if [ ! -e kube-controller-manager_$(KUBE_VERSION) ]; then \
		printf "\nDownloading kube-controller-manager...\n"; \
		curl  -o kube-controller-manager_$(KUBE_VERSION) -LO https://storage.googleapis.com/kubernetes-release/release/v$(KUBE_VERSION)/bin/linux/amd64/kube-controller-manager; \
	fi
	@chmod +x kube-controller-manager_$(KUBE_VERSION)

clean: snapcraft.yaml
	@echo Cleaning kube-controller-manager...
	@mkdir -p build
	@snapcraft clean > /dev/null
	@rm -rf build > /dev/null 2>&1 | true
	@rm *.snap > /dev/null 2>&1 | true
	@rm snapcraft.yaml > /dev/null 2>&1 | true

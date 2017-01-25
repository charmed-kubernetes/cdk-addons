
default: download chmod version
	@cp kube-controller-manager_$(KUBE_VERSION) kube-controller-manager
	@printf "\nBuilding kube-controller-manager snap version $(KUBE_VERSION)...\n"
	@snapcraft

version:
	@sed -e s/KUBE_VERSION/${KUBE_VERSION}/g kube-controller-manager.yaml > snapcraft.yaml

download:
	@if [ ! -e kube-controller-manager_$(KUBE_VERSION) ]; then \
		printf "\nDownloading kube-controller-manager...\n"; \
		curl  -o kube-controller-manager_$(KUBE_VERSION) -LO https://storage.googleapis.com/kubernetes-release/release/v$(KUBE_VERSION)/bin/linux/amd64/kube-controller-manager; \
	fi

chmod:
	@chmod +x kube-controller-manager_$(KUBE_VERSION)

clean: version
	@echo Cleaning kube-controller-manager...
	@snapcraft clean > /dev/null
	@rm kube-controller-manager > /dev/null 2>&1 | true
	@rm *.snap > /dev/null 2>&1 | true
	@rm snapcraft.yaml > /dev/null 2>&1 | true

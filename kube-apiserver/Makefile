ifndef KUBE_VERSION
$(error Aborting, KUBE_VERSION is not set.)
endif

kube-apiserver_$(KUBE_VERSION)_amd64.snap: kube-apiserver_$(KUBE_VERSION) snapcraft.yaml
	@mkdir -p build
	@cp kube-apiserver_$(KUBE_VERSION) build/kube-apiserver
	@printf "\nBuilding kube-apiserver snap version $(KUBE_VERSION)...\n"
	@snapcraft

snapcraft.yaml: kube-apiserver.yaml
	@sed -e s/KUBE_VERSION/${KUBE_VERSION}/g kube-apiserver.yaml > snapcraft.yaml

kube-apiserver_$(KUBE_VERSION):
	@if [ ! -e kube-apiserver_$(KUBE_VERSION) ]; then \
		printf "\nDownloading kube-apiserver...\n"; \
		curl  -o kube-apiserver_$(KUBE_VERSION) -LO https://storage.googleapis.com/kubernetes-release/release/v$(KUBE_VERSION)/bin/linux/amd64/kube-apiserver; \
	fi
	@chmod +x kube-apiserver_$(KUBE_VERSION)

clean: snapcraft.yaml
	@echo Cleaning kube-apiserver...
	@mkdir -p build
	@snapcraft clean > /dev/null
	@rm -rf build > /dev/null 2>&1 | true
	@rm *.snap > /dev/null 2>&1 | true
	@rm snapcraft.yaml > /dev/null 2>&1 | true

ifndef KUBE_VERSION
$(error Aborting, KUBE_VERSION is not set.)
endif

kube-proxy_$(KUBE_VERSION)_amd64.snap: snapcraft.yaml kube-proxy_$(KUBE_VERSION)
	@mkdir -p build
	@cp kube-proxy_$(KUBE_VERSION) build/kube-proxy
	@cp kube-proxy-daemon build
	@printf "\nBuilding kube-proxy snap version $(KUBE_VERSION)...\n"
	@snapcraft

snapcraft.yaml: kube-proxy.yaml
	@sed -e s/KUBE_VERSION/$(KUBE_VERSION)/g kube-proxy.yaml > snapcraft.yaml

kube-proxy_$(KUBE_VERSION):
	@if [ ! -e kube-proxy_$(KUBE_VERSION) ]; then \
		printf "\nDownloading kube-proxy...\n"; \
		curl  -o kube-proxy_$(KUBE_VERSION) -LO https://storage.googleapis.com/kubernetes-release/release/v$(KUBE_VERSION)/bin/linux/amd64/kube-proxy; \
	fi
	@chmod +x kube-proxy_$(KUBE_VERSION)

clean: snapcraft.yaml
	@echo Cleaning kube-proxy...
	@mkdir -p build
	@snapcraft clean > /dev/null
	@rm -rf build > /dev/null 2>&1 | true
	@rm *.snap > /dev/null 2>&1 | true
	@rm snapcraft.yaml > /dev/null 2>&1 | true

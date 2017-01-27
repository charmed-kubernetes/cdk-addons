ifndef KUBE_VERSION
$(error Aborting, KUBE_VERSION is not set.)
endif

kubelet_$(KUBE_VERSION)_amd64.snap: snapcraft.yaml kubelet_$(KUBE_VERSION)
	@cp kubelet_$(KUBE_VERSION) kubelet
	@printf "\nBuilding kubelet snap version $(KUBE_VERSION)...\n"
	@snapcraft

snapcraft.yaml: kubelet.yaml
	@sed -e s/KUBE_VERSION/$(KUBE_VERSION)/g kubelet.yaml > snapcraft.yaml

kubelet_$(KUBE_VERSION):
	@if [ ! -e kubelet_$(KUBE_VERSION) ]; then \
		printf "\nDownloading kubelet...\n"; \
		curl  -o kubelet_$(KUBE_VERSION) -LO https://storage.googleapis.com/kubernetes-release/release/v$(KUBE_VERSION)/bin/linux/amd64/kubelet; \
	fi
	@chmod +x kubelet_$(KUBE_VERSION)

clean: snapcraft.yaml
	@echo Cleaning kubelet...
	@snapcraft clean > /dev/null
	@rm kubelet > /dev/null 2>&1 | true
	@rm *.snap > /dev/null 2>&1 | true
	@rm snapcraft.yaml > /dev/null 2>&1 | true

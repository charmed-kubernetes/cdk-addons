
default: download chmod version
	@cp kubectl_$(KUBE_VERSION) kubectl
	@printf "\nBuilding kubectl snap version $(KUBE_VERSION)...\n"
	@snapcraft

version:
	@sed -e s/KUBE_VERSION/$(KUBE_VERSION)/g kubectl.yaml > snapcraft.yaml

download:
	@if [ ! -e kubectl_$(KUBE_VERSION) ]; then \
		curl  -o kubectl_$(KUBE_VERSION) -LO https://storage.googleapis.com/kubernetes-release/release/v$(KUBE_VERSION)/bin/linux/amd64/kubectl; \
	fi

chmod:
	@chmod +x kubectl_$(KUBE_VERSION)

clean: version
	@echo Cleaning kubectl...
	@snapcraft clean > /dev/null
	@rm kubectl > /dev/null 2>&1 | true
	@rm *.snap > /dev/null 2>&1 | true
	@rm snapcraft.yaml > /dev/null 2>&1 | true

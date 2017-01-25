
default: download chmod version
	@cp kube-apiserver_$(KUBE_VERSION) kube-apiserver
	@printf "\nBuilding kube-apiserver snap version $(KUBE_VERSION)...\n"
	@snapcraft

version:
	@sed -e s/KUBE_VERSION/${KUBE_VERSION}/g kube-apiserver.yaml > snapcraft.yaml

download:
	@if [ ! -e kube-apiserver_$(KUBE_VERSION) ]; then \
		curl  -o kube-apiserver_$(KUBE_VERSION) -LO https://storage.googleapis.com/kubernetes-release/release/v$(KUBE_VERSION)/bin/linux/amd64/kube-apiserver; \
	fi

chmod:
	@chmod +x kube-apiserver_$(KUBE_VERSION)

clean: version
	@echo Cleaning kube-apiserver...
	@snapcraft clean > /dev/null
	@rm kube-apiserver > /dev/null 2>&1 | true
	@rm *.snap > /dev/null 2>&1 | true
	@rm snapcraft.yaml > /dev/null 2>&1 | true

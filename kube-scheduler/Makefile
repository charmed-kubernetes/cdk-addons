
kube-scheduler_$(KUBE_VERSION)_amd64.snap: snapcraft.yaml kube-scheduler_$(KUBE_VERSION)
	@cp kube-scheduler_$(KUBE_VERSION) kube-scheduler
	@printf "\nBuilding kube-scheduler snap version $(KUBE_VERSION)...\n"
	@snapcraft

snapcraft.yaml: kube-scheduler.yaml
	@sed -e s/KUBE_VERSION/$(KUBE_VERSION)/g kube-scheduler.yaml > snapcraft.yaml

kube-scheduler_$(KUBE_VERSION):
	@if [ ! -e kube-scheduler_$(KUBE_VERSION) ]; then \
		printf "\nDownloading kube-scheduler...\n"; \
		curl  -o kube-scheduler_$(KUBE_VERSION) -LO https://storage.googleapis.com/kubernetes-release/release/v$(KUBE_VERSION)/bin/linux/amd64/kube-scheduler; \
	fi
	@chmod +x kube-scheduler_$(KUBE_VERSION)

clean: snapcraft.yaml
	@echo Cleaning kube-scheduler...
	@snapcraft clean > /dev/null
	@rm kube-scheduler > /dev/null 2>&1 | true
	@rm *.snap > /dev/null 2>&1 | true
	@rm snapcraft.yaml > /dev/null 2>&1 | true

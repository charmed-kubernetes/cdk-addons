
KUBE_VERSION=1.5.2

ifndef VERBOSE
	MAKEFLAGS += --no-print-directory
endif

targets = kubectl kube-apiserver kube-controller-manager kube-scheduler

.PHONY: $(targets)

default: $(targets)

# There's got to be a way to build the dependencies from a list of targets!
clean: kubectl-clean kube-apiserver-clean kube-controller-manager-clean kube-scheduler-clean
	@rm *.snap 2> /dev/null | true
	@rm -rf build 2> /dev/null | true

# The following are literally all the same; there's got to be a way to do this
# with macros or substitutions or somesuch, but I gave up. -RT

# kubectl

kubectl:
	@mkdir -p build
	@KUBE_VERSION=$(KUBE_VERSION) $(MAKE) -C kubectl
	@cp kubectl/*.snap ./build

kubectl-clean:
	@KUBE_VERSION=$(KUBE_VERSION) $(MAKE) clean -C kubectl

kubectl-install: kubectl
	@sudo snap install ./build/kubectl_$(KUBE_VERSION)_amd64.snap --classic --dangerous

kubectl-uninstall:
	@sudo snap remove kubectl

# kube-apiserver

kube-apiserver:
	@mkdir -p build
	@KUBE_VERSION=$(KUBE_VERSION) $(MAKE) -C kube-apiserver
	@cp kube-apiserver/*.snap ./build

kube-apiserver-clean:
	@KUBE_VERSION=$(KUBE_VERSION) $(MAKE) clean -C kube-apiserver

kube-apiserver-install: kube-apiserver
	@sudo snap install ./build/kube-apiserver_$(KUBE_VERSION)_amd64.snap --classic --dangerous

kube-apiserver-uninstall:
	@sudo snap remove kube-apiserver

# kube-controller-manager

kube-controller-manager:
	@mkdir -p build
	@KUBE_VERSION=$(KUBE_VERSION) $(MAKE) -C kube-controller-manager
	@cp kube-controller-manager/*.snap ./build

kube-controller-manager-clean:
	@KUBE_VERSION=$(KUBE_VERSION) $(MAKE) clean -C kube-controller-manager

kube-controller-manager-install: kube-controller-manager
	@sudo snap install ./build/kube-controller-manager_$(KUBE_VERSION)_amd64.snap --classic --dangerous

kube-controller-manager-uninstall:
	@sudo snap remove kube-controller-manager

# kube-scheduler

kube-scheduler:
	@mkdir -p build
	@KUBE_VERSION=$(KUBE_VERSION) $(MAKE) -C kube-scheduler
	@cp kube-scheduler/*.snap ./build

kube-scheduler-clean:
	@KUBE_VERSION=$(KUBE_VERSION) $(MAKE) clean -C kube-scheduler

kube-scheduler-install: kube-scheduler
	@sudo snap install ./build/kube-scheduler_$(KUBE_VERSION)_amd64.snap --classic --dangerous

kube-scheduler-uninstall:
	@sudo snap remove kube-scheduler

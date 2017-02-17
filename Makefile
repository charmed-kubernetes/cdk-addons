
KUBE_VERSION=1.5.2

ifndef VERBOSE
	MAKEFLAGS += --no-print-directory
endif

targets = kubectl kube-apiserver kube-controller-manager kube-scheduler kubelet kube-proxy

build = ./build-scripts/build

.PHONY: $(targets)

default: $(targets)

# There's got to be a way to build the dependencies from a list of targets!
clean: kubectl-clean kube-apiserver-clean kube-controller-manager-clean kube-scheduler-clean kubelet-clean kube-proxy-clean
	@rm -rf kube_bins

# The following are literally all the same; there's got to be a way to do this
# with macros or substitutions or somesuch, but I gave up. -RT

# kubectl

kubectl:
	@KUBE_VERSION=${KUBE_VERSION} ${build} kubectl

kubectl-clean:
	@rm -rf kubectl

kubectl-install: kubectl
	@sudo snap install kubectl/kubectl_$(KUBE_VERSION)_amd64.snap --classic --dangerous

kubectl-uninstall:
	@sudo snap remove kubectl

# kube-apiserver

kube-apiserver:
	@KUBE_VERSION=${KUBE_VERSION} ${build} kube-apiserver

kube-apiserver-clean:
	@rm -rf kube-apiserver

kube-apiserver-install: kube-apiserver
	@sudo snap install kube-apiserver/kube-apiserver_$(KUBE_VERSION)_amd64.snap --dangerous

kube-apiserver-uninstall:
	@sudo snap remove kube-apiserver

# kube-controller-manager

kube-controller-manager:
	@KUBE_VERSION=${KUBE_VERSION} ${build} kube-controller-manager

kube-controller-manager-clean:
	@rm -rf kube-controller-manager

kube-controller-manager-install: kube-controller-manager
	@sudo snap install kube-controller-manager/kube-controller-manager_$(KUBE_VERSION)_amd64.snap --dangerous

kube-controller-manager-uninstall:
	@sudo snap remove kube-controller-manager

# kube-scheduler

kube-scheduler:
	@KUBE_VERSION=${KUBE_VERSION} ${build} kube-scheduler

kube-scheduler-clean:
	@rm -rf kube-scheduler

kube-scheduler-install: kube-scheduler
	@sudo snap install kube-scheduler/kube-scheduler_$(KUBE_VERSION)_amd64.snap --dangerous

kube-scheduler-uninstall:
	@sudo snap remove kube-scheduler

# kubelet

kubelet:
	@KUBE_VERSION=${KUBE_VERSION} ${build} kubelet

kubelet-clean:
	@rm -rf kubelet

kubelet-install: kubelet
	@sudo snap install kubelet/kubelet_$(KUBE_VERSION)_amd64.snap --classic --dangerous

kubelet-uninstall:
	@sudo snap remove kubelet

# kube-proxy

kube-proxy:
	@KUBE_VERSION=${KUBE_VERSION} ${build} kube-proxy

kube-proxy-clean:
	@rm -rf kube-proxy

kube-proxy-install: kube-proxy
	@sudo snap install kube-proxy/kube-proxy_$(KUBE_VERSION)_amd64.snap --classic --dangerous

kube-proxy-uninstall:
	@sudo snap remove kube-proxy

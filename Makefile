
KUBE_VERSION=1.5.2

ifndef VERBOSE
	MAKEFLAGS += --no-print-directory
endif

targets = kubectl kube-apiserver kube-controller-manager kube-scheduler kubelet kube-proxy

build = ./build-scripts/build

.PHONY: $(targets)

default: $(targets)

clean:
	@rm -rf build

# The following are literally all the same; there's got to be a way to do this
# with macros or substitutions or somesuch, but I gave up. -RT

# kubectl

kubectl:
	@KUBE_VERSION=${KUBE_VERSION} ${build} kubectl

kubectl-install: kubectl
	@sudo snap install build/kubectl_$(KUBE_VERSION)_amd64.snap --classic --dangerous

kubectl-uninstall:
	@sudo snap remove kubectl

# kube-apiserver

kube-apiserver:
	@KUBE_VERSION=${KUBE_VERSION} ${build} kube-apiserver

kube-apiserver-install: kube-apiserver
	@sudo snap install build/kube-apiserver_$(KUBE_VERSION)_amd64.snap --dangerous

kube-apiserver-uninstall:
	@sudo snap remove kube-apiserver

# kube-controller-manager

kube-controller-manager:
	@KUBE_VERSION=${KUBE_VERSION} ${build} kube-controller-manager

kube-controller-manager-install: kube-controller-manager
	@sudo snap install build/kube-controller-manager_$(KUBE_VERSION)_amd64.snap --dangerous

kube-controller-manager-uninstall:
	@sudo snap remove kube-controller-manager

# kube-scheduler

kube-scheduler:
	@KUBE_VERSION=${KUBE_VERSION} ${build} kube-scheduler

kube-scheduler-install: kube-scheduler
	@sudo snap install build/kube-scheduler_$(KUBE_VERSION)_amd64.snap --dangerous

kube-scheduler-uninstall:
	@sudo snap remove kube-scheduler

# kubelet

kubelet:
	@KUBE_VERSION=${KUBE_VERSION} ${build} kubelet

kubelet-install: kubelet
	@sudo snap install build/kubelet_$(KUBE_VERSION)_amd64.snap --classic --dangerous

kubelet-uninstall:
	@sudo snap remove kubelet

# kube-proxy

kube-proxy:
	@KUBE_VERSION=${KUBE_VERSION} ${build} kube-proxy

kube-proxy-install: kube-proxy
	@sudo snap install build/kube-proxy_$(KUBE_VERSION)_amd64.snap --classic --dangerous

kube-proxy-uninstall:
	@sudo snap remove kube-proxy

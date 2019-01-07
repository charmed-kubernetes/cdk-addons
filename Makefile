KUBE_ARCH=amd64
# need to jump to master to get 1.10.1 for CVE-2018-18264
KUBE_DASHBOARD_VERSION=v1.10.1
KUBE_VERSION=$(shell curl -L https://dl.k8s.io/release/stable.txt)
KUBE_ERSION=$(subst v,,${KUBE_VERSION})
PWD=$(shell pwd)
BUILD=build

default: clean
	cp -r cdk-addons ${BUILD}
	KUBE_VERSION=${KUBE_VERSION} KUBE_DASHBOARD_VERSION=${KUBE_DASHBOARD_VERSION} ./get-addon-templates
	mv templates ${BUILD}
	wget -O ${BUILD}/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/${KUBE_ARCH}/kubectl
	chmod +x ${BUILD}/kubectl
	sed 's/KUBE_VERSION/${KUBE_ERSION}/g' cdk-addons.yaml > ${BUILD}/snapcraft.yaml
	sed -i "s/KUBE_ARCH/${KUBE_ARCH}/g" ${BUILD}/snapcraft.yaml
	cd ${BUILD} && snapcraft
	mv build/*.snap .

docker: clean
	docker build -t cdk-addons-builder .
	docker run --rm -v ${PWD}:/root/snap -w /root/snap -e SNAPCRAFT_SETUP_CORE=1 cdk-addons-builder make KUBE_VERSION=${KUBE_VERSION} KUBE_ARCH=${KUBE_ARCH}


clean:
	@rm -rf ${BUILD} templates

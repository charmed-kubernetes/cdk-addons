
KUBE_VERSION=$(shell curl -L https://dl.k8s.io/release/stable.txt)
KUBE_ERSION=$(subst v,,${KUBE_VERSION})
PWD=$(shell pwd)
BUILD=build

default: clean
	cp -r cdk-addons ${BUILD}
	KUBE_VERSION=${KUBE_VERSION} ./get-addon-templates
	mv templates ${BUILD}
	wget -O ${BUILD}/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl
	chmod +x ${BUILD}/kubectl
	sed 's/KUBE_VERSION/${KUBE_ERSION}/g' cdk-addons.yaml > ${BUILD}/snapcraft.yaml
	cd ${BUILD} && snapcraft

docker: clean
	docker build -t cdk-addons-builder .
	docker run --rm -v ${PWD}:/root/snap -w /root/snap -e SNAPCRAFT_SETUP_CORE=1 cdk-addons-builder make KUBE_VERSION=${KUBE_VERSION}


clean:
	@rm -rf ${BUILD} templates

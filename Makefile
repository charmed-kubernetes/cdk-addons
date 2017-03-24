
KUBE_VERSION=$(shell curl -L https://dl.k8s.io/release/stable.txt)
KUBE_ERSION=$(subst v,,${KUBE_VERSION})

BUILD=build

default:
	rm -rf ${BUILD}
	cp -r cdk-addons ${BUILD}
	rm -rf templates
	KUBE_VERSION=${KUBE_VERSION} ./get-addon-templates
	mv templates ${BUILD}
	wget -O ${BUILD}/kubectl\
	  https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl
	chmod +x ${BUILD}/kubectl
	bash -c "sed 's/KUBE_VERSION/${KUBE_ERSION}/g' cdk-addons.yaml > ${BUILD}/snapcraft.yaml"
	cd ${BUILD} && snapcraft

clean:
	@rm -rf ${BUILD} templates

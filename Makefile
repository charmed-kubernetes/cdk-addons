BUILD=build
KUBE_ARCH=amd64
KUBE_VERSION=$(shell curl -L https://dl.k8s.io/release/stable.txt)
KUBE_ERSION=$(subst v,,${KUBE_VERSION})
PWD=$(shell pwd)

## Pin some addons to known-good versions
# NB: If we lock images to commits/versions, this could affect the image
# version matching in ./get-addon-templates. Be careful here, and verify
# any images we need based on commit are matched/substituted correctly.
# NB Ceph: Need upstream issue resolved before we can bump ceph-csi commit
# https://github.com/ceph/ceph-csi/issues/278
CEPH_CSI_COMMIT=a4dd8457350b4c4586743d78cbd5776437e618b6
COREDNS_COMMIT=d26b5fbfcb53eba71a9a0f827eebea483d6becd7
# pin cloud-provider-openstack because it's under active dev
OPENSTACK_PROVIDER_COMMIT=1b68bd85d5c6670a0b9aa0b7a4ef8934ef1b1eb9
KUBE_DASHBOARD_VERSION=v1.10.1

default: prep
	wget -O ${BUILD}/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/${KUBE_ARCH}/kubectl
	chmod +x ${BUILD}/kubectl
	sed 's/KUBE_VERSION/${KUBE_ERSION}/g' cdk-addons.yaml > ${BUILD}/snapcraft.yaml
	sed -i "s/KUBE_ARCH/${KUBE_ARCH}/g" ${BUILD}/snapcraft.yaml
# NB: do not call cleanbuild as jenkins cannot run the confined lxd snap from /var/lib/jenkins.
# Generic build is safe here as the snap doesnt build anything, hence cant be polluted from the host.
	cd ${BUILD} && snapcraft
	mv build/*.snap .

clean:
	@rm -rf ${BUILD} templates

docker: clean
	docker build -t cdk-addons-builder .
	docker run --rm -v ${PWD}:/root/snap -w /root/snap -e SNAPCRAFT_SETUP_CORE=1 cdk-addons-builder make KUBE_VERSION=${KUBE_VERSION} KUBE_ARCH=${KUBE_ARCH}

prep: clean
	cp -r cdk-addons ${BUILD}
	KUBE_ARCH=${KUBE_ARCH} KUBE_VERSION=${KUBE_VERSION} KUBE_DASHBOARD_VERSION=${KUBE_DASHBOARD_VERSION} CEPH_CSI_COMMIT=${CEPH_CSI_COMMIT} COREDNS_COMMIT=${COREDNS_COMMIT} OPENSTACK_PROVIDER_COMMIT=${OPENSTACK_PROVIDER_COMMIT} ./get-addon-templates
	mv templates ${BUILD}

upstream-images: prep
	$(eval RAW_IMAGES := "$(shell grep -hoE 'image:.*' ./${BUILD}/templates/* | sort -u)")
# NB: sed cleans up image prefix, quotes, and matches '{{ registry|default('k8s.gcr.io') }}/foo-{{ bar }}:latest', replacing the first {{..}} with the specified default registry
	$(eval UPSTREAM_IMAGES := $(shell echo ${RAW_IMAGES} | sed -E -e "s/image: //g" -e "s/\{\{ registry\|default\(([^}]*)\) }}/\1/g" -e "s/['\"]//g"))
	@echo "${KUBE_VERSION}-upstream: ${UPSTREAM_IMAGES}"




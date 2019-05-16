BUILD=build
KUBE_ADDONS=addon-resizer coredns defaultbackend heapster k8s-dns kubernetes-dashboard metrics-server
KUBE_ADDONS_REGISTRY=k8s.gcr.io
KUBE_ARCH=amd64
KUBE_VERSION=$(shell curl -L https://dl.k8s.io/release/stable-1.14.txt)
KUBE_ERSION=$(subst v,,${KUBE_VERSION})
PWD=$(shell pwd)

## Pin some addons to known-good versions
# Need upstream issue resolved before we can bump ceph-csi commit
# https://github.com/ceph/ceph-csi/issues/278
CEPH_CSI_COMMIT=a4dd8457350b4c4586743d78cbd5776437e618b6
COREDNS_COMMIT=3ec05335204d92842edb288f10c715bc84333960
# pin cloud-provider-openstack because it's under active dev
OPENSTACK_PROVIDER_COMMIT=1b68bd85d5c6670a0b9aa0b7a4ef8934ef1b1eb9
KUBE_DASHBOARD_VERSION=v1.10.1

default: prep
	wget -O ${BUILD}/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/${KUBE_ARCH}/kubectl
	chmod +x ${BUILD}/kubectl
	sed 's/KUBE_VERSION/${KUBE_ERSION}/g' cdk-addons.yaml > ${BUILD}/snapcraft.yaml
	sed -i "s/KUBE_ARCH/${KUBE_ARCH}/g" ${BUILD}/snapcraft.yaml
	cd ${BUILD} && snapcraft cleanbuild
	mv build/*.snap .

clean:
	@rm -rf ${BUILD} templates

docker: clean
	docker build -t cdk-addons-builder .
	docker run --rm -v ${PWD}:/root/snap -w /root/snap -e SNAPCRAFT_SETUP_CORE=1 cdk-addons-builder make KUBE_VERSION=${KUBE_VERSION} KUBE_ARCH=${KUBE_ARCH}

prep: clean
	cp -r cdk-addons ${BUILD}
	KUBE_VERSION=${KUBE_VERSION} KUBE_DASHBOARD_VERSION=${KUBE_DASHBOARD_VERSION} CEPH_CSI_COMMIT=${CEPH_CSI_COMMIT} COREDNS_COMMIT=${COREDNS_COMMIT} OPENSTACK_PROVIDER_COMMIT=${OPENSTACK_PROVIDER_COMMIT} ./get-addon-templates
	mv templates ${BUILD}

upstream-images: prep
	$(eval RAW_IMAGES := "$(foreach raw,${KUBE_ADDONS},$(shell grep -hoE 'image:.*${raw}.*' ./${BUILD}/templates/*.yaml | sort -u))")
	$(eval UPSTREAM_IMAGES := $(shell echo ${RAW_IMAGES} | sed -e 's|image: ||g' -e 's|{{ arch }}|${KUBE_ARCH}|g' -e 's|{{[^}]*}}|${KUBE_ADDONS_REGISTRY}|g'))
	@echo "${KUBE_VERSION}-upstream: ${UPSTREAM_IMAGES}"




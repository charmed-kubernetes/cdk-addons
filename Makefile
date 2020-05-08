BUILD=build
KUBE_ARCH=amd64
# NB: change this to ./stable-1.xx.txt on relevant cdk-addons release-1.xx branches
KUBE_VERSION=$(shell curl -L https://dl.k8s.io/release/latest.txt)
KUBE_ERSION=$(subst v,,${KUBE_VERSION})
PWD=$(shell pwd)

## Pin some addons to known-good versions
# NB: If we lock images to commits/versions, this could affect the image
# version matching in ./get-addon-templates. Be careful here, and verify
# any images we need based on commit are matched/substituted correctly.
# NB Ceph: Need upstream issue resolved before we can bump ceph-csi commit
# https://github.com/ceph/ceph-csi/issues/278
CEPH_CSI_COMMIT=a4dd8457350b4c4586743d78cbd5776437e618b6
COREDNS_COMMIT=b0a81f926196cc750ea329476169ac89f0bfd78b
# pin o7k-cloud-provider to current 1.17 commit
# https://github.com/kubernetes/cloud-provider-openstack/commit/486cf06ea7fc3fafa022cc3a0d03fd63c8ff79e2
OPENSTACK_PROVIDER_COMMIT=486cf06ea7fc3fafa022cc3a0d03fd63c8ff79e2
# pin dashboard to current 2.0.0-rc5 commit
# https://github.com/kubernetes/dashboard/commit/646b573a938cc083f1712de05334f31e7003cc4e
KUBE_DASHBOARD_COMMIT=646b573a938cc083f1712de05334f31e7003cc4e
# pin state metrics to current 1.9.5 commit
# https://github.com/kubernetes/kube-state-metrics/commit/7710f43536611dfbd4eba64483baa8d1af39e404
KUBE_STATE_METRICS_COMMIT=7710f43536611dfbd4eba64483baa8d1af39e404

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
	KUBE_VERSION=${KUBE_VERSION} KUBE_DASHBOARD_COMMIT=${KUBE_DASHBOARD_COMMIT} CEPH_CSI_COMMIT=${CEPH_CSI_COMMIT} COREDNS_COMMIT=${COREDNS_COMMIT} OPENSTACK_PROVIDER_COMMIT=${OPENSTACK_PROVIDER_COMMIT} KUBE_STATE_METRICS_COMMIT=${KUBE_STATE_METRICS_COMMIT} ./get-addon-templates
	mv templates ${BUILD}

upstream-images: prep
	$(eval RAW_IMAGES := "$(shell grep -hoE 'image:.*' ./${BUILD}/templates/* | sort -u)")
# NB: sed cleans up image prefix, quotes, and matches '{{ registry|default('k8s.gcr.io') }}/foo-{{ bar }}:latest', replacing the first {{..}} with the specified default registry
	$(eval UPSTREAM_IMAGES := $(shell echo ${RAW_IMAGES} | sed -E -e "s/image: //g" -e "s/\{\{ registry\|default\(([^}]*)\) }}/\1/g" -e "s/['\"]//g"))
	@echo "${KUBE_VERSION}-upstream: ${UPSTREAM_IMAGES}"

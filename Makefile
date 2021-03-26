BUILD=build
KUBE_ARCH=amd64
# NB: change this to ./stable-1.xx.txt on relevant cdk-addons release-1.xx branches
KUBE_VERSION=$(shell curl -L https://dl.k8s.io/release/stable-1.20.txt)
KUBE_ERSION=$(subst v,,${KUBE_VERSION})
PWD=$(shell pwd)

# cdk-addons release branch for comparing images. By default, this should be
# set to the previous stable release-1.xx branch.
PREV_RELEASE=release-1.19

## Pin some addons to known-good versions
# NB: If we lock images to commits/versions, this could affect the image
# version matching in ./get-addon-templates. Be careful here, and verify
# any images we need based on commit are matched/substituted correctly.
CEPH_CSI_COMMIT=a03675e3aeea093a48c389c5795730445356f3e1  # v2.1.2
COREDNS_COMMIT=75a1cad61791d38ba955ef29dad0366c9ad6acc4  # v1.6.7
OPENSTACK_PROVIDER_COMMIT=f571d5f679c2ee157a86c62220deb6772f109db3  # v1.18.0
KUBE_DASHBOARD_COMMIT=5b83803463d035c089ce505991cb37733ee1668e  # v2.0.1
KUBE_STATE_METRICS_COMMIT=b3fa5852d755c912c2601c53781a58567c822b81  # v1.9.7

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
	@rm -rf ${BUILD} ${PREV_RELEASE} templates

docker: clean
	docker build -t cdk-addons-builder .
	docker run --rm -v ${PWD}:/root/snap -w /root/snap -e SNAPCRAFT_SETUP_CORE=1 cdk-addons-builder make KUBE_VERSION=${KUBE_VERSION} KUBE_ARCH=${KUBE_ARCH}

prep: clean
	cp -r cdk-addons ${BUILD}
	KUBE_VERSION=${KUBE_VERSION} KUBE_DASHBOARD_COMMIT=${KUBE_DASHBOARD_COMMIT} CEPH_CSI_COMMIT=${CEPH_CSI_COMMIT} COREDNS_COMMIT=${COREDNS_COMMIT} OPENSTACK_PROVIDER_COMMIT=${OPENSTACK_PROVIDER_COMMIT} KUBE_STATE_METRICS_COMMIT=${KUBE_STATE_METRICS_COMMIT} ./get-addon-templates
	mv templates ${BUILD}

upstream-images: prep
	$(eval RAW_IMAGES := "$(shell grep -rhoE 'image:.*' ./${BUILD}/templates | sort -u)")
# NB: sed cleans up image prefix, quotes, and matches '{{ registry|default('k8s.gcr.io') }}/foo-{{ bar }}:latest', replacing the first {{..}} with the specified default registry
	$(eval UPSTREAM_IMAGES := $(shell echo ${RAW_IMAGES} | sed -E -e "s/image: //g" -e "s/\{\{ registry\|default\(([^}]*)\) }}/\1/g" -e "s/['\"]//g"))
	@echo "${KUBE_VERSION}-upstream: ${UPSTREAM_IMAGES}"

compare-prep:
	git clone --branch ${PREV_RELEASE} --single-branch --depth 1 https://github.com/charmed-kubernetes/cdk-addons.git ${PREV_RELEASE}
	$(MAKE) -C ${PREV_RELEASE} prep

compare-images: upstream-images compare-prep
	$(eval PREV_RAW := "$(shell grep -rhoE 'image:.*' ./${PREV_RELEASE}/${BUILD}/templates | sort -u)")
# NB: sed cleans up image prefix, quotes, and matches '{{ registry|default('k8s.gcr.io') }}/foo-{{ bar }}:latest', replacing the first {{..}} with the specified default registry
	$(eval PREV_IMAGES := $(shell echo ${PREV_RAW} | sed -E -e "s/image: //g" -e "s/\{\{ registry\|default\(([^}]*)\) }}/\1/g" -e "s/['\"]//g"))
# NB: compare image lists, only keeping those unique to UPSTREAM_IMAGES
	$(eval NEW_IMAGES := $(shell bash -c "comm -13 <(echo ${PREV_IMAGES} | tr ' ' '\n' | sort) <(echo ${UPSTREAM_IMAGES} | tr ' ' '\n' | sort) | tr '\n' ' '"))
	@echo "${KUBE_VERSION}-versus-${PREV_RELEASE}: ${NEW_IMAGES}"

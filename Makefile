BUILD=build
KUBE_ARCH=amd64
# NB: change this to ./stable-1.xx.txt on relevant cdk-addons release-1.xx branches
KUBE_VERSION=$(shell curl -L https://dl.k8s.io/release/latest.txt)
KUBE_ERSION=$(subst v,,${KUBE_VERSION})
PWD=$(shell pwd)
RELEASE_BRANCH=release-$(basename ${KUBE_ERSION})
LOCAL_BRANCH=$(strip $(shell git symbolic-ref HEAD 2>/dev/null | sed -e 's|^refs/heads/||'))
REMOTE_BRANCH=$(strip $(shell git branch --list -r '*/'${RELEASE_BRANCH}))

# cdk-addons release branch for comparing images. By default, this should be
# set to the previous stable release-1.xx branch.
PREV_RELEASE=release-1.20

## Pin some addons to known-good versions
# NB: If we lock images to commits/versions, this could affect the image
# version matching in ./get-addon-templates. Be careful here, and verify
# any images we need based on commit are matched/substituted correctly.
CEPH_CSI_COMMIT=a07260f19153cb6fef7cb27bfb9135082630830e  # v3.3.1
COREDNS_COMMIT=316f8a857c06813cc899267a4428bf5ba4088d87  # v1.8.3
OPENSTACK_PROVIDER_COMMIT=a6a2bea4f376281887c7bcc2d1f612611e5f3dac  # v1.22.0
KUBE_DASHBOARD_COMMIT=0a30039e0111cbfd0c9bb09d6de6649e4a36fc3a  # v2.2.0
KUBE_STATE_METRICS_COMMIT=e72315512a38653b19dcfe4429f93eadedc0ea96  # v1.9.8

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

branch-matches-version:
ifneq ($(REMOTE_BRANCH),)
  ifneq ($(LOCAL_BRANCH),$(RELEASE_BRANCH))
    $(error Must be on ${RELEASE_BRANCH}, not ${LOCAL_BRANCH})
  endif
endif

compare-images: branch-matches-version upstream-images compare-prep
	$(eval PREV_RAW := "$(shell grep -rhoE 'image:.*' ./${PREV_RELEASE}/${BUILD}/templates | sort -u)")
# NB: sed cleans up image prefix, quotes, and matches '{{ registry|default('k8s.gcr.io') }}/foo-{{ bar }}:latest', replacing the first {{..}} with the specified default registry
	$(eval PREV_IMAGES := $(shell echo ${PREV_RAW} | sed -E -e "s/image: //g" -e "s/\{\{ registry\|default\(([^}]*)\) }}/\1/g" -e "s/['\"]//g"))
# NB: compare image lists, only keeping those unique to UPSTREAM_IMAGES
	$(eval NEW_IMAGES := $(shell bash -c "comm -13 <(echo ${PREV_IMAGES} | tr ' ' '\n' | sort) <(echo ${UPSTREAM_IMAGES} | tr ' ' '\n' | sort) | tr '\n' ' '"))
	@echo "${KUBE_VERSION}-versus-${PREV_RELEASE}: ${NEW_IMAGES}"

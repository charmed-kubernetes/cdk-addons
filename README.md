# Charmed Kubernetes Addons Snap

To build the cdk-addons snap, run `make` here and check for the results in the
current directory.

```sh
$ make

$ ls *.snap
cdk-addons_1.20.2_amd64.snap
```

By default, the latest stable version of Kubernetes is queried. To override
this, set the `KUBE_VERSION` variable when calling make:

```sh
$ make KUBE_VERSION=v1.20.2
```

Make sure to include the `v` prefix when overriding versions.

The `amd64` architecture is built by default. To select a different
architecture, set the `KUBE_ARCH` variable when calling make:

```sh
$ make KUBE_ARCH=arm64
```

To generate a list of images used by cdk-addons, use the `upstream-images`
target:

```sh
$ make upstream-images
...
v1.21.0-beta.1-upstream: docker.io/coredns/coredns:1.8.3 docker.io/k8scloudprovider/cinder-csi-plugin:v1.20.0 docker.io/k8scloudprovider/k8s-keystone-auth:v1.20.0 docker.io/k8scloudprovider/openstack-cloud-controller-manager:v1.20.0 docker.io/kubernetesui/dashboard:v2.2.0 docker.io/kubernetesui/metrics-scraper:v1.0.6 k8s.gcr.io/k8s-dns-dnsmasq-nanny:1.15.10 k8s.gcr.io/k8s-dns-kube-dns:1.15.10 k8s.gcr.io/k8s-dns-sidecar:1.15.10 k8s.gcr.io/metrics-server-{{ arch }}:v0.3.6 k8s.gcr.io/sig-storage/csi-attacher:v2.2.1 k8s.gcr.io/sig-storage/csi-node-driver-registrar:v1.3.0 k8s.gcr.io/sig-storage/csi-provisioner:v1.6.1 k8s.gcr.io/sig-storage/csi-resizer:v0.5.1 k8s.gcr.io/sig-storage/csi-snapshotter:v2.1.3 k8s.gcr.io/sig-storage/livenessprobe:v2.1.0 nvcr.io/nvidia/k8s-device-plugin:v0.9.0 quay.io/cephcsi/cephcsi:v2.1.2 quay.io/coreos/kube-state-metrics:v1.9.8 quay.io/k8scsi/csi-attacher:v2.1.1 quay.io/k8scsi/csi-node-driver-registrar:v1.3.0 quay.io/k8scsi/csi-provisioner:v1.4.0 quay.io/k8scsi/csi-resizer:v0.5.0 quay.io/k8scsi/csi-snapshotter:v1.2.2 rocks.canonical.com/cdk/addon-resizer-{{ arch }}:1.8.9
```

To generate a list of images that have changed since the last stable release,
use the `compare-images` target:

```sh
$ make compare-images
...
v1.21.0-beta.1-versus-release-1.20: docker.io/coredns/coredns:1.8.3 docker.io/k8scloudprovider/cinder-csi-plugin:v1.20.0 docker.io/k8scloudprovider/k8s-keystone-auth:v1.20.0 docker.io/k8scloudprovider/openstack-cloud-controller-manager:v1.20.0 docker.io/kubernetesui/dashboard:v2.2.0 docker.io/kubernetesui/metrics-scraper:v1.0.6 k8s.gcr.io/sig-storage/csi-attacher:v2.2.1 k8s.gcr.io/sig-storage/csi-node-driver-registrar:v1.3.0 k8s.gcr.io/sig-storage/csi-provisioner:v1.6.1 k8s.gcr.io/sig-storage/csi-resizer:v0.5.1 k8s.gcr.io/sig-storage/csi-snapshotter:v2.1.3 k8s.gcr.io/sig-storage/livenessprobe:v2.1.0 quay.io/coreos/kube-state-metrics:v1.9.8
```

To set explicit releases for image comparison, use `KUBE_VERSION` and
`PREV_RELEASE` as needed:

```sh
$ make KUBE_VERSION=v1.20.2 PREV_RELEASE=release-1.19 compare-images
...
v1.20.2-versus-release-1.19: docker.io/coredns/coredns:1.8.3 docker.io/k8scloudprovider/cinder-csi-plugin:v1.20.0 docker.io/k8scloudprovider/k8s-keystone-auth:v1.20.0 docker.io/k8scloudprovider/openstack-cloud-controller-manager:v1.20.0 docker.io/kubernetesui/dashboard:v2.2.0 docker.io/kubernetesui/metrics-scraper:v1.0.6 k8s.gcr.io/sig-storage/csi-attacher:v2.2.1 k8s.gcr.io/sig-storage/csi-node-driver-registrar:v1.3.0 k8s.gcr.io/sig-storage/csi-provisioner:v1.6.1 k8s.gcr.io/sig-storage/csi-resizer:v0.5.1 k8s.gcr.io/sig-storage/csi-snapshotter:v2.1.3 k8s.gcr.io/sig-storage/livenessprobe:v2.1.0 quay.io/coreos/kube-state-metrics:v1.9.8
```

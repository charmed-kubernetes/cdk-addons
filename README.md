# Canonical Distribution of Kubernetes Addons Snap

To build the cdk-addons snap, run `make` here and check for the results in the current directory.

```sh
$ make

$ ls *.snap
cdk-addons_1.6.2_amd64.snap
```

By default, the latest stable version of Kubernetes is queried. To override this,
set the `KUBE_VERSION` variable when calling make:

```sh
$ make KUBE_VERSION=v1.6.1
```

Make sure to include the `v` prefix when specifying `KUBE_VERSION`.

The `amd64` architecture is built by default. To select a different architecture,
set the `KUBE_ARCH` variable when calling make:

```sh
$ make KUBE_ARCH=arm64
```

To build inside a docker container, use:

```sh
$ make docker
```

and similarly:

```sh
$ make KUBE_VERSION=v1.6.1 KUBE_ARCH=ppc64le docker
```

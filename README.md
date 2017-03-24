# Canonical Distribution of Kubernetes Addons Snap

To build the cdk-addons snap, run `make` here and check for the results in the `build/` directory.

```sh
$ make

$ tree -L 1 build
build
├── apply
├── cdk-addons_1.5.5_amd64.snap
├── kubectl
├── meta
├── parts
├── prime
├── snapcraft.yaml
├── stage
└── templates

5 directories, 4 files
```

By default, the latest stable version of Kubernetes is queried. To override this,
set the `KUBE_VERSION` variable when calling make:

```sh
$ make KUBE_VERSION=v1.6.1
```

Make sure to include the `v` prefix when specifying `KUBE_VERSION`.

To build inside a docker container, use:

```sh
$ make docker
```

and similarly:

```sh
$ make KUBE_VERSION=v1.6.1 docker
```

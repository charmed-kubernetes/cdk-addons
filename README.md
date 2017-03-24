# Canonical Distribution of Kubernetes Addons Snap

To build the cdk-addons snap, run `make` here and check for the results in the `build/` directory.

```sh
$ make
```

By default, the latest stable version of Kubernetes is queried. To override this,
set the `KUBE_VERSION` variable when calling make:

```sh
$ make KUBE_VERSION=v1.6.1
```

Make sure to include the `v` prefix when specifying `KUBE_VERSION`.

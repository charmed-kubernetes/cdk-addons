# Canonical Distribution of Kubernetes Snaps

This repo is responsible for building all the snaps associated with CDK.

## Build everything

Run `make` here and check for the results in the `build/` directory.

```sh
$ make

Building kubectl snap version 1.5.2...
Preparing to pull kubectl
Pulling kubectl
Preparing to build kubectl
Building kubectl
Staging kubectl
Priming kubectl
Snapping 'kubectl' /                                                            
Snapped kubectl_1.5.2_amd64.snap

Building kube-apiserver snap version 1.5.2...
Preparing to pull kube-apiserver
Pulling kube-apiserver
Preparing to build kube-apiserver
Building kube-apiserver
Staging kube-apiserver
Priming kube-apiserver
Snapping 'kube-apiserver' -                                                     
Snapped kube-apiserver_1.5.2_amd64.snap

$ tree build
build
├── kube-apiserver_1.5.2_amd64.snap
└── kubectl_1.5.2_amd64.snap

0 directories, 2 files
```

## Build one snap

To build a specific snap, run `make` with the name of the snap, e.g., for
kubectl:

```sh
$ make kubectl

Building kubectl snap version 1.5.2...
Preparing to pull kubectl
Pulling kubectl
Preparing to build kubectl
Building kubectl
Staging kubectl
Priming kubectl
Snapping 'kubectl' |                                                            
Snapped kubectl_1.5.2_amd64.snap
```

The result will again be in the `build/` directory.

## Install a snap

Installation make targets are included for individual snaps:

```sh
$ make kube-apiserver-install
[sudo] password for user:
kube-apiserver 1.5.2 installed
```

## Uninstall a snap

There are also make targets for uninstalling a snap:

```sh
$ make kube-apiserver-uninstall
kube-apiserver removed
```

## Cleaning up

Simply run `make clean` to remove everything except downloaded resources:

```sh
$ make clean
Cleaning kubectl...
Cleaning kube-apiserver...
```

## Versioning

Developers, edit `KUBE_VERSION` in the top-level Makefile to update the version
of kubernetes resources acquired.

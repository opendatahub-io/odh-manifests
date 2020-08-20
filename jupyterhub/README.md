# dh-jupyterhub

Kustomize deployment for the Data Hub's internal Jupyterhub instance

## Runbook

The Runbook for Jupyterhub can be found in the dh-runbooks repository at
[jupyterhub.md](https://github.com/AICoE/aicoe-sre/blob/master/runbooks/jupyterhub.md) for deployment instructions.

## Deployment Instructions

### Prerequisites

#### Deploy ODH Operator

To deploy Jupyterhub we first need to deploy the ODH Operator.

Follow the steps in this repo to deploy the ODH Operator: [dh-internal-odh-install](https://gitlab.cee.redhat.com/data-hub/dh-internal-odh-install)

#### Install Kustomize

Install [Kustomize](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/INSTALL.md)

```bash
GO111MODULE=on go get sigs.k8s.io/kustomize/kustomize/v3@v3.5.4
```

See [Kustomize](https://github.com/kubernetes-sigs/kustomize/tree/master/docs)
docs for more info.

### Custom Images

We build a number of custom Jupyter notebook images for use in production
JupyterHub. By default, these images are not included when you deploy to
dev. This is to save resources in our development environments. If you
wish to deploy these custom images run:

```bash
cd overlays/dev
kustomize edit add resource ../../bases/custom-images/
```

This will add custom-images as part of the `kustomize` build when following
the steps below for deployment.

### Deploying to Development

Run the following command from the root of this repository to deploy
Jupyterhub in a development environment:

```bash
kustomize build overlays/dev/ | oc apply -f -
```

### Deploying to Stage

NOTE: You need to be logged in as the `opendatahub-operator` Service Account
in the `dh-stage-jupyterhub` namespace
Run the following command from the root of this repository to deploy
Jupyterhub to stage:

```bash
oc login --token=$(oc sa get-token opendatahub-operator -n dh-stage-jupyterhub)
kustomize build overlays/stage/ | oc apply -f -
```

### Deploying to Production

NOTE: You need to be logged in as the `opendatahub-operator` Service Account
in the `dh-prod-jupyterhub` namespace

Run the following command from the root of this repository to deploy
Jupyterhub to production:

```bash
oc login --token=$(oc sa get-token opendatahub-operator -n dh-prod-jupyterhub)
kustomize build overlays/prod/ | oc apply -f -
```

## Build manifests

If you want to build the manifests on your local file system without deploying
them run the following command from the root of this repository:

```bash
# target_env is either dev, stage, prod
mkdir build
kustomize build overlays/${target_env}/ -o build/
```

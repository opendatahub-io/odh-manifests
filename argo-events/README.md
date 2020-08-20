# Argo Events

Kustomize templates for deploying Argo Events into Argo CD managed namespaces.

## Repository layout

### Base

The base folder points to a remote kustomize base for [Argo Events](https://github.com/argoproj/argo-events/tree/master/manifests). It uses a namespaced variant of the manifests.

Additionally all generic Roles are defined here.

### Overlays

Each overlay is tied to a specific namespace on a cluster. Argo CD Application definition then specifies to which cluster the overlay belongs to.

Additionally an overlay can define more namespace specific resources - usually Roles, RoleBindings and ConfigMaps required in that particular context.

## Usage

If you desire to create a new Argo Events deployment, simply create a new overlay with a Kustomization file that at minimum speficies the base and the namespace:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: <NAMESPACE>

resources:
  - ../../base
```

Then create a new Argo CD application by following the [AICOE-CD guide for Application Management](https://github.com/AICoE/aicoe-cd/blob/master/docs/application_management.md).

Use following source in the application spec:

```yaml
...
spec:
  ...
  source:
    repoURL: https://github.com/AICoE/aicoe-sre
    path: applications/argo-events/overlays/<YOUR_OVERLAY>
    targetRevision: HEAD
  ...
```

## Deployment guide

Run the following command from the root of this repository to deploy Argo Events in a ovelayed environment:

`${target_env}` must much a folder in `overlays`.

```bash
kustomize build overlays/${target_env}/ | oc apply -f -
```

## Build manifests

If you want to build the manifests on your local file system without deploying them, run the following command from the root of this repository:

```bash
mkdir build
kustomize build overlays/${target_env}/ -o build/
```

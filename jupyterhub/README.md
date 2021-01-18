# JupyterHub

JupyterHub comes with 2 components:

1. [jupyterhub](#jupyterhub)
1. [notebook-images](#notebook-images)

## JupyterHub

Contains deployment manifests for JupyterHub instance.

### Parameters

JupyterHub component comes with 4 parameters exposed vie KFDef.

#### s3_endpoint_url

HTTP endpoint exposed by your S3 object storage solution which will be made available to JH users in `S3_ENDPOINT_URL` env variable.

#### storage_class

Name of the storage class to be used for PVCs created by JupyterHub component. This requires `storage-class` **overlay** to be enabled as well to work.

#### registry

URL of the registry where images are located. This is useful when you are trying to deploy to a disconnected/air gapped cluster where images are mirrored to some local registry.

#### registry_db

Same as `registry` but specifically used for the DB deployment since that is pulled from a different registry than the rest of the images by default

##### Examples

```
  - kustomizeConfig:
      overlays:
      - storage-class
      parameters:
        - name: storage_class
          value: standard
        - name: s3_endpoint_url
          value: "s3.odh.com"
      repoRef:
        name: manifests
        path: jupyterhub/jupyterhub
    name: jupyterhub
```


### Overlays

JupyterHub component comes with 2 overlays.

#### build

Contains build manifests for JupyterHub images.

#### storage-class

Customizes JupyterHub to use a specific `StorageClass` for PVCs, see `storage_class` parameter.

## Notebook Images

Contains manifests for Jupyter notebook images compatible with JupyterHub on OpenShift.

### Parameters

Notebook images come with 1 parameter

#### registry

URL of the registry where images are located. This is useful when you are trying to deploy to a disconnected/air gapped cluster where images are mirrored to some local registry.

### Overlays

Notebook Images component comes with 3 overlays.

#### additional

Contains additional Jupyter notebook images.

#### build

Contains build manifests for Jupyter notebook images.

#### cuda

Contains build chain manifest for CUDA enabled ubi 7 based images, provides `tensorflow-gpu` enabled notebook image.

*NOTE:* Builds in this overlay require 4 GB of memory and 4 cpus

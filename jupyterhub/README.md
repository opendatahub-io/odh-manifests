# JupyterHub

JupyterHub comes with 2 components:

1. [jupyterhub](#jupyterhub)
1. [notebook-images](#notebook-images)

## JupyterHub

Contains deployment manifests for JupyterHub instance.

### Parameters

JupyterHub component comes with 2 parameters exposed vie KFDef.

#### s3_endpoint_url

HTTP endpoint exposed by your S3 object storage solution which will be made available to JH users in `S3_ENDPOINT_URL` env variable.

#### storage_class

Name of the storage class to be used for PVCs created by JupyterHub component. This requires `storage-class` **overlay** to be enabled as well to work.

#### jupyterhub_groups_config

A ConfigMap containing comma separated lists of groups which would be used as Admin and User groups for JupyterHub. The default ConfgiMap can be found [here](jupyterhub/base/jupyterhub-groups-configmap.yaml).

#### jupyterhub_secret

A Secret containing configuration values like JupyterHub DB password or COOKIE_SECRET. The default Secret can be found [here](jupyterhub/base/jupyterhub-secret.yaml).

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

JupyterHub component comes with 3 overlays.

#### build

Contains build manifests for JupyterHub images.

#### storage-class

Customizes JupyterHub to use a specific `StorageClass` for PVCs, see `storage_class` parameter.

#### trigger-imagechange

Adds an `imageChange` trigger to the JupyterHub DeploymentConfig to enable automatic redeployment of the JupterHub server when the `jupyterhub-img` `ImagestreamTag` is updated

## Notebook Images

Contains manifests for Jupyter notebook images compatible with JupyterHub on OpenShift.

### Parameters

Notebook Images do not provide any parameters.

### Overlays

Notebook Images component comes with 3 overlays.

#### [additional](notebook-images/overlays/additional/)

Contains additional Jupyter notebook images.

#### [build](notebook-images/overlays/build/)

Contains build manifests for Jupyter notebook images.

#### [cuda](notebook-images/overlays/cuda/)

Contains build chain manifest for CUDA enabled ubi 7 based images, provides `tensorflow-gpu` enabled notebook image.

*NOTE:* Builds in this overlay require 4 GB of memory and 4 cpus

#### [cuda-11.0.3](notebook-images/overlays/cuda-11.0.3/)

Contains build chain manifest for CUDA 11.0.3 enabled ubi 8 based images with python 3.8 support, provides `tensorflow-gpu` and `pytorch-gpu` enabled notebook image.

*NOTE:* Builds in this overlay require 4-6 GB of memory

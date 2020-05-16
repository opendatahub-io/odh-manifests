# AI Library 

The AI Library component installs the AI Library operator as well as the CRD for AI Library.

### Folders
There are 2 folders that contain installation files:

`cluster/base` This folder includes the yaml files that will install the AI Library CRD on your cluster.

`operator/base` This folder includes the yaml files to set up the deployment for the operator in your namespace along with the service account, role, and role binding that is necessary.

### Installation
To install AI Library add the following to the `KfDef` in your yaml file.

Note, to use AI Library, you also need to have [Seldon](../odhseldon/README.md) installed.
In addition, Seldon must be placed before ai-library in the KfDef.  This is shown in the example below.

```
   - kustomizeConfig:
      repoRef:
        name: manifests
        path: odhseldon/cluster
    name: odhseldon
  - kustomizeConfig:
      repoRef:
        name: manifests
        path: ai-library/cluster
    name: ai-library-cluster
  - kustomizeConfig:
      repoRef:
        name: manifests
        path: ai-library/operator
    name: ai-library-operator
```

### Instantiate an AI Library instance
You can install the sample AI Library custom resource found in the AI Library repository by running the following command.

```
oc create -f https://gitlab.com/opendatahub/ai-library/-/raw/master/operator/deploy/crds/ailibrary_v1alpha1_ailibrary_cr.yaml
```

For details on how to work with AI Library, see the official AI Library repository [https://gitlab.com/opendatahub/ai-library/]

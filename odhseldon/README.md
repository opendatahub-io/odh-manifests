# Seldon

Seldon component subscribes to Seldon certified operator, which in turn issues an install of the Seldon certified operator in the namespace. 
 
### Folders
There is one main folder in the Seldon component
1. cluster: contains the subscription to the Seldon operator



### Installation
To install Seldon add the following to the `kfctl` yaml file.

```
   - kustomizeConfig:
      repoRef:
        name: manifests
        path: odhseldon/cluster
    name: odhseldon
```

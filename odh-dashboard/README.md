# Dashboard

The Open Data Hub Dashboard component installs a UI which 

- Shows what's installed
- Show's what's available for installation
- Links to component UIs
- Links to component documentation

For more information, visit the project [GitHub repo](https://github.com/opendatahub-io/odh-dashboard).

### Folders
There is one main folder in the Dashboard component
1. base: contains all the necessary yaml files to install the dashboard

##### Installation
```
  - kustomizeConfig:
      repoRef:
        name: manifests
        path: odh-dashboard
    name: odh-dashboard
```


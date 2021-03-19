# Dashboard

The Open Data Hub Dashboard component installs a UI which 

- Shows what's installed
- Show's what's available for installation
- Links to component UIs
- Links to component documentation

For more information, visit the project [GitHub repo](https://github.com/opendatahub-io/odh-dashboard).

### Folders
1. base: contains all the necessary yaml files to install the dashboard
2. overlays/authentication: Contains the necessary yaml files to install the
   Open Data Hub Dashboard configured to require users to authenticate to the
   OpenShift cluster before they can access the service

##### Installation
```
  - kustomizeConfig:
      repoRef:
        name: manifests
        path: odh-dashboard
    name: odh-dashboard
```

If you would like to configure the dashboard to require authentication:
```
  - kustomizeConfig:
      overlays:
        - authentication
      repoRef:
        name: manifests
        path: odh-dashboard
    name: odh-dashboard
```

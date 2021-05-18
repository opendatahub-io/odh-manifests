# Apache Superset

Apache Superset component installs Apache Superset tool which provides a portal for business intelligence. It provides tools for exploring and visualizing datasets and creating business intelligence dashboards. Superset can also connect to SQL databases for data access. For more information please visit [Apache Superset](https://superset.incubator.apache.org/)  

### Folders
There is one main folder in the Superset component
1. base: contains all the necessary yaml files to install Superset

### Installation
To install Superset add the following to the `kfctl` yaml file.

```
  - kustomizeConfig:
      parameters:
      # Note: The admin username is admin
      - name: SUPERSET_ADMIN_PASSWORD
        value: admin
      repoRef:
        name: manifests
        path: superset
    name: superset
```

By default the user and password to the Superset portal is admin/admin. You can change the password by changing the value of the `SUPERSET_ADMIN_PASSWORD`. To launch the portal, go to the routes in the namespace you installed Open Data Hub and click on the route with `superset` name.

### Superset Database Initialization

Prior to running, Superset's database must be initialized. This is handled via the `superset-init` initContainer. Once this is done, the Superset pod should
start running without intervention. If the database is already initialized the initContainer just checks if everything is as expected and finishes with success.

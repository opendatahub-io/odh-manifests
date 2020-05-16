# Grafana

The Grafana component subscribes to the Grafana operator.  It also creates a
Grafana dashboard instance in your project along with a dashboard and a datasource.
 
## Folders
There are two main folders in the Grafana component
1. cluster: contains the subscription to the operator
2. operator: contains installation of the Grafana instance, dashboard, and datasource

## Grafana Instance

This installation creates a Grafana instance with a route that leads to the UI.

## Grafana Dashboard

This installation creates a grafanadashboard instance that is meant to view data from the strimzi-kafka installation

## Grafana Datasource

This instance creates a grafanadatasource instance that scrapes data from our Prometheus
installation and is required for the grafanadashboard instance mentioned above.

# Installation
To install Grafana add the following to the `KfDef` in your yaml file.

```
  - kustomizeConfig:
      repoRef:
        name: manifests
        path: grafana/cluster
    name: grafana-cluster
  - kustomizeConfig:
      repoRef:
        name: manifests
        path: grafana/grafana
    name: grafana-operator
```

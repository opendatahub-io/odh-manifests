# Grafana

The Grafana component subscribes to the Grafana operator.  It also creates a
Grafana dashboard instance in your project along with 
 
## Folders
There are two main folders in the Prometheus component
1. cluster: contains the subscription to the operator
2. operator: contains the routes and instances of the operator

## Grafana Instance

This installation creates a Grafana instance with a route that leads to the UI.

## Grafana Dashboard

This installation creates a grafanadashboard instance that is meant to view data from the strimzi-kafka installation

## Grafana Datasource

This instance creates a grafanadatasource instance that scrapes data from our Prometheus
installation and is required for the grafanadashboard instance mentioned above.

# Installation
To install Prometheus add the following to the `kfctl` yaml file.

```
  - kustomizeConfig:
      parameters:
      - name: namespace
        value: opendatahub
      repoRef:
        name: manifests
        path: prometheus/cluster
    name: prometheus-cluster
  - kustomizeConfig:
      parameters:
      - name: namespace
        value: opendatahub
      repoRef:
        name: manifests
        path: prometheus/operator
    name: prometheus-operator
```

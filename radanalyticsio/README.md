# Radanalytics

Radanalytics comes with 1 component:

1. [spark operator](#spark-operator)

## Spark Operator

Deploys the Radanalytics [spark operator](https://github.com/radanalyticsio/spark-operator). This operator will watch for the following custom resources cluster-wide:

1. [SparkCluster](https://github.com/radanalyticsio/spark-operator#quick-start)
1. [SparkApplication](https://github.com/radanalyticsio/spark-operator#spark-applications)

### Parameters

Spark Operator does not provide any parameters.

##### Examples

```
  - kustomizeConfig:
      repoRef:
        name: manifests
        path: radanalyticsio/spark/cluster
    name: radanalyticsio-cluster
  - kustomizeConfig:
      repoRef:
        name: manifests
        path: radanalyticsio/spark/operator
    name: radanalyticsio-spark-operator
```


### Overlays

Spark Operator does not provide any overlays.

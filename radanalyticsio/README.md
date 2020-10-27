# Radanalytics

[Radanalytics](https://radanalytics.io/) contains one component, a [spark operator](#spark-operator), that deploy [Apache Spark](https://spark.apache.org) clusters for large-scale data processing.

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
    name: radanalyticsio-spark-cluster
```


### Overlays

Spark Operator does not provide any overlays.

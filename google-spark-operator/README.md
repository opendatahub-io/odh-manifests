# Google Spark operator

[Kubernetes Operator for Spark](https://github.com/GoogleCloudPlatform/spark-on-k8s-operator) contains one component, the [spark operator](#spark-operator), that deploys [Apache Spark](https://spark.apache.org) clusters for large-scale data processing.

By default, the operator will be deployed in the namespace where Open Data Hub is installed, but will listen for SparkApplication and Scheduled SparkApplication objects in all namespaces.

If workloads are deployed outside of the Open Data Hub namespace, it may be necessary to create a dedicated ServiceAccount to be used with those workloads, along with necessary Role and Rolebindings. You can refer to the following files for examples:

- `operator/base/spark-sa.yaml`
- `operator/base/role.yaml`
- `operator/base/rolebinding.yaml`

Documentation for the operator usage is available here: https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/blob/master/docs/user-guide.md

## Parameters

Google Spark Operator does not provide any parameters.

## Examples

```yaml
  - kustomizeConfig:
      repoRef:
        name: manifests
        path: google-spark-operator/operator
    name: google-spark-operator
```

## Overlays

Google Spark Operator does not provide any overlays.

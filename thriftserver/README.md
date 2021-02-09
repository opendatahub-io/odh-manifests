# Spark Thrift Server - HiveServer2

Spark Thrift Server component installs HiveServer2 variant for Spark SQL - Thriftserver. It deploys the Spark SQL Thrift Server intended to expose Spark dataframes modeled as Hive tables through a JDBC connection.

### Folders

There is one main folder in the Thrift Server component `thriftserver` which contains the kustomize manifests.

### Installation

To install Thrift Server add the following to the `kfctl` yaml file.

Minimal install:

```yaml
- kustomizeConfig:
    parameters:
      - name: spark_url
        value: spark://spark.odh.com
    repoRef:
      name: manifests
      path: thriftserver/thriftserver
  name: thriftserver
```

Standalone install:

```yaml
- kustomizeConfig:
    overlays:
      - create-spark-cluster
    parameters:
      - name: s3_endpoint_url
        value: s3.odh.com
      - name: s3_credentials_secret
        value: s3-credentials
    repoRef:
      name: manifests
      path: thriftserver/thriftserver
  name: thriftserver
```

### Overlays

Thrift Server component comes with 2 overlays.

#### storage-class

Customizes Thrift Server to use a specific `StorageClass` for PVCs, see `storage_class` parameter.

#### create-spark-cluster

Requires `radanalytics/spark` component of ODH to be installed first. It provisions a minimal Spark cluster matching the Thrift Server's Spark version and connects the Thrift Server instance to it as it's master Spark cluster. This overlay modifies value of `spark_url` parameter and routes Thrift server to the Spark cluster created by this overlay only.

### Parameters

There are 4 parameters exposed vie KFDef.

#### storage_class

Name of the storage class to be used for PVCs created by Thrift Server component. This requires `storage-class` **overlay** to be enabled as well to work.

#### s3_endpoint_url

HTTP endpoint exposed by your S3 object storage solution which will be made available to Thrift Server as the default S3 filesystem location. In order for this value to be respected properly, the Spark cluster of choice must use the same endpoint.

#### spark_url

Spark cluster [`master-url`](https://spark.apache.org/docs/latest/submitting-applications.html#master-urls) in format `spark://...` which points Thrift Server to Spark cluster which it should use. This parameter value is **overriden** if `create-spark-cluster` overlay is activated. This parameter **is required** to be set if the overlay mentioned before is not used.

#### s3_credentials_secret

Along with `s3_endpoint_url` this parameter configures the Thrift Server's access to S3 object storage. Setting this parameter to any name of local Openshift/Kubernetes Secret resource name would allow Thift Server to consume S3 credentials from it. The secret of choice must contain `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` keys. Keep in mind, in order for this value to be respected by Spark cluster properly, it must use the same credentials. If not set, credentials from [`thriftserver-sample-s3-secret`](thriftserver/base/thriftserver-sample-s3-secret.yaml) will be used instead.

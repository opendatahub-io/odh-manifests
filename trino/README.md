# Trino

Trino component installs trino, the Open Source project of Starburst Presto. Trino is a
distributed SQL Analytical database that can integrate with multiple data sources.

### Folders

There is one main folder in the Trino component `trino` which contains the kustomize manifests.

### Installation

To install Trino, add the following to the `kfctl` file:

```yaml
- kustomizeConfig:
    parameters:
    - name: s3_endpoint_url
      value: s3.odh.com
    - name: s3_credentials_secret
      value: s3-credentials
    repoRef:
      name: manifests
      path: trino
  name: trino
```

### Overlays

Trino component comes with 1 overlay.

#### storage-class

Customizes Trino to use a specific `StorageClass` for PVCs, see `storage_class` parameter.

### Parameters

There are 15 parameters exposed via KFDef.

#### storage_class

Name of the storage class to be used for PVCs created by Trino component. This requires `storage-class` **overlay** to be enabled as well to work.

#### s3_endpoint_url

HTTP endpoint exposed by your S3 object storage solution which will be made available to Trino as the default S3 filesystem location. This parameter is required.

#### s3_credentials_secret

Along with `s3_endpoint_url` this parameter configures the Trino's access to S3 object storage. Setting this parameter to any name of local Openshift/Kubernetes Secret resource name would allow Thift Server to consume S3 credentials from it. The secret of choice must contain `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` keys. If not set, credentials from [`aws-secret`](base/aws-secret.yaml) will be used instead.

#### trino_environment

This is a parameter to specify the `node.environment` property from `node.properties` file, which specifies to all trino nodes the name of the environment. For more information, see the [Trino documentation](https://trino.io/docs/current/installation/deployment.html#node-properties)

#### trino_db_database_name

This parameter will configure the Trino database name. All Hive Metastore information is stored in this database. If not set, `trino` will be used instead.

#### trino_db_secret

Along with `trino_db_database_name` this parameter configures the Hive Metastore database. Setting this parameter to any name of local Openshift/Kubernetes Secret resource name would allow Thift Server to consume S3 credentials from it. The secret of choice must contain `database-user` and `database-password` keys. If not set, credentials from [`trino-db-secret`](base/trino-db-secret.yaml) will be used instead.

#### hive_metastore_cpu_request

This parameter will configure the CPU request for Hive Metastore. If not set, the default value `1` will be used instead.

#### hive_metastore_cpu_limit

This parameter will configure the CPU limit for Hive Metastore. If not set, the default value `1` will be used instead.

#### hive_metastore_memory_request=

This parameter will configure the Memory request for Hive Metastore. If not set, the default value `4Gi` will be used instead.

#### hive_metastore_memory_limit

This parameter will configure the Memory limit for Hive Metastore. If not set, the default value `4Gi` will be used instead.

#### trino_cpu_request

This parameter will configure the CPU request for all Trino nodes (coordinator and workers). If not set, the default value `1` will be used instead.

#### trino_cpu_limit

This parameter will configure the CPU limit for all Trino nodes (coordinator and workers). If not set, the default value `1` will be used instead.

#### trino_memory_request

This parameter will configure the Memory request for all Trino nodes (coordinator and workers). If not set, the default value `4Gi` will be used instead.

#### trino_memory_limit

This parameter will configure the Memory limit for all Trino nodes (coordinator and workers). If not set, the default value `4Gi` will be used instead.

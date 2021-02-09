# Cloudera Hue

Deploys the Cloudera Hue server allowing data exploration on Hive and S3 buckets.

Cloudera Hue is expected to be deployed along any HiveServer2 type of service. In Open Data Hub a [Spark SQL Thrift Server](../thriftserver) is used. Without Thrift Server deployment, Hue won't be able to fulfil any SQL queries. However it can still serve as an S3 browser.

### Folders

There is one main folder in the Hue component `hue` which contains the kustomize manifests.

### Installation

To install Hue add the following to the `kfctl` yaml file.

```yaml
- kustomizeConfig:
    repoRef:
      name: manifests
      path: hue/hue
  name: hue
```

### Overlays

Hue component provides a single overlay.

#### storage-class

Customizes Hue's database to use a specific `StorageClass` for PVC, see `storage_class` parameter.

### Parameters

There are 4 parameters exposed vie KFDef.

#### storage_class

Name of the storage class to be used for PVC created by Hue's database. This requires `storage-class` **overlay** to be enabled as well to work.

#### hue_secret_key

Set session store secret key for Hue web server.

#### s3_endpoint_url

HTTP endpoint exposed by your S3 object storage solution which will be made available to Hue as the default S3 filesystem location.

#### s3_is_secure

Specifies if HTTPS should be used as a transport protocol. Set to `true` for HTTPS and to `false` to use HTTP. Parameter is set to `true` by default.

#### s3_credentials_secret

Along with `s3_endpoint_url`, this parameter configures the Hue's access to S3 object storage. Setting this parameter to any name of local Openshift/Kubernetes Secret resource name would allow Hue to consume S3 credentials from it. The secret of choice must contain `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` keys. Keep in mind, in order for this value to be respected by Spark cluster properly, it must use the same credentials. If not set, credentials from [`hue-sample-s3-secret`](hue/base/hue-sample-s3-secret.yaml) will be used instead.

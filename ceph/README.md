# Ceph Object Storage

Deploys [cn-core](https://github.com/cn-core) image that provides object storage for minimal cluster deployments based on a release of [ceph-container](https://github.com/ceph/ceph-container).

[Ceph](https://ceph.io) provides S3 compatible object storage via the RADOS GateWay(RGW) Service

***NOTE***: This component includes a SCC that enables runAsUser->RunAsAny

### Folders
There is one main folder in the Ceph Object Storage component
1. object-storage/nano/base: contains all the necessary yaml files to install Ceph Object Storage

### Installation
To install Ceph Object Storage add the following to the `kfctl` yaml file.

```
  - kustomizeConfig:
      repoRef:
        name: manifests
        path: ceph/object-storage/scc
    name: ceph-nano-scc
  - kustomizeConfig:
      repoRef:
        name: manifests
        path: ceph/object-storage/nano
    name: ceph-nano
```

### Additional Info
* When `ceph-nano` is deployed, pods in the namespace can access the object storage using the `ceph-nano-0` service name `http://ceph-nano-0`

* Deployment of `ceph-nano` will create a route to a `ceph-nano-dashboard` that provides a S3 web portal for the in pod object storage.

* The ACCESS_KEY and SECRET_KEY created for this deployment can be retrieved from the `ceph-nano-0` pod under `/nano_user_details`
  ```
  # While logged in to the cluster and in the Open Data Hub namespace
  # Output the ceph-nano radosgw settings
  $ oc exec ceph-nano-0 -- cat /nano_user_details | jq '.keys'
    ...
        "keys": [
          {
            "user": "cn",
            "access_key": "ABCDEFGHIJKL01234567",
            "secret_key": "mnOPQRSTUVWXYZV6oSrx2MDtfEUK8R0ETagp5A9X"
          }
        ],
    ...                                                       ],
  ```
  ***NOTE***: The ACCESS_KEY and SECRET_KEY will change EVERY time the pod starts

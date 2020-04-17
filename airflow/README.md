# Apache Airflow
Apache Airflow comes with 2 components
1. [Airflow Operator-Controller] (#Airflow Operator-Controller)
1. [Airflow Base + Cluster] (#Airflow Base + Cluster)

## Airflow Operator-Controller

Airflow Operator-Controller is deployed via the Airflow Cluster and Airflow Operator components in KfDef

## Airflow Base + Cluster

Airflow Base and Airflow Cluster are deployed via the `base.yaml` and `cluster.yaml` [here](https://github.com/VedantMahabaleshwarkar/odh-manifests/tree/dev/airflow/example-celery/base)
[Examples for all available configurations](https://github.com/opendatahub-io/airflow-on-k8s-operator/tree/master/hack/sample)

### Airflow Base

Airflow Base deploys base components for Airflow and can be customized.

example
```
apiVersion: airflow.apache.org/v1alpha1
kind: AirflowBase
metadata:
  name: pc-base
spec:
  postgres:
    operator: False
    image: "registry.access.redhat.com/rhscl/postgresql-10-rhel7"
    version: "latest"
  storage:
    version: ""
```
#### Parameters

1. Database

Can be `postgres` or `mysql`

2. Database Image

Can be changed to custom image and version

### Airflow Cluster

Airflow Cluster deploys cluster components and can be customized

example
```
apiVersion: airflow.apache.org/v1alpha1
kind: AirflowCluster
metadata:
  name: pc-cluster
spec:
  executor: Celery
  redis:
    operator: False
  scheduler:
    image: "quay.io/opendatahub/docker-airflow"
    version: "openshift"
  ui:
    image: "quay.io/opendatahub/docker-airflow"
    replicas: 1
    version: "openshift"
    enableroutes: true
  worker:
    image: "quay.io/opendatahub/docker-airflow"
    replicas: 2
    version: "openshift"
    ForceRoot: "true"
  flower:
    image: "quay.io/opendatahub/docker-airflow"
    replicas: 1
    version: "openshift"
    enableroutes: true
  dags:
    subdir: "airflow/dags/"
    git:
      repo: "https://github.com/VedantMahabaleshwarkar/airflow-dags"
      once: true
  airflowbase:
    name: pc-base
```

#### Parameters

1. Executor
  * `Celery`
  * `Kubernetes`
2. Routes
`enableroutes` should be true when deployed on OpenShift Clusters.
3. DAG Source
Dag source can be customized to point to any github repo where DAG files are located in `{your_repo}/airflow/dags`

# Open Data Hub Manifests
A repository for [Open Data Hub](https://opendatahub.io) components Kustomize manifests.

## Community

* Website: https://opendatahub.io
* Documentation: https://opendatahub.io/docs.html (applicable for version 0.5.1)
* Mailing lists: https://opendatahub.io/community.html
* Community meetings: https://gitlab.com/opendatahub/opendatahub-community

## Components

Open Data Hub is an end-to-end AI/ML platform on top of OpenShift Container Platform which provides various tools for Data Scientists and Engineers. The components currently available are:

* [JupyterHub](jupyterhub/README.md)
* [Airflow](airflow/README.md)
* [Argo Workflows](odhargo/README.md)
* [Grafana](grafana/README.md) & [Prometheus](prometheus/README.md)
* [Spark Operator](radanalyticsio/README.md)
* [Kafka](kafka/README.md)
* [Superset](superset/README.md)
* [AI Library](ai-library/README.md)


Some components are still in process of conversion from Ansible Operator based version on [Gitlab](https://gitlab.com/opendatahub/opendatahub-operator/)

* Seldon
* Data Catalog
    * Hue
    * Hive
    * Thrift Server



## Deploy

We are relying on [Kustomize](https://github.com/kubernetes-sigs/kustomize), [kfctl](https://github.com/kubeflow/kfctl) and [Kubeflow Operator](https://github.com/kubeflow/kfctl/blob/master/operator.md) for deployment.

The two ways to deploy are:

1. Using `kfctl` and follow the documentation at [Kubeflow.org](https://www.kubeflow.org/docs/openshift/). The only change is to use this repository instead of Kubeflow manifests.
2. Following  [Kubeflow Operator](https://github.com/kubeflow/kfctl/blob/master/operator.md) deployment instructions and then using a KFDef from this repository as the custom resource.

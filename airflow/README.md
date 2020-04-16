# Apache Airflow
Adding Airflow Cluster and Airflow Operator in the kfdef file deployes the "Apache Airflow on K8s Operator"
To deploy Airflow components, `base.yaml` and `cluster.yaml` can be deployed from the `example-celery` folder
Other example deployment files can be found [here](https://github.com/opendatahub-io/airflow-on-k8s-operator/tree/master/hack/sample)


## Deployment Configurations

### Routes
If deploying on an Openshift Cluster, to enable routes :
`Spec.UI.EnableRoutes` and `Spec.Flower.EnableRoutes` should be `true` in the `cluster.yaml`

### Celery Workers
If deploying with a Celery Executor, to change `Spec.Worker.Replicas` to control the number of Worker Pods spawned.

### DAGs Source
To customize DAG source, create a git repository and place DAGs under `{your_git_repo}/airflow/dags`
Change `Spec.Dags.Git.Repo` in `cluster.yaml` 

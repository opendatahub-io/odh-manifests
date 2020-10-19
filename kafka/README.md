# DH-Kafka

This repo contains our OpenShift templates for deploying our Kafka
infrastructure.

## Components in this repo

This repo contains deployment artifacts for all components associated with
the internal Data Hub's Kafka deployment. The list of components deployed
are the following:

  1. Kafka cluster definition
  2. Full set of Kafka topics
  3. Kafka Connect cluster
  4. Kafka Connector manager for deploying kafka connector instances
  5. Kafka consumer lag monitor

The deployment instructions that follow deploy all of the above components.

## Deployment Instructions

### Prerequisites

We use [helm](https://helm.sh/) to install our helm charts. We also need the helm secrets plugin.
To install these use the commands below:

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

sudo helm plugin install https://github.com/zendesk/helm-secrets
```

We are using sops to encrypt and decrypt our secret variable files using the ArgoCD ksops key(s).
You can find the public key [here](http://keys.gnupg.net/pks/lookup?op=vindex&fingerprint=on&search=0xBD2C73FF891FBC7E).
For the private key please reach out to [Internal Datahub Devs](mailto:data-hub@redhat.com).

### Install Strimzi

To deploy kafka we first need to deploy the strimzi cluster operator. Follow
the instructions found [here][1].

__Note: All deploying the Strimzi operator requires cluster-admin__
This should create a cluster-operator pod in the namespace. This can be
configured to monitor multiple namespaces. See [here][2] for more information.

### Steps to deploy in dev

To deploy Kafka and its supporting artifacts to dev, run the following command:

```bash
helm secrets install --generate-name -f secrets.enc.yaml -f helm_vars/dev/values.yaml -f helm_vars/dev/secrets.yaml.
```

Once deploy to upgrade the current deployment run the commands:

```bash
helm list
helm secrets upgrade -f secrets.enc.yaml -f helm_vars/prod/values.yaml -f helm_vars/prod/secrets.yaml <chart_name_from_previous_command> .
```

### Steps to deploy in stage

To deploy Kafka and its supporting artifacts to stage, run the following command:

```bash
 helm secrets install --generate-name -f secrets.enc.yaml -f helm_vars/stage/values.yaml -f helm_vars/stage/secrets.yaml .
```

Once deploy to upgrade the current deployment run the commands:

```bash
helm list
helm secrets upgrade -f secrets.enc.yaml -f helm_vars/stage/values.yaml -f helm_vars/stage/secrets.yaml <chart_name_from_previous_command> .
```

### Steps to deploy in prod

To deploy Kafka and its supporting artifacts to prod, run the following commands:
__Note: In order to deploy Kafka you must have the "strimziadmin" role associated with your account in OpenShift in the Kafka namespace. If you do not have the role, open a ticket similar to [PNT0776863](https://redhat.service-now.com/surl.do?n=PNT0776863) and add the team lead as a watcher.__

```bash
helm secrets install --generate-name -f secrets.enc.yaml -f helm_vars/prod/values.yaml -f helm_vars/prod/secrets.yaml .
```

Once deploy to upgrade the current deployment run the commands:

```bash
helm list
helm secrets upgrade -f secrets.enc.yaml -f helm_vars/prod/values.yaml -f helm_vars/prod/secrets.yaml <chart_name_from_previous_command> .
```

## Further Documentation

### Kafka Connect

Our Kafka Connect deployments use a custom docker image that gets deployed
by the Strimzi operator. This custom image contains the necessary
credentials (in the form of environment variables) for connecting to S3, and
it also contains the files for the S3 kafka connector plugin.

### Management of Kafka Connectors

The kafka-connect.yaml template includes deployment of an OpenShift
Job that will manage deployment of Kafka Connector instances. The
configuration for which connectors to deploy is contained in the
`kafka-connector-manager-config` ConfigMap.

Unfortunately, the Job cannot be configured to run whenever the configuration
is updated, so we must manually force it to execute. The only way to do that
is to delete and recreated the Job. To do this, first delete the Job:

```bash
oc delete job kafka-connector-manager -n $NAMESPACE
```

Then recreate it by running the deployment instructions above.

### Monitoring

Kafka exports a lot of topic and cluster level metrics including zookeeper and
JMX metrics. The kafka-persistent.yaml template is already configured to
expose this metrics at the `_prometheus/metrics` endpoint.

In order to generate metrics on Kafka consumer groups, we deploy a kafka
consumer lag monitor with this project as well.

## Testing the deployment

After deploying kafka, we can test our deployment and check if kafka is working properly:

```bash
oc get pods
oc rsh dev-kafka-0
cd bin
```

Create a sample topic:

```bash
$ ./kafka-topics.sh --create --zookeeper localhost \
--replication-factor 1 --partitions 1 --topic sample
```

List topics:

```bash
./kafka-topics.sh --zookeeper localhost --list
```

Produce some sample data:

```bash
$ ./kafka-console-producer.sh --broker-list localhost:9092 \
--topic sample
```

Consume the sample data to see the data you provided:

```bash
$ ./kafka-console-consumer.sh --bootstrap-server localhost:9092 \
--from-beginning --topic sample
```

[1]: https://gitlab.cee.redhat.com/data-hub/dh-strimzi-install
[2]: http://strimzi.io/docs/0.8.2/#deploying-cluster-operator-kubernetes-to-watch-multiple-namespacesstr

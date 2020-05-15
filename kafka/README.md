# Kafka

The Kafka component subscribes to the Strimzi operator, which provides Kafka.  It also creates a
Kafka instance in your project.

## Folders
There are two main folders in the Kafka component
1. cluster: contains the subscription to the Strimzi operator
2. kafka: contains installation of the Kafka instance

## Kafka Instance

The installed Kafka instance is named odh-message-bus and is intended for general use within Open Data Hub

# Installation
To install Kafka add the following to the `KfDef` in your yaml file.

```
  - kustomizeConfig:
      repoRef:
        name: manifests
        path: kafka/cluster
    name: kafka-cluster
  - kustomizeConfig:
      repoRef:
        name: manifests
        path: kafka/kafka
    name: kafka-instance
```

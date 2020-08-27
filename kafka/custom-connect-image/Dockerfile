FROM strimzi/kafka-connect:0.8.1
USER root:root
RUN mkdir -p /opt/kafka/plugins/ && \
    yum -y install java-1.8.0-openjdk procps wget && yum clean all && \
    wget -O confluent-hub-client.tar.gz http://client.hub.confluent.io/confluent-hub-client-latest.tar.gz && \
    tar -xvzf confluent-hub-client.tar.gz && \
    bin/confluent-hub install --no-prompt --component-dir /opt/kafka/plugins/ confluentinc/kafka-connect-s3:5.0.0 --worker-configs config/server.properties
USER kafka:kafka

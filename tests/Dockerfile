FROM registry.access.redhat.com/ubi8/ubi:latest

RUN dnf install -y bc git go-toolset && \
    git clone https://github.com/crobby/peak && \    
    cd /peak && \
    git submodule update --init

# install jq to help with parsing json
RUN curl -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq && \
    chmod +x /usr/local/bin/jq

RUN mkdir -p /src && \
    cd /src && \
    git clone https://github.com/opendatahub-io/odh-manifests && \
    chmod -R 777 /src

ADD https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz /peak/ 
RUN tar -C /usr/bin -xvf /peak/oc.tar.gz && \
    chmod +x /usr/bin/oc

COPY basictests /peak/operator-tests/odh-manifests/basictests
COPY resources /peak/operator-tests/odh-manifests/resources
COPY util /peak/operator-tests/odh-manifests
COPY setup/kfctl_openshift.yaml /kfdef/
COPY setup/operatorsetup /peak/
COPY scripts/install.sh /peak/
COPY scripts/installandtest.sh /peak/

RUN chmod -R 777 /kfdef && \
    mkdir -p /.kube && \
    chmod -R 777 /.kube && \
    chmod -R 777 /peak

# For local testing, you can add your own kubeconfig to the image
# Note:  Do not push the image to a public repo with your kubeconfig
# ADD kubeconfig /root/.kube/config

CMD /peak/installandtest.sh

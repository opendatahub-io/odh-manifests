FROM registry.access.redhat.com/ubi8/ubi:latest

RUN dnf install -y bc git go-toolset && \
    git clone https://github.com/crobby/peak && \    
    cd /peak && \
    git submodule update --init

ADD https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz /peak/ 
ADD https://github.com/kubeflow/kfctl/releases/download/v1.0.2/kfctl_v1.0.2-0-ga476281_linux.tar.gz /peak/
RUN tar -C /usr/bin -xvf /peak/oc.tar.gz && \
    tar -C /usr/bin -xvf /peak/kfctl_v1.0.2-0-ga476281_linux.tar.gz && \
    chmod +x /usr/bin/oc && \
    chmod +x /usr/bin/kfctl

COPY basictests /peak/operator-tests/odh-manifests/tests
COPY util /peak/operator-tests/odh-manifests
COPY resources/kfctl_openshift.yaml /kfdef/
COPY scripts/install.sh /peak/
COPY scripts/installandtest.sh /peak/

# For local testing, you can add your own kubeconfig to the image
# Note:  Do not push the image to a public repo with your kubeconfig
# ADD kubeconfig /root/.kube/config

ENTRYPOINT [ "/peak/installandtest.sh" ]

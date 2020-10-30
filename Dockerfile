from registry.access.redhat.com/ubi8/ubi-minimal:latest

RUN microdnf install -y tar gzip && microdnf clean all && rm -rf /var/cache/yum

COPY . /opt/manifests
RUN cd /opt && \
    tar -czf odh-manifests.tar.gz manifests && \
    rm -rf /opt/manifests

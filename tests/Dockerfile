FROM centos:centos8

ARG CHROMEDRIVER_VER=84.0.4147.30

RUN dnf install -y bc git go-toolset python3-pip unzip && \
    git clone https://github.com/crobby/peak && \    
    cd /peak && \
    git submodule update --init

RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm &&\
    echo -e "[google-chrome]\nname=google-chrome\nbaseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64\nenabled=1\ngpgcheck=1\ngpgkey=https://dl.google.com/linux/linux_signing_key.pub" > /etc/yum.repos.d/google-chrome.repo &&\
    yum -y install "google-chrome-stable-84*" &&\
    yum clean all

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

RUN curl -o /tmp/chromedriver_linux64.zip -L https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VER}/chromedriver_linux64.zip &&\
    unzip /tmp/chromedriver_linux64.zip &&\
    cp chromedriver /usr/local/bin/chromedriver

COPY Pipfile Pipfile.lock /peak

RUN pip3 install micropipenv &&\
    ln -s `which pip3` /usr/bin/pip &&\
    cd /peak &&\
    micropipenv install

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

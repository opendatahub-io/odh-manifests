FROM centos:centos8

ARG CHROMEDRIVER_VER=86.0.4240.22
ARG ORG=opendatahub-io
ARG BRANCH=master

ENV HOME /root
WORKDIR /root

RUN dnf install -y bc git go-toolset python3-pip unzip && \
    git clone https://github.com/crobby/peak $HOME/peak && \    
    cd $HOME/peak && \
    git submodule update --init

RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm &&\
    echo -e "[google-chrome]\nname=google-chrome\nbaseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64\nenabled=1\ngpgcheck=1\ngpgkey=https://dl.google.com/linux/linux_signing_key.pub" > /etc/yum.repos.d/google-chrome.repo &&\
    yum -y install "google-chrome-stable-86*" &&\
    yum clean all

# install jq to help with parsing json
RUN curl -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq && \
    chmod +x /usr/local/bin/jq

RUN mkdir -p $HOME/src && \
    cd $HOME/src && \
    git clone --depth=1 --branch ${BRANCH} https://github.com/${ORG}/odh-manifests && \
    chmod -R 777 $HOME/src

ADD https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz $HOME/peak/ 
RUN tar -C /usr/local/bin -xvf $HOME/peak/oc.tar.gz && \
    chmod +x /usr/local/bin/oc

RUN curl -o /tmp/chromedriver_linux64.zip -L https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VER}/chromedriver_linux64.zip &&\
    unzip /tmp/chromedriver_linux64.zip &&\
    cp chromedriver /usr/local/bin/chromedriver

COPY Pipfile Pipfile.lock $HOME/peak/

RUN pip3 install micropipenv &&\
    ln -s `which pip3` /usr/bin/pip &&\
    cd $HOME/peak &&\
    micropipenv install

COPY setup/operatorsetup scripts/install.sh scripts/installandtest.sh $HOME/peak/
COPY resources $HOME/peak/operator-tests/odh-manifests/resources
COPY util $HOME/peak/operator-tests/odh-manifests
COPY setup/kfctl_openshift.yaml $HOME/kfdef/
COPY basictests $HOME/peak/operator-tests/odh-manifests/basictests

RUN chmod -R 777 $HOME/kfdef && \
    mkdir -p $HOME/.kube && \
    chmod -R 777 $HOME/.kube && \
    chmod -R 777 $HOME/peak && \
    mkdir -p /peak && \
    ln -s $HOME/peak/installandtest.sh /peak/installandtest.sh

# For local testing, you can add your own kubeconfig to the image
# Note:  Do not push the image to a public repo with your kubeconfig
# ADD kubeconfig /root/.kube/config

CMD $HOME/peak/installandtest.sh

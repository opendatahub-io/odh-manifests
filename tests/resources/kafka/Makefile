IMAGE=quay.io/opendatahub-ci/kafka-test:latest
USE_BUILDER=
WITH_BUILDER=docker
ifneq ($(WITH_BUILDER), docker)
USE_BUILDER=--with-builder $(WITH_BUILDER)
endif

all: build push

build:
	s2i $(USE_BUILDER) build ./image/ ubi7/python-36 $(IMAGE)
push:
	podman push $(IMAGE)

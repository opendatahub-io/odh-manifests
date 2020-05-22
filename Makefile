
STRIPPED_VERSION=$(shell echo ${VERSION} | sed 's/v*\(.*\)/\1/' )
MAJOR=$(shell echo ${STRIPPED_VERSION} | sed 's/\..*//' )
MINOR=$(shell echo ${STRIPPED_VERSION} | sed 's/[^.]*\.\([^.]*\)\..*/\1/' )
RELEASE=$(shell echo ${STRIPPED_VERSION} | sed 's/.*\.//' )
BRANCH_NAME=v$(MAJOR).$(MINOR)-branch
TAG_NAME=v$(MAJOR).$(MINOR).$(RELEASE)
REPO_URL="https://github.com/opendatahub-io/odh-manifests"
KFDEF_FILE="kfdef/kfctl_openshift.yaml"
COMMIT_MESSAGE="Update KFdef for release $(TAG_NAME)"
UPDATE_TO_COMMIT=master
ifndef VERSION
$(help)
endif

all: help

prep-release: branch tag
push-release: push-branch push-tag

release: prep-release push-release

help:
	@echo -e "\
	This Makefile allows you to create a new release of odh-manifests\n\
	\n\
	It requires a variable VERSION in format "MAJOR.MINOR.PATCH" (e.g. VERSION=0.6.1) to be set\n\
	\n\
	prep-release\t prepares a version branch (e.g. v0.6-branch) for new release and creates the version tag (e.g. v0.6.1)\n\
	push-release\t push the version branch and tags\n\
	\nPlease refer to RELEASE.md for documentation.\
	"

branch:
	#Create or update a minor branch (e.g. 0.6.2 -> v0.6-branch)
	git branch | grep -w $(BRANCH_NAME) ||\
	( echo " => Creating branch $(BRANCH_NAME)" &&\
	  git checkout master &&\
	  git pull &&\
	  git checkout -b $(BRANCH_NAME) $(UPDATE_TO_COMMIT)) &&\
	( echo " => Branch $(BRANCH_NAME) exists, rebasing" &&\
	  git checkout $(BRANCH_NAME) &&\
	  git rebase $(UPDATE_TO_COMMIT) )
update-kfdef-with-tag:
	git checkout $(BRANCH_NAME)
	sed -i "s#$(REPO_URL).*#$(REPO_URL)/tarball/$(TAG_NAME)#" $(KFDEF_FILE)
	git add $(KFDEF_FILE)
	git commit -m $(COMMIT_MESSAGE)
push-branch:
	git push --set-upstream origin $(BRANCH_NAME)
tag: update-kfdef-with-tag
	echo " => Created tag $(TAG_NAME)"
	git tag $(TAG_NAME)
push-tag:
	git push --tags

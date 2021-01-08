# Open Data Hub Release Policy 

* Status: proposed
* Deciders: vpavlin 
* Date: 2020-Nov-03 

Technical Story: As an Open Source project, we want to document the policies and guideline on how we create a new
release.

## Context and Problem Statement

The Open Data Hub itself consists of many components all having their own release cycles. ODH users might decide to
update individual components such as container images used by JupyterHub. Nevertheless it is required to create
releases of ODH as a whole.

## Considered Options

* do a monolithic, coordinated release of all components of ODH by creating a tag within the odh-manifests repository
* have a rolling release, and no tags on odh-manifests repository 

## Decision Outcome

Chosen option: we do a monolithic, coordinated release, because it will enable us to have a release at the
project/product level while maintianing freedom of others to update.

### Positive Consequences <!-- optional -->

* Operators of ODH have a clear base line of versions, these versions have been tested with each other and have
  undergone ODH integration testing.
* Operators of ODH can update individual components, they could maintain a repository analog to odh-manifests declaring
  the exact versions (container image tags, git repository tags) of components they want to deploy.
* Operators can mix in their builds of container images following the method mentioned above.

### Negative Consequences <!-- optional -->

* An ODH release (a tag in the odh-manifests repository) might not contain the latest versions of components, for example
  security updates might have forced the build of a S2I image used with JupyterHub component of ODH.

<!-- markdownlint-disable-file MD013 -->

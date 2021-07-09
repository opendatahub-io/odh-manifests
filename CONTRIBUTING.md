# Contributing to Open Data Hub Manifests
Thank you for your interest in contributing to the Open Data Hub manifests.

Below are guidelines for contributing to this project and adding new components to the Open Data Hub.

## Reporting Bugs & Requesting Features/Enhancement

We use Github Issues to track bug reports and feature requests.

When submitting a bug report, please be as detailed as possible. Include as much of these items as you have:

1. Steps to reproduce the bug
1. The KfDef you used to deploy Open Data Hub
1. Error messages with stacktraces and any relevant logs
1. Environment details including
   * Open Data Hub Operator version
   * Open Shift Version
   * Cloud Provider

When submitting a feature request, please submit them in the form of a user story with acceptance criteria:

* Describe the current functionality
* Describe the feature or enhancement and why you think this would be a better solution

## Proposing New Components

Any components being proposed for addition to the Open Data Hub, should be well documented and presented during the Open Data Hub [community meeting](https://gitlab.com/opendatahub/opendatahub-community). At this time, community members will ask questions to discuss the feature set and how it benefits the goals of the Open Data Hub.

## Component Requirements

### Documentation

All components must have a README that provides
* Description of the major components to include all relevant applications & libraries
* Links to official homepages, repos and documentation for the component
* Any relevant use cases that this component fulfills
* Description of all overlays included in the component
* Listing & short description of all major parameters available to the user

### Requirements
* Component does not have any namespace name hardcoded. If explicit namespace is needed, it is configured via $(namespace) parameter
  * Exceptions: some components might require to be deployed to a special namespace (e.g. Istio - istio-system), justificaton needs to be provided
* If there are metrics exposed by the component, a Prometheus ServiceMonitor must be added

### Testing
#### Smoke Test
  * Test verifying all the pods/services are available after deployment is provided

#### Functionality Test
* Test verifying the component actually works after deployment is provided

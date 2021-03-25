
## Release 1.0.1 (2021-02-18T21:17:04)
### Features
* issue template for release via bots (#322)
* include thoth configuration file for kebechet (#323)
* Change ODH dashboard type to ClusterIP (#321)
* upgrade s2i notebook images for jupyterhub (#304)
* Update README.md (#307)
* Owners List Updates (#306)
* Update grafana to version 3.8.1 (#301)
* Update peak operator file to include odh-manifests repo url (#299)
* Adding changes to kfdef (#298)
* Updated jupyterhub imagestream image to 0.1.5 (#296)
### Bug Fixes
* Update JH image to v0.2.0 to fix cert issues and support groups (#312)
### Improvements
* Simplify test for dashboard pods, hopefully eliminating flake (#305)
* Use airflowui secure route for tests (#300)

## Release 1.0.2 (2021-02-25T14:39:50)
### Features
* Adding optional var SKIP_KFDEF_INSTALL to allow for cases where the KfDef to be tested is created outside of the tests (#331)
### Improvements
* Changing Superset deployment to recreate strategy (#317)
* set imagestream name same as the tag version (#325)

## Release 1.0.3 (2021-03-04T14:16:04)
### Features
* [JupyterHub] Fix auth for prometheus /metrics endpoint behind auth proxy (#330)
* Remove tls-acme annotation from JuptyerHub route (#329)

## Release 1.0.4 (2021-03-11T14:20:52)
### Features
* Update Jupyterhub image to v0.2.2 (#345)
* Add JH groups configuration CM (#342)
* Update JH image with prometheus authentication (#339)

## Release 1.0.5 (2021-03-18T13:20:58)
### Features
* Add env vars to JH so that we don't lose auth_state on restart (#351)
* Update Elyra image to v2.0.1 (#297)
* Added ImageChange trigger to the JupyterHub deployment config (#334)
* Remove empty operator log artifact from tests runs (#348)

## Release 1.0.6 (2021-03-25T13:11:07)
### Features
* Update Metrics endpoints for ODH operator (#349)
* Move the JH DeploymentConfig imageChange trigger to an overlay (#360)
* Update README.md (#354)
* Add oauth proxy to ODH dashboard (#350)

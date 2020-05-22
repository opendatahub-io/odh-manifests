# Releasing ODH Manifests

The versioning scheme follows the schemantic versioning (i.e. MAJOR.MINOR.PATCH).

We offer branches based on `MAJOR.MINOR` (e.g. `v0.6-branch`) and tags based on `MAJOR.MINOR.PATCH` (e.g. `v0.6.1`).

## Creating a new MAJOR or MINOR release

To create a new release (tag) and branch you can use the `make` command:

```
make prep-release VERSION=0.7.0
```

This will result in the branch `v0.7-branch` to be created and a tag `v0.7.0` created. A manifests repository in the file [kfdef/kfctl_openshift.yaml](kfdef/kfctl_openshift.yaml) will also be updated to point to the newly created tag.

If you are happy with the result, you can push the branch and the tag to the repository

```
make push-release VERSION=0.7.0
```

## Creating a new PATCH release

The `PATCH` release is special because it does not result in the new branch created. If the new `PATCH` release is from the top of the `master` branch, the workflow is the same as for `MAJOR` and `MINOR` releases.

In case the `PATCH` release is not directly from the `master` branch (e.g. updating a security issue in an older version), you need to cherry-pick the commits to the release branch (e.g. `v0.5-branch`) and run the following command only to crete the release:

```
make tag VERSION=0.5.3
make push-tag VERSION=0.5.3
```

# Creating a new release from a specific commit

In case you need to use a specific commit below the top of the `master` (and all commits between it and the previous release), you can use the following command:

```
make prep-release VERSION=0.7.1 UPDATE_TO_COMMIT=<commit-id-below-top-of-master>
make push-release VERSION=0.7.1
```

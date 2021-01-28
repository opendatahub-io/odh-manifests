# ODH Argo guide for maintainers

## Updating the component manifests

Steps for semi-automated manifests update of Argo manifests in this repo:

1. Execute the [`gen_argo_manifests.sh`](gen_argo_manifests.sh) script within this folder, which results in:
   - Latest manifests are fetched
   - `README` version banner updated
2. Commit

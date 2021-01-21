#!/bin/bash
set -eu -o pipefail

echo -n ".. Fetching latest version"
version=$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/argoproj/argo/releases/latest))
old_version=$(grep -oP '(?<=<!-- ).*(?= -->)' README.md)
echo -e "\r ✓"
echo "     Latest release: $version"

echo -n ".. Temporarily cloning the upstream repo"
tmp_dir=$(mktemp -d)
git clone -c advice.detachedHead=false --quiet --depth 1 --branch $version https://github.com/argoproj/argo.git $tmp_dir > /dev/null
echo -e "\r ✓"

echo -n ".. Building CRDs"
kustomize build "$tmp_dir/manifests/base/crds" > cluster/base/crds.yaml
echo -e "\r ✓"

echo -n ".. Copying ClusterRoles"
cp "$tmp_dir/manifests/cluster-install/workflow-controller-rbac/workflow-aggregate-roles.yaml" cluster/base/cluster-roles.yaml
echo -e "\r ✓"

echo -n ".. Building namespaced resources"
sed -i '/.*crds/d' "$tmp_dir/manifests/base/kustomization.yaml"
kustomize build "$tmp_dir/manifests/namespace-install" > odhargo/base/namespace-install.yaml
echo -e "\r ✓"

echo -n ".. Update image tags in kustomization.yaml"
sed -i "s/$old_version/$version/g" odhargo/base/kustomization.yaml
echo -e "\r ✓"

echo ".. Ensure the result is buildable"
for folder in cluster/base odhargo/base; do
    echo -n "  .. [$folder]"
    kustomize build $folder > /dev/null && echo -e "\r   ✓"
done

echo -n ".. Removing the temporary clone"
rm -rf $tmp_dir
echo -e "\r ✓ "

echo -n ".. Updating README version"
sed -i "s/$old_version/$version/g" README.md
echo -e "\r ✓ "

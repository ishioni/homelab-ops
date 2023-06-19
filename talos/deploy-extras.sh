#!/bin/bash

pushd extras >/dev/null 2>&1

if test -d cni/charts; then
  rm -rf cni/charts
fi
envsubst < ../../kubernetes/apps/kube-system/cillium/app/cillium-values.yaml  > cni/values.yaml
kustomize build --enable-helm cni | kubectl apply -f -
rm -r cni/values.yaml cni/charts

if test -d csr-approver/charts; then
  rm -rf csr-approver/charts
fi
envsubst < ../../kubernetes/apps/kube-system/kubelet-csr-approver/app/values.yaml > csr-approver/values.yaml
kustomize build --enable-helm csr-approver | kubectl apply -f -
rm -r csr-approver/values.yaml csr-approver/charts
popd >/dev/null 2>&1

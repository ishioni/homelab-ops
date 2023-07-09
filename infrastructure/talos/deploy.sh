#!/bin/bash

if ! [ -f talconfig.yaml ]; then
    echo "Missing talconfig.yaml!"
    exit 1
fi

if ! [ -f talenv.yaml ]; then
    echo "Missing talenv.sops.yaml!"
    exit 1
fi

if ! [ -f talsecret.sops.yaml ]; then
    talhelper gensecret > talsecret.sops.yaml
    sops --encrypt --in-place talenv.sops.yaml
fi

if ! [ -f clusterconfig/talosconfig ]; then
    talhelper genconfig -e talenv.yaml -s talsecret.sops.yaml -c talconfig.yaml
fi

echo "Applying talos configs"

talosctl config merge ./clusterconfig/talosconfig

# Deploy the configuration to the nodes
talosctl apply-config -i -n 10.1.4.20 -f ./clusterconfig/talos-talos-master-0*.yaml
talosctl apply-config -i -n 10.1.4.21 -f ./clusterconfig/talos-talos-master-1*.yaml
talosctl apply-config -i -n 10.1.4.22 -f ./clusterconfig/talos-talos-master-2*.yaml
talosctl apply-config -i -n 10.1.4.30 -f ./clusterconfig/talos-talos-worker-0*.yaml
talosctl apply-config -i -n 10.1.4.31 -f ./clusterconfig/talos-talos-worker-1*.yaml
talosctl apply-config -i -n 10.1.4.32 -f ./clusterconfig/talos-talos-worker-2*.yaml

echo "Waiting for installation"
sleep 120

talosctl config node talos-master-0.k3s.internal talos-master-1.k3s.internal talos-master-2.k3s.internal\
                    talos-worker-0.k3s.internal talos-worker-1.k3s.internal talos-worker-2.k3s.internal;
talosctl config endpoint talos-master-0.k3s.internal talos-master-1.k3s.internal talos-master-2.k3s.internal talos-api.k3s.internal

echo Running bootstrap..
talosctl bootstrap -n talos-master-0.k3s.internal
sleep 180

talosctl kubeconfig -n talos-api.k3s.internal

kubectl certificate approve $(kubectl get csr --sort-by=.metadata.creationTimestamp | grep Pending | awk '{print $1}')

echo kubectl get no
kubectl get no

#!/bin/bash

# Deploy the configuration to the nodes
talosctl apply-config -n 10.1.4.20 -f ./clusterconfig/talos-talos-master-0*.yaml
talosctl apply-config -n 10.1.4.21 -f ./clusterconfig/talos-talos-master-1*.yaml
talosctl apply-config -n 10.1.4.22 -f ./clusterconfig/talos-talos-master-2*.yaml

talosctl apply-config -n 10.1.4.30 -f ./clusterconfig/talos-talos-worker-0*.yaml
talosctl apply-config -n 10.1.4.31 -f ./clusterconfig/talos-talos-worker-1*.yaml
talosctl apply-config -n 10.1.4.32 -f ./clusterconfig/talos-talos-worker-2*.yaml

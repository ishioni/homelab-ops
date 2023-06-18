# Upgrading Talos

Determine which CP node is running the VIP port.

```shell
talosctl get addresses | grep 10.1.4.100
```

Upgrade the other two CP nodes first with:

```shell
talosctl upgrade --image ghcr.io/siderolabs/installer:v1.3.4 -n talos-master-1.k3s.internal talos-master-2.k3s.internal
```

Upgrade the CP node running the VIP port.

Then upgrade the workers

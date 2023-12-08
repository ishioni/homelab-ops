# Truenas setup
This is all based on the presupposition you have an "enterprise" version ;)

### Disable spyware
Settings -> General -> Usage collection = off

### Set kernel arguments
``````sh
midclt call system.advanced.update '{ "kernel_extra_options": "youargs" }'
``````

### Enable passthrough mode
```sh
midclt call kubernetes.update '{"passthrough_mode": true}'
midclt call kubernetes.config
```
This should return with passthrough_mode: true

### Setup "apps"
Disable:
  - Enable Container Image Updates
  - Enable Integrated Loadbalancer

Steal the /etc/rancher/k3s/k3s.yaml, change the names and the k3s endpoint

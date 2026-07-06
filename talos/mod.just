set default-list
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

talos_dir := justfile_directory() + '/talos'
secret_id := 'talos'

[doc('Generate talosconfig for the cluster')]
[script]
generate-talosconfig:
  op read op://homelab/talos/MACHINE_CA_CRT | base64 -d > ca.crt
  op read op://homelab/talos/MACHINE_CA_KEY | base64 -d > ca.key
  talosctl gen key --name admin
  talosctl gen csr --key admin.key --ip 127.0.0.1
  talosctl gen crt --ca ca --csr admin.csr --name admin --hours 87600
  op item edit --vault homelab {{ secret_id }} "Admin.ADMIN_CRT[password]=$(cat admin.crt | base64 -w 0)" > /dev/null
  op item edit --vault homelab {{ secret_id }} "Admin.ADMIN_KEY[password]=$(cat admin.key | base64 -w 0)" > /dev/null
  rm ca.crt ca.key admin.crt admin.csr admin.key
  just template "{{ talos_dir }}/talosconfig.j2" > talosconfig
  mv talosconfig $TALOSCONFIG

[doc('Apply Talos config to a node')]
[script]
apply-node node *args:
    just talos render-config "{{ node }}" | talosctl -n "{{ node }}" apply-config -f /dev/stdin {{ args }}

[doc('Download Talos machine image')]
[script]
download-image version:
    export SCHEMATIC="$(just talos schematic-id)"
    curl -fL --remove-on-error --retry 5 --retry-delay 5 --retry-all-errors --progress-bar \
        -o "{{ talos_dir }}/talos-{{ version }}-${SCHEMATIC:0:8}.iso" \
        "https://factory.talos.dev/image/${SCHEMATIC}/{{ version }}/metal-amd64-secureboot.iso"
    just log info "Downloaded Talos" version "{{ version }}" schematic "${SCHEMATIC}"

[doc('Reboot a node')]
[script]
reboot-node node:
    gum confirm "Reboot node {{ node }}?" --default="No" &&
        talosctl -n {{ node }} reboot -m powercycle || exit 0

[doc('Render Talos config for a node')]
[script]
render-config node:
    export IS_CONTROLLER="$(just talos machine-controller {{ node }})";
    export SCHEMATIC="$(just talos schematic-id)"
    talosctl machineconfig patch <(just template "{{ talos_dir }}/machineconfig.yaml.j2") -p @<(just template "{{ talos_dir }}/nodes/{{ node }}.yaml.j2")

[doc('Reset a node')]
[script]
reset-node node *args:
    gum confirm "Reset node {{ node }}?" --default="No" &&
        talosctl -n "{{ node }}" reset --system-labels-to-wipe STATE --system-labels-to-wipe EPHEMERAL --system-labels-to-wipe u-local --graceful=false {{ args }} || exit 0

[doc('Shutdown a node')]
[script]
shutdown-node node *args:
    gum confirm "Shutdown node {{ node }}?" --default="No" &&
        talosctl -n "{{ node }}" shutdown --force {{ args }} || exit 0

[doc('Upgrade Kubernetes version on the cluster')]
[script]
upgrade-k8s version:
    talosctl -n "$(talosctl config info -o yaml | yq -e '.endpoints[0]')" upgrade-k8s --to {{ version }}

[doc('Upgrade Talos version on a node')]
[script]
upgrade-node node *args:
    talosctl -n "{{ node }}" upgrade -i "$(just talos machine-image)" -m powercycle --timeout=10m {{ args }}

[private]
schematic-id:
    curl -sX POST --data-binary @<(just template "{{ source_directory() }}/schematic.yaml.j2") "https://factory.talos.dev/schematics" | jq -r '.id'

[private]
[script]
machine-controller node:
    just template "{{ talos_dir }}/nodes/{{ node }}.yaml.j2" | yq -e 'select(.machine) | (.machine.type == "controlplane") // ""'

[private]
[script]
machine-image:
    export SCHEMATIC="$(just talos schematic-id)"
    just template "{{ talos_dir }}/machineconfig.yaml.j2" | yq -e 'select(.machine) | .machine.install.image'

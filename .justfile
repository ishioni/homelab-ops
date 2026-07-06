#!/usr/bin/env -S just --justfile

set default-list
set lazy
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

[group: 'bootstrap']
mod bootstrap "bootstrap"

[group: 'k8s']
mod kube "kubernetes"

[group: 'talos']
mod talos "talos"

[private]
[script]
log lvl msg *args:
    gum log -t rfc3339 -s -l "{{ lvl }}" "{{ msg }}" {{ args }}

[private]
[script]
template file *args:
    minijinja-cli "{{ file }}" {{ args }} | op inject

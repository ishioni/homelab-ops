#!/usr/bin/env -S just --justfile

set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

mod bootstrap "bootstrap"
mod kube "kubernetes"
mod talos "talos"

root_dir := justfile_directory()

[private]
default:
    just -l

[private]
log lvl msg *args:
    gum log -t rfc3339 -s -l "{{ lvl }}" "{{ msg }}" {{ args }}

[private]
template file *args:
    minijinja-cli "{{ file }}" {{ args }} | op inject

# Format all files
format-all: format-markdown format-yaml format-tofu

# Format Markdown files
format-markdown:
    -prettier \
        --config '{{ root_dir }}/.ci/prettier/.prettierrc.yaml' \
        --list-different \
        --ignore-unknown \
        --parser=markdown \
        --write '*.md' \
        '{{ root_dir }}/**/*.md'

# Format YAML files
format-yaml:
    -prettier \
        --config '{{ root_dir }}/.ci/prettier/.prettierrc.yaml' \
        --list-different \
        --ignore-unknown \
        --parser=yaml \
        --write '*.y*ml' \
        '{{ root_dir }}/**/*.y*ml'

# Format Terraform files
format-tofu:
    -tofu fmt -recursive {{ root_dir }}

# Initialize pre-commit hooks
precommit-init:
    pre-commit install --install-hooks

# Run pre-commit on all files
precommit-run:
    pre-commit run --all-files

# Update pre-commit hooks
precommit-update:
    pre-commit autoupdate

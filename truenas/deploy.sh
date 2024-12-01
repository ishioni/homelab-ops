#!/bin/bash
source .envrc
SEARCH_DIR=${1:-.}

if ! command -v sops &> /dev/null; then
    echo "Error: sops is not installed or not in PATH"
    exit 1
fi

if ! test -f $SOPS_AGE_KEY_FILE &> /dev/null; then
    echo "Error: missing age key file at $SOPS_AGE_KEY_FILE"
    exit 1
fi

# Find all docker-compose.yml files and process them
find "$SEARCH_DIR" -type f -name "docker-compose.yml" | sort | while read -r compose_file; do
    # Get the directory containing the docker-compose.yml file
    compose_dir=$(dirname "$compose_file")

    echo "Processing directory: $compose_dir"

    # Check for *.sops.env files in the directory
    sops_env_files=("$compose_dir"/*.sops.env)
    if compgen -G "$compose_dir/*.sops.env" > /dev/null; then
        for sops_env_file in "${sops_env_files[@]}"; do
            env_file="${sops_env_file%.sops.env}.env"
            echo "Decrypting $sops_env_file to $env_file..."
            if sops -d "$sops_env_file" > "$env_file"; then
                echo "Decrypted $sops_env_file to $env_file."
            else
                echo "Failed to decrypt $sops_env_file." >&2
                exit 1
            fi
        done
    else
        echo "No *.sops.env files found in $compose_dir."
    fi

    echo "Running 'docker compose up' in $compose_dir..."
    (cd "$compose_dir" && docker compose up -d)
    if [ $? -eq 0 ]; then
        echo "Successfully executed 'docker compose up' in $compose_dir."
    else
        echo "Failed to execute 'docker compose up' in $compose_dir." >&2
    fi
done

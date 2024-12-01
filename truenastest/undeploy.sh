#!/bin/bash
source .envrc
SEARCH_DIR=${1:-.}

# Find all docker-compose.yml files and process them
find "$SEARCH_DIR" -type f -name "docker-compose.yml" | sort -r | while read -r compose_file; do
    # Get the directory containing the docker-compose.yml file
    compose_dir=$(dirname "$compose_file")

    echo "Running 'docker compose down' in $compose_dir..."
    (cd "$compose_dir" && docker compose down)
    if [ $? -eq 0 ]; then
        echo "Successfully executed 'docker compose down' in $compose_dir."
    else
        echo "Failed to execute 'docker compose down' in $compose_dir." >&2
    fi
done

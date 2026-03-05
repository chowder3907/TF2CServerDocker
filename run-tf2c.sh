#!/bin/bash

# File that acts as your trigger
TF2_DEPOT=$(curl -s https://api.steamcmd.net/v1/info/232250 | jq '.data["232250"].depots.branches.public.buildid')
# File storing the last trigger value
LAST_TF2_DEPOT="./last_tf2_depot"

# Check that the trigger file exists
if [[ ! -f "./last_tf2_depot" ]]; then
    echo $TF2_DEPOT > "./last_tf2_depot"
    exit 1
fi

# Read current and last trigger values
if [[ -f "./last_tf2_depot" ]]; then
    LAST_TF2_DEPOT=$(cat "./last_tf2_depot")
else
    LAST_TF2_DEPOT=""
fi

# Compare and decide
if [[ "$TF2_DEPOT" != "$LAST_TF2_DEPOT" ]]; then
    echo "Trigger changed! Rebuilding Docker image..."

    # Save current trigger value
    echo "$TF2_DEPOT" > "$LAST_TF2_DEPOT"

    # Rebuild Docker image from scratch
    docker-compose build --no-cache

    # Start container
    docker-compose up
else
    echo "Trigger unchanged. Skipping rebuild, just restarting container..."
    docker-compose up
fi

#!/bin/bash
#PS4='+${LINENO}: '
#set -x # enable these 2 lines for debugging
#Check depot build numbers
TF2_DEPOT=$(curl -s https://api.steamcmd.net/v1/info/232250 | jq '.data["232250"].depots.branches.public.buildid')
TF2C_DEPOT=$(curl -s https://api.steamcmd.net/v1/info/3557020 | jq '.data["3557020"].depots.branches.public.buildid')
#Store depot build numbers for future reference
LAST_TF2_DEPOT="./last_tf2_depot"
LAST_TF2C_DEPOT="./last_tf2c_depot"

# Check that depot files exist, make them if not
if [[ ! -f "./last_tf2_depot" ]]; then
    echo $TF2_DEPOT > "./last_tf2_depot"
fi

if [[ ! -f "./last_tf2c_depot" ]]; then
    echo $TF2_DEPOT > "./last_tf2c_depot"
fi

# Read current and last trigger values
if [[ -f "./last_tf2_depot" ]]; then
    LAST_TF2_DEPOT=$(cat "./last_tf2_depot")
else
    LAST_TF2_DEPOT=""
fi

if [[ -f "./last_tf2c_depot" ]]; then
    LAST_TF2C_DEPOT=$(cat "./last_tf2c_depot")
else
    LAST_TF2C_DEPOT=""
fi
# Compare and decide
if [[ "$TF2_DEPOT" != "$LAST_TF2_DEPOT" ]] || [[ "$TF2C_DEPOT" != "$LAST_TF2C_DEPOT" ]] ; then
    echo "Depot changed! Rebuilding Docker image..."

    # Save current trigger value
    echo "$TF2_DEPOT" > "./last_tf2_depot"
    echo "$TF2C_DEPOT" > "./last_tf2c_depot"
    # Rebuild Docker image from scratch
    docker-compose build --no-cache

    # Start container
    docker-compose up -d
else
    echo "Depot unchanged. Skipping rebuild, just restarting container..."
    docker-compose up -d
fi

docker builder prune -f

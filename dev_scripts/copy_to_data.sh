#!/bin/bash

# Copy changed scripts and assets to Stratagus data directory without requiring a full build
# This script uses the current user's home directory to find the data path

set -e  # Exit on error

DATA_DIR="$HOME/Library/Application Support/Stratagus/data.War1gus"

# Get the script's directory to find the project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Verify the data directory exists
if [ ! -d "$DATA_DIR" ]; then
    echo "Error: Data directory not found at: $DATA_DIR"
    exit 1
fi

echo "Copying changed files to: $DATA_DIR"

# Copy scripts directory
if [ -d "$PROJECT_ROOT/scripts" ]; then
    echo "Copying scripts..."
    rsync -av --delete "$PROJECT_ROOT/scripts/" "$DATA_DIR/scripts/"
else
    echo "Warning: scripts directory not found"
fi

# Copy campaigns directory
if [ -d "$PROJECT_ROOT/campaigns" ]; then
    echo "Copying campaigns..."
    rsync -av --delete "$PROJECT_ROOT/campaigns/" "$DATA_DIR/campaigns/"
else
    echo "Warning: campaigns directory not found"
fi

# Copy contrib directory
if [ -d "$PROJECT_ROOT/contrib" ]; then
    echo "Copying contrib..."
    rsync -av --delete "$PROJECT_ROOT/contrib/" "$DATA_DIR/contrib/"
else
    echo "Warning: contrib directory not found"
fi

# Copy shaders directory
if [ -d "$PROJECT_ROOT/shaders" ]; then
    echo "Copying shaders..."
    rsync -av --delete "$PROJECT_ROOT/shaders/" "$DATA_DIR/shaders/"
else
    echo "Warning: shaders directory not found"
fi

# Copy maps directory
if [ -d "$PROJECT_ROOT/maps" ]; then
    echo "Copying maps..."
    rsync -av --delete "$PROJECT_ROOT/maps/" "$DATA_DIR/maps/"
else
    echo "Warning: maps directory not found"
fi

echo "Done! Files copied to $DATA_DIR"

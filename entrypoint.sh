#!/bin/bash
set -euo pipefail

if [[ -f $INIT_SCRIPT ]]; then
    echo "Running init script: ${INIT_SCRIPT}"
    source "$INIT_SCRIPT"
fi

echo "Checking repository: ${RESTIC_REPOSITORY}"
if restic cat config > /dev/null; then
    echo "Found repository"
else
    echo "Initializing repository: ${RESTIC_REPOSITORY}"
    if restic init; then
        echo "Initialized repository"
    else
        echo "Failed to initialize repository"
        exit 1
    fi
fi

exec "$@"
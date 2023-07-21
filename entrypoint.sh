#!/bin/bash

if [[ -f $INIT_SCRIPT ]]; then
    echo "Running init script: ${INIT_SCRIPT}"
    source "$INIT_SCRIPT"
fi

echo "Running Restic: $(date)"
exec "$@"
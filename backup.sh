#!/bin/bash
set -euo pipefail

start=$(date +%s)
echo "Starting backup: ${RESTIC_BACKUP_SOURCE} to ${RESTIC_REPOSITORY} $(date +"%Y-%m-%d %H:%M:%S")"

set +e
restic backup ${RESTIC_BACKUP_ARGS:-""} "${RESTIC_BACKUP_SOURCE}"
backupRC=$?
set -e

if [[ $backupRC == 0 ]]; then
    echo "Backup successful"
else
    echo "Backup failed with status: ${backupRC}"
    restic unlock
fi

if [[ $backupRC == 0 ]] && [ -n "${RESTIC_FORGET_ARGS}" ]; then
    echo "Forgetting old snapshots with: ${RESTIC_FORGET_ARGS}"
    if restic forget ${RESTIC_FORGET_ARGS}; then
        echo "Forget successful"
    else
        echo "Forget failed"
        restic unlock
    fi
fi

end=$(date +%s)
echo "Finished backup at: $(date +"%Y-%m-%d %H:%M:%S") in $((end-start)) seconds."

exit $backupRC
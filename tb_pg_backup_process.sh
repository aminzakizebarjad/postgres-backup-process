#!/bin/bash

bash_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$bash_dir/pg_backup_process.sh"

get_tb_version() {
    all_pars=""
    tb_dir=""

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --tb_dir)
                tb_dir="$2"
                shift 2
                ;;
            *)
                all_pars="$all_pars $1"
                shift
                ;;
        esac
    done

    # Debug log for all parameters
    echo "[DEBUG] All parameters: $all_pars"

    # Check if tb_dir was provided
    if [[ -z "$tb_dir" ]]; then
        echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - must include --tb_dir [directory where ThingsBoard is cloned] in parameters"
        return 1
    fi

    # Check if .env file exists before sourcing
    if [[ -f "$tb_dir/thingsboard/docker/.env" ]]; then
        source "$tb_dir/thingsboard/docker/.env"
        tb_version="$TB_VERSION"
        echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - Current ThingsBoard version is $tb_version"
    else
        echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - Failed to find ThingsBoard .env file at $tb_dir/thingsboard/docker/.env" >&2
        return 1
    fi

    # Export version and parameters for use outside
    export tb_version
    export all_pars
}

# --- MAIN EXECUTION ---
if get_tb_version "$@"; then
    backup_main $all_pars --db_name "thingsboard" --bu_name "$(hostname)_TB_V_${tb_version}"
else
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - get_tb_version failed. Backup aborted."
    exit 1
fi

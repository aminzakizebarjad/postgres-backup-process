bash_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$bash_dir/pg_backup_process.sh"

backup_main "$@"

#!/bin/bash

get_params(){
        while [[ "$#" -gt 0 ]]; do
            case $1 in
                --db_dir)         db_dir="$2";        shift;;
		--db_name)        db_name="$2";       shift;;
		--bu_name)        bu_name="$2";       shift;;
		--bu_user)        bu_user="$2";       shift;;
                --bu_ip)          bu_ip="$2";         shift;;
                --bu_dir)         bu_dir="$2";        shift;;
                --bu_key)         bu_key="$2";        shift;;
		--container_name) container_name="$2";shift;;
                *) echo "Unknown parameter: $1" ;;
            esac
            shift
        done

        if [ -z "$db_dir" ]||[ -z "$bu_ip" ]||[ -z "$bu_dir" ]||[ -z "$bu_key" ]||[ -z "$container_name" ]||\
	[ -z "$bu_user" ]||[ -z "$bu_name" ]||[ -z "$db_name" ]; then
            echo -e "\
		\n [ERROR] $(date '+%Y-%m-%d %H:%M:%S') \
		\n ---------------------------------\
		\n USAGE: \
		\n ---------------------------------\
		\n pg_backup_process.sh --db_dir [directrory of where postgresql database saves data] --db_name [database name which is being backed up] --container_name [name of docker container that runs postgres inside] --bu_name [the prefix of backup file name] --bu_user [the user on backup server] --bu_ip [backup server ip address] --bu_dir [where in backup server the backup resides] --bu_key [the ssh key to connect to backup server]" >&2

            echo -e "\n --------------------------------- \n TAKEN PARAMS : \n --------------------------------- \n tb_dir->$tb_dir \n container_name-> $container_name \n db_dir->$db_dir \n db_name->$db_name \n bu_name->$bu_name \n bu_user->$bu_user \n bu_ip->$bu_ip \n bu_dir->$bu_dir  \n bu_key->$bu_key \n ----------------------------------- \n " >&2
            return 1
        else
                bash_dir="$(dirname ${BASH_SOURCE[0]})"
            echo -e "\
                \n --------------------------------------------------------
                \r [INFO] - $(date '+%Y-%m-%d %H:%M:%S')
                \r -------------------------------------------------------
                \r bash crone directory at $bash_dir \n \
                \n --------------------------------------------------------
                \r HOST SERVER INFO:\
                \n --------------------------------------------------------
		\r postgres container name is $container_name \
                \n postgress saves in $db_dir \n \
		\n database name $db_name \n \
		\n backup file prefix in $bu_name \n \
                \n --------------------------------------------------------
                \r BACKUP SERVER INFO: \
                \n --------------------------------------------------------
                \r backup server ip is $bu_ip \
		\n backup user is $bu_user \
                \n save in backup sarver at $bu_dir \
                \n the ssh key is at $bu_key \n "
            return 0
        fi
}


create_backup() {

 # define the file name of backup
 backup_file_name=$(echo $bu_name)_PG_BU_DATE_$(date +%Y-%m-%d_%H-%M-%S).sql
 back_up_directory_in_container=/var/lib/postgresql/data

 # docker create backup
 echo -e "\
 	\n [INFO] $(date '+%Y-%m-%d %H:%M:%S') \
	\n --------------------------------- \
	\n creating postgres backup \
	\n --------------------------------- \r"
 if \
 docker exec -u postgres $2 pg_dump -U postgres -h localhost -p 5432 -f $back_up_directory_in_container/$backup_file_name\
 thingsboard; then

 	echo " [INFO] $(date '+%Y-%m-%d %H:%M:%S') - done creating postgresql backup with name $backup_file_name"
	return 0
 else
	echo " [ERROR] $(date '+%Y-%m-%d %H:%M:%S') - Failed to create backup" >&2
	return 1
 fi
}


remove_previous_backup() {

	echo -e "\
        \n [INFO] $(date '+%Y-%m-%d %H:%M:%S') \
        \n --------------------------------- \
        \n clearing previous backups \
        \n --------------------------------- \r"


	SEARCH_DIR=$1

	# Find all matching backup files
	files=($(find "$SEARCH_DIR" -type f -name "$(echo $bu_name)_PG_BU_DATE_*.sql"))

	# Exit if no files found
	if [ ${#files[@]} -eq 0 ]; then
		echo " [ERROR] $(date '+%Y-%m-%d %H:%M:%S') - No backup files found." >&2
		return 1
	fi

	# Sort files lexicographically
	sorted=($(printf '%s\n' "${files[@]}" | sort))
	newest="${sorted[-1]}"

	echo " [INFO]  $(date '+%Y-%m-%d %H:%M:%S') - Newest backup: $newest"
	echo " [INFO]  $(date '+%Y-%m-%d %H:%M:%S') - Removing older backups..."

	for f in "${sorted[@]}"; do
		if [[ "$f" != "$newest" ]]; then
			if rm -f "$f"; then
				echo " [INFO]  $(date '+%Y-%m-%d %H:%M:%S') - Deleted: $f"
			else
				echo " [ERROR] $(date '+%Y-%m-%d %H:%M:%S') - Failed to delete: $f" >&2
			fi
		fi
	done

	echo " [INFO]  $(date '+%Y-%m-%d %H:%M:%S') - Cleanup complete."
	echo " --------------------------------------------"


}

transfer_to_bu_server(){

        echo -e "\
        \n [INFO] $(date '+%Y-%m-%d %H:%M:%S') \
        \n --------------------------------- \
        \n transfering to backup server \
        \n --------------------------------- \r"

	SEARCH_DIR=$1

        # Find all matching backup files
        files=($(find "$SEARCH_DIR" -type f -name "$(echo $bu_name)_PG_BU_DATE_*.sql"))

        # Exit if no files found
        if [ ${#files[@]} -eq 0 ]; then
                echo " [ERROR] $(date '+%Y-%m-%d %H:%M:%S') - No backup to transfer." >&2
                return 1
        fi

        # Sort files lexicographically
        sorted=($(printf '%s\n' "${files[@]}" | sort))
        newest="${sorted[-1]}"

	if\
		scp -i $2  $newest $3@$4:$5/; then
		echo " [INFO]  $(date '+%Y-%m-%d %H:%M:%S') - Transfering $newest complete"
        else
                echo " [ERROR] $(date '+%Y-%m-%d %H:%M:%S') - Failed to transfer" >&2
        fi

}

backup_main(){

	if get_params "$@"; then
		create_backup "$tb_dir" "$container_name"
		remove_previous_backup "$db_dir"
		transfer_to_bu_server "$db_dir" "$bu_key" "$bu_user" "$bu_ip" "$bu_dir"
	fi
}

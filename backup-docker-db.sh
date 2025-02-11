#!/usr/bin/env bash

set -e

# Script version
readonly VERSION=0.0.1
# Script filename
readonly FILENAME=$(basename ${0})
# Current date
readonly DATE=$(date "+%Y-%m-%d")
# Retention days amount
readonly RETENTION=${RETENTION:-3}
# Backup directory path
readonly BACKUP_DIR=${BACKUP_DIR:-"/backup"}

# For these variables, you can fill them inside the file
# or using CLI arguments.

# Database username
USERNAME=
# Database password
PASSWORD=
# Database name
DATABASE=
# Database engine
ENGINE=
# Docker container id / name
CONTAINER=
# Operation kind (export, import)
OPERATION=export
# File path to the import file
# (optional is ${OPERATION} is export)
DB_FILE=

# Destination filename without the extension
DESTINATION=

# Help display function
print_help() {
  cat <<USAGE
${FILENAME}
Version ${VERSION}

Optional arguments
  -h        Show this help message
  -u        Database user
  -p        Databse password
  -d        Database name
  -e        Database engine (mysql, postgresql)
  -c        Docker container
  -f        Database file (import only)
  -k        Operation kind (import, export)
  -v        Print the script version
USAGE
}

# Parsing the CLI arguments with the built-in getopts command
parse() {
  while getopts "k:f:c:e:u:p:d:hvn" arg; do
    case ${arg} in
    u) USERNAME=${USERNAME:-${OPTARG}} ;;

    e) ENGINE=${ENGINE:-${OPTARG}} ;;

    p) PASSWORD=${PASSWORD:-${OPTARG}} ;;

    d) DATABASE=${DATABASE:-${OPTARG}} ;;

    c) CONTAINER=${CONTAINER:-${OPTARG}} ;;

    f) DB_FILE=${DB_FILE:-${OPTARG}} ;;

    k) OPERATION=${OPTARG} ;;

    h)
      print_help
      exit 0
      ;;

    v)
      echo ${FILENAME} -- ${VERSION}
      exit 0
      ;;
    esac
  done

  if [[ -z ${CONTAINER} ]]; then
    echo "You must set a container id/name" >&2
    return 1
  fi

  DESTINATION=${BACKUP_DIR}/${ENGINE}-${CONTAINER}-${DATE}
}

# Export a MySQL database inside a Docker container as a SQL file
export_mysl() {
  docker exec ${CONTAINER} \
    mysqldump \
    -u ${USERNAME} \
    --password=${PASSWORD} \
    ${DATABASE} >${DESTINATION}.sql
}

# Import a SQL file into a Docker container containing a MySQL database
import_mysql() {
  cat ${DB_FILE} | docker exec -i ${CONTAINER} \
    mysql -u ${USERNAME} \
    --password=${PASSWORD} \
    ${DATABASE}
}

# Export a PostgreSQL database inside a Docker container as a SQL file
export_postgresql() {
  docker exec ${CONTAINER} \
    pg_dump \
    -U ${USERNAME} \
    ${DATABASE} >${DESTINATION}.sql
}

# Import a SQL file into a Docker container containing a PostgreSQL database
import_postgresql() {
  cat ${DB_FILE} | docker exec -i ${CONTAINER} \
    psql \
    -d ${DATABASE} \
    -U ${USERNAME}
}

# Deleting files older than ${RETENTION} days
purge_backups() {
  find ${BACKUP_DIR} \
    -type f \
    -mtime +${RETENTION} \
    -delete

  echo "Deleted files older than ${RETENTION} days in ${BACKUP_DIR}"
}

# Export manager
_export() {
  case ${ENGINE} in
  mysql) export_mysl ;;
  postgresql) export_postgresql ;;
  *) return 1 ;;
  esac

  echo "Exported the database from ${CONTAINER} as ${DESTINATION}"
}

# Import manager
_import() {
  case ${ENGINE} in
  mysql) import_mysql ;;
  postgresql) import_postgresql ;;
  *) return 1 ;;
  esac

  echo "Imported ${DB_FILE} into ${CONTAINER}"
}

# Operation controller
_exec() {
  local call=

  case ${OPERATION} in
  export) call=_export ;;
  import) call=_import ;;
  esac

  if ! ${call}; then
    echo "Invalid database engine, check -h" >&2
    return 1
  fi
}

main() {
  parse ${@} || exit 1

  test -d ${BACKUP_DIR} || mkdir -p ${BACKUP_DIR}

  echo "Starting database ${OPERATION}"

  _exec || exit 1
  purge_backups
}

main ${@}

#!/usr/bin/env bash

set -e

# Script version
readonly VERSION=0.0.1
# Script filename
readonly FILENAME=$(basename ${0})
# Current date
readonly DATE=$(date "+%Y-%m-%d")
# https://github.com/theobori/dockerv
#
# dockerv source points
#
# You can replace $@ by the sources point you want
# instead of passing CLI arguments
readonly SOURCE_POINTS=($@)
# Retention days amount
readonly RETENTION=${RETENTION:-3}
# Backup directory path
readonly BACKUP_DIR=${BACKUP_DIR:-"/backup"}
# dockerv destination point
readonly DESTINATION_POINT="${BACKUP_DIR}/docker-volumes-${DATE}.tar.gz"

# Help display function
print_help() {
  cat <<USAGE
${FILENAME}
Version ${VERSION}

Optional arguments
  -h        Show this help message
  -v        Print the script version

Usage example
${FILENAME} src1 src2 src3
USAGE
}

# Parsing the CLI arguments with the built-in getopts command
parse() {
  while getopts "hv" arg; do
    case ${arg} in
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

  if [[ ${#SOURCE_POINTS[@]} -eq 0 ]]; then
    echo "Missing sources, check the help message" >&2
    return 1
  fi
}

# Exporting and packing Docker volumes
# selected with the source points as a Tarball
export_docker_volumes() {
  local args=""

  for source_point in ${SOURCE_POINTS[@]}; do
    args+="--src \"${source_point}\" "
  done

  if ! dockerv export \
    ${args} \
    --dest ${DESTINATION_POINT} \
    --force; then
    return 1
  fi
}

# Deleting files older than ${RETENTION} days
purge_backups() {
  find ${BACKUP_DIR} \
    -type f \
    -mtime +${RETENTION} \
    -delete

  echo "Deleted files older than ${RETENTION} days in ${BACKUP_DIR}"
}

main() {
  parse ${@} || exit 1

  mkdir -p ${BACKUP_DIR}

  echo "Starting Docker volumes export"

  export_docker_volumes || exit 1
  purge_backups
}

main ${@}

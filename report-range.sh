#!/usr/bin/env bash

set -e

# Script version
readonly VERSION=0.0.1
# Script filename
readonly FILENAME=$(basename ${0})

# CLI arguments
#
# Start date range
readonly START_DATE=${1:-$(date --date='-1 month' -I)}
# End date range
readonly END_DATE=${2:-$(date --date='+1 month' -I)}
# Output report
readonly OUTPUT=${3:-"report.html"}
# Starting point
readonly STARTING_POINT=${4:-"/var/log/nginx/access.log*"}

# Environment variables
#
# goaccess configuration
readonly CONF=${CONF:-"/etc/goaccess/goaccess.conf"}
#Target domain and subdomains only
readonly GREP_FILTER=${GREP_FILTER:-"theobori.cafe"}

# Help display function
print_help() {
  cat <<USAGE
${FILENAME}
Version ${VERSION}

Arguments
${FILENAME} <start_date> <end_date> <output path> <file(s)/dir>

The following environment variables are overridable:
- GREP_FILTER
- CONF

Usage example:

CONF="custom.conf" ${FILENAME} \\
    "$(date --date='-1 month' -I)" \\
    "$(date --date='+1 month' -I)" \\
    "report.html" \\
    "web_server_logs/*.log"
USAGE
}

report() {
  local -r files=$(find ${STARTING_POINT} -maxdepth 1 -newermt "${START_DATE}" ! -newermt "${END_DATE}")

  if [[ -z ${files} ]]; then
    echo "Missing files to process !"
    exit 1
  fi

  zcat -f ${files} |
    grep -P "${GREP_FILTER}" |
    goaccess -o ${OUTPUT} --log-format=COMBINED -p ${CONF} -
}

main() {
  if [[ ${#@} -lt 3 ]]; then
    print_help
    exit 1
  fi

  report
}

main ${@}

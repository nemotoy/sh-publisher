#!/usr/bin/env bash

set -euo pipefail

readonly FILE_NAME="message.json"
readonly TOPIC_NAME="test/topic"
readonly ATTR_KEY_ID="uuid"

function usage() {
cat <<_EOT_
Usage:
  $0 [--type messageKey]

Description:
  This script publishes messages defined from a JSON file to a CloudPub/Sub topic

Options:
  --type, -t  represent a type of message key
_EOT_
exit 1
}

function parse_args() {
  while [ $# -gt 0 ];
  do
    case ${1} in
        --type|-t)
            type="${2}"
            shift
        ;;

        --help|-h)
            usage
            shift
        ;;

        *)
            echo "[ERROR] Invalid option '${1}'"
            usage
            exit 1
        ;;
    esac
    shift
  done
}

function gen_attribute() {
  local uuid; uuid=$(uuidgen | tr "[:upper:]" "[:lower:]")
  attr="${ATTR_KEY_ID}=${uuid}"
}

function do_publish() {
  echo "gcloud pubsub topics publish ${TOPIC_NAME} --message '${msg}' --attribute ${attr}"
  echo "Are you sure you want to do this command?(y/n)"
  read -r answer
  case "${answer}" in

      y)
          ;;
      n)
          echo "finished "
          exit 1
          ;;
      *)
          echo "${answer} is invalid"
          exit 1
          ;;
  esac
}

function publish() {
  local root_dir; root_dir=$(cd "$(dirname "$0")" && pwd)
  local file="${root_dir}/${FILE_NAME}"
  msg=$(< "${file}" jq -r '.[].'"${type}"'')

  gen_attribute
  do_publish
  echo gcloud pubsub topics publish "${TOPIC_NAME}" --message "${msg}" --attribute "${attr}"
}


function main() {
  parse_args "$@"
  publish
}

main "$@"

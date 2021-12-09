#!/bin/bash -x
# Sample:
# ./search_entities.sh -t fs_path -n abc_abc-FX_corebanking

# Default local IP

usage() {
  echo "usage: ATLAS server lookup script: [[-ip 'xxx.xxx.xxx.xxx' ] | [-h]]"
}

while [ "$1" != "" ]; do
  case $1 in
  -t | --type)
    shift
    TYPE_NAME="$1"
    ;;
  -n | --name)
    shift
    ENTITY_NAME="$1"
    ;;
  -h | --help)
    usage
    exit
    ;;
  *)
    usage
    exit 1
    ;;
  esac
  shift
done

ATLAS_USER="admin"
ATLAS_PWD="admin"
ATLAS_ENDPOINT="http://localhost:21000/api/atlas/v2"
ATLAS="${ATLAS_USER}:${ATLAS_PWD}"
# TYPE_NAME="fs_path" 
# ENTITY_NAME="abc_abc-FX_corebanking"

SERVER_GUID=$(curl -u ${ATLAS} \
  -X GET \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' "${ATLAS_ENDPOINT}/search/basic?typeName=${TYPE_NAME}&query=${ENTITY_NAME}" | jq --raw-output '.')

echo "$SERVER_GUID"

# -H 'Accept:application/json' "${ATLAS_ENDPOINT}/search/basic?typeName=${TYPE_NAME}&query=${ENTITY_NAME}" | jq --raw-output '.entities[].guid')
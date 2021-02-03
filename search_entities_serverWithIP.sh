#!/bin/bash -x
# Sample:
# ./search_entities_serverWithIP.sh -ip 10.71.68.133

# Default local IP
SERVER_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

usage() {
  echo "usage: ATLAS server lookup script: [[-ip 'xxx.xxx.xxx.xxx' ] | [-h]]"
}

while [ "$1" != "" ]; do
  case $1 in
  -ip | --ipadress)
    shift
    SERVER_IP="$1"
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

SERVER_GUID=$(curl -u ${ATLAS} \
  -X GET \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' "${ATLAS_ENDPOINT}/search/basic?typeName=server&query=${SERVER_IP}" | jq --raw-output '.entities[].guid')

echo "$SERVER_GUID"

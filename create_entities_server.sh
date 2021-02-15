#!/bin/bash -x
# Sample:
# ./create_entities_server.sh -ip 10.71.68.007 -h 4711 -e prod -c edge_node -r 4711

# Default local IP
SERVER_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

HOST_NAME=$(hostname)
HOST_OS=$OSTYPE
USER=$USER
RACK_ID="swiss 1.0"

usage() {
  echo "usage: ATLAS create server script: [[-ip 'xxx.xxx.xxx.xxx'] | [-h'xxx'] | [-e 'xxx'] | [-c 'xxx'] | [-r 'xxx'] | [-help]]"
}

while [ "$1" != "" ]; do
  case $1 in
  -c | --classification)
    shift
    CLASS="$1"
    ;;
  -e | --env_level)
    shift
    ENV="$1"
    ;;
  -h | --host_name)
    shift
    HOST_NAME="$1"
    ;;
  --help)
    usage
    exit
    ;;
  -ip | --ipadress)
    shift
    SERVER_IP="$1"
    ;;
  -r | --rack_id)
    shift
    RACK_ID="$1"
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

ATLAS="curl -u ${ATLAS_USER}:${ATLAS_PWD}"

# typedef
SERVER_GUID=$(${ATLAS} \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' ${ATLAS_ENDPOINT}/entity/bulk -d '
  {
  "entities": [
    {
      "typeName": "server",
      "createdBy": "infrastructure_'"$USER"'",
      "attributes": {
        "description": "Server: '"$HOST_NAME"' a '"$CLASS"' in the '"$ENV"' environment",
        "owner": "'"$USER"'",
        "qualifiedName": "'"$HOST_NAME"'.'"$CLASS"'@'"$ENV"'",
        "name": "'"$HOST_NAME"'.'"$CLASS"'",
        "host_name": "'"$HOST_NAME"'",
        "ip_address": "'"$SERVER_IP"'",
        "zone": "'"$ENV"'",
        "platform": "'"$HOST_OS"'",
        "rack_id": "'"$RACK_ID"'"
      },
      "classifications": [
        {"typeName": "'"$CLASS"'"}
      ]
    }
  ]
  }' | jq --raw-output '.guidAssignments[]')

echo "$SERVER_GUID"

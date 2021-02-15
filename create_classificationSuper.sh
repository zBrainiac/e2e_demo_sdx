#!/bin/bash -x
# ./create_classification.sh -a ABC
usage() {
  echo "usage: ATLAS create server script: [[-a 'xxx'] | [-help]]"
}

while [ "$1" != "" ]; do
  case $1 in
  -a | --application_id)
    shift
    APPLICATION_ID="$1"
    ;;
  --help)
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

ATLAS="curl -u ${ATLAS_USER}:${ATLAS_PWD}"

# classification
$(${ATLAS}  \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' ${ATLAS_ENDPOINT}/types/typedefs -d '{
  "classificationDefs": [
    {
      "category": "CLASSIFICATION",
      "name": "'"$APPLICATION_ID"'",
      "typeVersion": "1.0",
      "attributeDefs": [],
      "superTypes": []
    }
  ]
  }
')

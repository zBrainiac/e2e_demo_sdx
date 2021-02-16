#!/bin/bash -x
# ./create_classification.sh -a ABC -s APPLICATION
usage() {
  echo "usage: ATLAS create server script: [[-a 'xxx'] | [-s 'xxx'] | [-help]]"
}

while [ "$1" != "" ]; do
  case $1 in
  -a | --application_id)
    shift
    APPLICATION_ID="$1"
    ;;
  -s | --super_type_id)
    shift
    SUPER_TYPE_ID="$1"
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
      "superTypes": ["'"$SUPER_TYPE_ID"'"]
    }
  ]
  }
')

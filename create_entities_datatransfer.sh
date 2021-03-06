#!/bin/bash -x
# Sample:
# ./create_entities_datatransfer.sh -t transfer -i raw-ds -ig 4a11c7a0-18ae-4e1d-a4f9-ac80762b34f2 -o landing_ds -og 5cbdd0c7-3fa3-4a00-8b10-1782b758a536 -c sftp

# Default local IP
SERVER_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

# lookup guid of this IP
SERVER_GUID=$(./search_entities_serverWithIP.sh -ip "${SERVER_IP}")
USER=$USER

usage() {
  echo "usage: ATLAS create file script: [[-i 'xxx'] | [-ip 'xxx.xxx.xxx.xxx'] | [-ig 'xxx'] | [-it 'xxx'] | [-o 'xxx'] | [-og 'xxx'] | [-ot 'xxx'] | [-t 'xxx'] | [-h]]"
}

while [ "$1" != "" ]; do
  case $1 in
  -c | --classification)
    shift
    CLASS="$1"
    ;;
  -i | --input_name)
    shift
    INPUT_NAME="$1"
    ;;
  -ig | --input_guid)
    shift
    INPUT_GUID="$1"
    ;;
  -it | --input_typ)
    shift
    INPUT_TYP="$1"
    ;;
  -ip | --ipadress)
    shift
    SERVER_IP="$1"
    ;;
  -o | --output_name)
    shift
    OUTPUT_NAME="$1"
    ;;
  -og | --output_guid)
    shift
    OUTPUT_GUID="$1"
    ;;
  -ot | --output_typ)
    shift
    OUTPUT_TYP="$1"
    ;;
  -t | --datafow_typ)
    shift
    DATAFLOW_TYP="$1"
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

ATLAS="curl -u ${ATLAS_USER}:${ATLAS_PWD}"

# entity definition for "etl_load"
DATAFLOW_GUID=$(${ATLAS} \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' ${ATLAS_ENDPOINT}/entity/bulk -d '
  {"entities": [
    {
      "typeName": "'"$DATAFLOW_TYP"'",
      "createdBy": "'"$DATAFLOW_TYP"'_'"$APPLICATION_ID"'_'"$USER"'",
      "attributes": {
        "qualifiedName": "'"$INPUT_NAME"'-to-'"$OUTPUT_NAME"'",
        "uri": "'"$INPUT_NAME"'-to-'"$OUTPUT_NAME"'",
        "name": "'"$INPUT_NAME"'-to-'"$OUTPUT_NAME"'",
        "description": "ingests '"$INPUT_TYP"' to '"$OUTPUT_TYP"'",
        "owner": "'"$USER"'",
        "run_user":"'"$USER"'",
        "target_server":"'"$TARGET_SERVER_GUID"'",
        "execution_server":{"guid": "'"$SERVER_GUID"'","typeName": "server"},
        "inputs": [{"guid": "'"$INPUT_GUID"'", "typeName": "'"$INPUT_TYP"'"}],
        "outputs": [{"guid": "'"$OUTPUT_GUID"'","typeName": "'"$OUTPUT_TYP"'"}]
      }
    }
  ],
      "classifications": [
        { "typeName": "'"$APPLICATION_ID"'" }
      ]
    }
  ]
  }' | jq --raw-output '.')

echo "$DATAFLOW_GUID"

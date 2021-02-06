#!/bin/bash -x
# Sample:
# ./create_entities_dataflowWithParm.sh -t etl_load -i raw_dataset -ig 862734ba-7c9c-436d-8858-5fdea68d498a -it dataset -o landing_ds -og e0945d8b-9013-42e0-b46f-c35f533eb274 -ot dataset -c etl_db_load

# Default local IP
SERVER_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

# lookup guid of this IP
SERVER_GUID=$(./search_entities_serverWithIP.sh -ip "${SERVER_IP}")

DATAFLOW_TYP="etl_load"
INPUT_NAME="dataset"
INPUT_GUID="02e61ff3-70ab-433d-9129-d83f6f406fcb"
INPUT_TYP="dataset"
OUTPUT_NAME="abc_db_table"
OUTPUT_GUID="9bd6da4d-cc67-4b62-b325-c28acf4136e0"
OUTPUT_TYP="db_table"
CLASS=

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

ATLAS_USER=admin
ATLAS_PWD=admin
ATLAS_ENDPOINT="http://localhost:21000/api/atlas/v2"

ATLAS="curl -u ${ATLAS_USER}:${ATLAS_PWD}"
ATLAS_HEADER="-X POST -H Content-Type:application/json -H Accept:application/json -H Cache-Control:no-cache"

# entity definition for "etl_load"
DATAFLOW_GUID=$(${ATLAS} \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' ${ATLAS_ENDPOINT}/entity/bulk -d '
  {"entities": [
    {
      "typeName": "'"$DATAFLOW_TYP"'",
      "createdBy": "ingestors_news",
      "attributes": {
        "qualifiedName": "'"$INPUT_NAME"'-to-'"$OUTPUT_NAME"'",
        "uri": "'"$INPUT_NAME"'-to-'"$OUTPUT_NAME"'",
        "name": "'"$INPUT_NAME"'-to-'"$OUTPUT_NAME"'",
        "description": "ingests '"$INPUT_TYP"' to '"$OUTPUT_TYP"'",
        "run_user":"'"$USER"'",
        "execution_server":{"guid": "'"$SERVER_GUID"'","typeName": "server"},
        "inputs": [{"guid": "'"$INPUT_GUID"'", "typeName": "'"$INPUT_TYP"'"}],
        "outputs": [{"guid": "'"$OUTPUT_GUID"'","typeName": "'"$OUTPUT_TYP"'"}]
      }
    }
  ],
      "classifications": [
        { "typeName": ["'"$CLASS"'", "'"$DATAFLOW_TYP"'"] }
      ]
    }
  ]
  }' | jq --raw-output '.guidAssignments[]')

echo "$DATAFLOW_GUID"

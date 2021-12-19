#!/bin/bash -x
# Sample:
# ./create_entities_data_processing.sh -t etl_load -i raw_dataset -ig 0aa3e090-587e-4bb8-b147-097951142ca4 -it dataset -o landing_ds -og 0035ec3a-c9ea-46ef-80e3-ae21ad3c391c -ot dataset -c etl_db_load


usage() {
  echo "usage: ATLAS create file script: [[-i 'xxx'] | [-ig 'xxx'] | [-it 'xxx'] | [-o 'xxx'] | [-og 'xxx'] | [-ot 'xxx'] | [-t 'xxx'] | [-h]]"
}

while [ "$1" != "" ]; do
  case $1 in
    -a | --application_id)
    shift
    APPLICATION_ID="$1"
    ;;
  -c | --classification)
    shift
    CLASS="$1"
    ;;
    -n | --name)
    shift
    NAME="$1"
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
      "classifications": [{ "typeName": "'"$APPLICATION_ID"'" }],
      "labels": ["quality_gate"],
      "attributes": {
        "qualifiedName": "'"$INPUT_NAME"'-to-'"$OUTPUT_NAME"'",
        "name": "'"$INPUT_NAME"'-to-'"$OUTPUT_NAME"'",
        "description": "ingests '"$INPUT_TYP"' to '"$OUTPUT_TYP"'",
        "owner": "'"$USER"'",
        "run_user":"'"$APPLICATION_ID"'-'"$USER"'",
        "inputs": [{"guid": "'"$INPUT_GUID"'", "typeName": "'"$INPUT_TYP"'"}],
        "outputs": [{"guid": "'"$OUTPUT_GUID"'","typeName": "'"$OUTPUT_TYP"'"}]
      }
    }
  ]}]
  }' | jq --raw-output '.guidAssignments[]')

echo "$DATAFLOW_GUID"

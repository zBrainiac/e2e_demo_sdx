#!/bin/bash -x
# Sample:
# ./create_entities_dataflowWithParm.sh

# Default local IP
SERVER_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

DATAFLOW_TYP="etl_load"
INPUT_GUID="fbaf9a8b-7d66-48f9-b2b7-31dbb4c0cfc5"
INPUT_TYP="dataset"
OUTPUT_GUID="bd3a6842-4140-429f-a3cd-04defa679eba"
OUTPUT_TYP="db_table"

USER=$USER

usage() {
  echo "usage: ATLAS create file script: [[-n 'xxx'] | [-ip 'xxx.xxx.xxx.xxx'] | [-d 'xxx/xxx/'] | [-f 'xxx'] | [-fq 'xxx'] | [-s 'xxx'] | [-h]]"
}

while [ "$1" != "" ]; do
  case $1 in
  -n | --file_name)
    shift
    FILE_NAME="$1"
    ;;
  -ip | --ipadress)
    shift
    SERVER_IP="$1"
    ;;
  -d | --file_directory)
    shift
    FILE_DIRECTORY="$1"
    ;;
  -f | --file_format)
    shift
    FILE_FORMAT="$1"
    ;;
  -fq | --file_frequency)
    shift
    FILE_FREQENCY="$1"
    ;;
  -s | --file_source)
    shift
    FILE_SOURCE="$1"
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

# lookup guid of this IP
SERVER_GUID=$(./search_entities_serverWithIP.sh -ip "${SERVER_IP}")

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
        "qualifiedName": "news_from_reuters:to:news_topic",
        "uri": "news_from_reuters:to:news_topic",
        "name": "news_from_reuters:to:news_topic",
        "description": "ingests '"$INPUT_TYP"' to '"$OUTPUT_TYP"' ",
        "run_user":"'"$USER"'",
        "execution_server":{"guid": "'"$SERVER_GUID"'","typeName": "server"},
        "inputs": [{"guid": "'"$INPUT_GUID"'", "typeName": "'"$INPUT_TYP"'"}],
        "outputs": [{"guid": "'"$OUTPUT_GUID"'","typeName": "'"$OUTPUT_TYP"'"}]
      }
    }
  ]
},
      "classifications": [
        { "typeName": "'"$DATAFLOW_TYP"'" }
      ]
    }
  ]
  }' | jq --raw-output '.guidAssignments[]')

echo "$DATAFLOW_GUID"

#!/bin/bash -x
# Sample:
# ./create_entities_fileWithParm.sh -n marcel_2 -d /tmp/tep -f rec -fq weekly -s core-banking

# Default local IP
SERVER_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

FILE_NAME="foobar1"
FILE_DIRECTORY="/tmp/data"
FILE_FORMAT="CSV"
FILE_FREQENCY="daily"
FILE_SOURCE="test"
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

# typedef
File_GUID=$(${ATLAS} \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' ${ATLAS_ENDPOINT}/entity/bulk -d '
  {
  "entities": [
    {
      "typeName": "dataset",
      "createdBy": "ingestors",
      "attributes": {
        "description": "Dataset: '"$FILE_NAME"'.'"$FILE_FORMAT"' is stored in '"$FILE_DIRECTORY"'",
        "qualifiedName": "'"$FILE_DIRECTORY"'/'"$FILE_NAME"'.'"$FILE_FORMAT"'",
        "name": "'"$FILE_NAME"'",
        "file_directory": "'"$FILE_DIRECTORY"'",
        "frequency":"'"$FILE_FREQENCY"'",
        "owner": "'"$USER"'",
        "group":"'"$FILE_SOURCE"'",
        "format":"'"$FILE_FORMAT"'",
        "server" : {"guid": "'"$SERVER_GUID"'","typeName": "server"},
        "col_schema":[
          { "col" : "id" ,"data_type" : "string" ,"required" : true },
          { "col" : "scrap_time" ,"data_type" : "timestamp" ,"required" : true },
          { "col" : "url" ,"data_type" : "string" ,"required" : true },
          { "col" : "headline" ,"data_type" : "string" ,"required" : true },
          { "col" : "content" ,"data_type" : "string" ,"required" : false }
        ]
      },
      "classifications": [
        { "typeName": "systemOfRecord" }
      ]
    }
  ]
  }' | jq --raw-output '.guidAssignments[]')

echo "$File_GUID"

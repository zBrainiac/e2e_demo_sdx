#!/bin/bash -x
# Sample:
# ./create_entities_dbtable.sh -a id3 -n abc_db_marcel_1 -d /tmp/tep -f rec -fq weekly -s core-banking

# Default local IP
SERVER_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
USER=$USER

usage() {
  echo "usage: ATLAS create file script: [[-n 'xxx'] | [-ip 'xxx.xxx.xxx.xxx'] | [-d 'xxx/xxx/'] | [-f 'xxx'] | [-fq 'xxx'] | [-s 'xxx'] | [-h]]"
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
  -n | --DB_TABLE_NAME)
    shift
    DB_TABLE_NAME="$1"
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
  -g | --server_guid)
    shift
    SERVER_GUID="$1"
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

ATLAS_USER="admin"
ATLAS_PWD="admin"
ATLAS_ENDPOINT="http://localhost:21000/api/atlas/v2"

ATLAS="curl -u ${ATLAS_USER}:${ATLAS_PWD}"

# typedef
DB_TABLE_GUID=$(${ATLAS} \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' ${ATLAS_ENDPOINT}/entity/bulk -d '
  {
  "entities": [
    {
      "typeName": "db_table",
      "createdBy": "ingestors_'"$APPLICATION_ID"'_'"$USER"'",
      "attributes": {
        "description": "External Db2 table: '"$DB_TABLE_NAME"' stored in '"$FILE_DIRECTORY"' format '"$FILE_FORMAT"'",
        "qualifiedName": "'"$FILE_DIRECTORY"'/'"$DB_TABLE_NAME"'.'"$FILE_FORMAT"'",
        "name": "'"$DB_TABLE_NAME"'",
        "file_directory": "'"$FILE_DIRECTORY"'",
        "frequency":"'"$FILE_FREQENCY"'",
        "owner": "'"$USER"'",
        "group":"'"$FILE_SOURCE"'",
        "format":"'"$FILE_FORMAT"'",
        "col_schema":[
          { "col" : "id" ,"data_type" : "string" ,"required" : true },
          { "col" : "scrap_time" ,"data_type" : "timestamp" ,"required" : true },
          { "col" : "url" ,"data_type" : "string" ,"required" : true },
          { "col" : "headline" ,"data_type" : "string" ,"required" : true },
          { "col" : "content" ,"data_type" : "string" ,"required" : false }
        ]
      },
      "classifications": [
        { "typeName": "'"$APPLICATION_ID"'" }
      ]
    }
  ]
  }' | jq --raw-output '.guidAssignments[]')

echo "$DB_TABLE_GUID"

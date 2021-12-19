#!/bin/bash -x
# Sample:
# ./create_entities_fs_path.sh -a zyx -n marcel_2 -d /data/corebanking -f csv -s systemOfRecord



usage() {
  echo "usage: ATLAS create file script: [[-a 'xxx'] | [-n 'xxx'] | [-d 'xxx/xxx/'] | [-f 'xxx'] | [-s 'xxx'] | [-h]]"
}

while [ "$1" != "" ]; do
  case $1 in
  -a | --application_id)
    shift
    APPLICATION_ID="$1"
    ;;
  -n | --file_name)
    shift
    FILE_NAME="$1"
    ;;
  -d | --file_directory)
    shift
    FILE_DIRECTORY="$1"
    ;;
  -f | --file_format)
    shift
    FILE_FORMAT="$1"
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

ATLAS_USER="admin"
ATLAS_PWD="admin"
ATLAS_ENDPOINT="http://localhost:21000/api/atlas/v2"

ATLAS="curl -u ${ATLAS_USER}:${ATLAS_PWD}"

# typedef
fs_path_GUID=$(${ATLAS} \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' ${ATLAS_ENDPOINT}/entity/bulk -d '
  {
  "entities": [
    {
      "typeName": "fs_path",
      "createdBy": "ingestors_'"$APPLICATION_ID"'_'"$USER"'",
      "classifications": [{ "typeName": "'"$APPLICATION_ID"'" }],
      "labels": ["raw_data"],
      "attributes": {
        "name": "'"$APPLICATION_ID"'_'"$FILE_NAME"'",
        "description": "Dataset '"$FILE_NAME"'.'"$FILE_FORMAT"' is stored in '"$FILE_DIRECTORY"'",
        "qualifiedName": "'"$FILE_DIRECTORY"'/'"$FILE_NAME"'.'"$FILE_FORMAT"'",
        "path": "'"$FILE_DIRECTORY"'",
        "owner": "'"$USER"'",
        "isFile": "true"
      }}]
  }' | jq --raw-output '.guidAssignments[]')

echo "$fs_path_GUID"

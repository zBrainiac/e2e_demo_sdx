#!/bin/bash -x
# Sample:
# ./create_entities_petWithParm.sh -s Burmilla -n "The Tiger" -e Red -c cat

ANIMAL_SPECIES="Birman"
NAME="sweety"
EYE_COLOR="blue"
CLASS=

usage() {
  echo "usage: ATLAS create server script: [[-s 'xxx'] | [-n'xxx'] | [-e 'xxx'] | [-help]]"
}

while [ "$1" != "" ]; do
  case $1 in
  -c | --classification)
    shift
    CLASS="$1"
    ;;
  -e | --eye_color)
    shift
    EYE_COLOR="$1"
    ;;
  -n | --name)
    shift
    NAME="$1"
    ;;
  -s | --animal_species)
    shift
    ANIMAL_SPECIES="$1"
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

ATLAS_USER=admin
ATLAS_PWD=admin
ATLAS_ENDPOINT="http://localhost:21000/api/atlas/v2"

ATLAS="curl -u ${ATLAS_USER}:${ATLAS_PWD}"
ATLAS_HEADER="-X POST -H Content-Type:application/json -H Accept:application/json -H Cache-Control:no-cache"

# typedef
PET_GUID=$(${ATLAS} \
  -H 'Content-Type:application/json' \
  -H 'Accept:application/json' ${ATLAS_ENDPOINT}/entity/bulk -d '
  {
  "entities": [
    {
      "typeName": "pet",
      "attributes": {
        "animal_species": "'"$CLASS"'.'"$ANIMAL_SPECIES"'",
        "name": "'"$NAME"'",
        "eye_color": "'"$EYE_COLOR"'"
      },
      "classifications": [
        {"typeName": "'"$CLASS"'"}
      ]
    }
  ]
  }' | jq --raw-output '.guidAssignments[]')

echo "$PET_GUID"

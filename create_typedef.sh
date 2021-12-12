#!/bin/bash -x

ATLAS_USER="admin"
ATLAS_PWD="admin"
ATLAS_ENDPOINT="http://localhost:21000/api/atlas/v2"

ATLAS="curl -u ${ATLAS_USER}:${ATLAS_PWD}"
ATLAS_HEADER="-X POST -H Content-Type:application/json -H Accept:application/json -H Cache-Control:no-cache"

# typedef
$(${ATLAS} ${ATLAS_HEADER} ${ATLAS_ENDPOINT}/types/typedefs -d '@./1_typedef-server.json')
$(${ATLAS} ${ATLAS_HEADER} ${ATLAS_ENDPOINT}/types/typedefs -d '@./2_typedef-etl_process.json')
$(${ATLAS} ${ATLAS_HEADER} ${ATLAS_ENDPOINT}/types/typedefs -d '@./3_typedef-file.json')
$(${ATLAS} ${ATLAS_HEADER} ${ATLAS_ENDPOINT}/types/typedefs -d '@./4_typedef-transfer_process.json')
$(${ATLAS} ${ATLAS_HEADER} ${ATLAS_ENDPOINT}/types/typedefs -d '@./5_typedef-Db_table.json')
$(${ATLAS} ${ATLAS_HEADER} ${ATLAS_ENDPOINT}/types/typedefs -d '@./10_typedef-pet.json')
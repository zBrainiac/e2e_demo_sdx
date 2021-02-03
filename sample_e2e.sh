#!/bin/bash -x

SERVER_GUID=$(./create_entities_serverWithParm.sh -h load-node-0 -e prod -c landing_zone_incoming)
echo "$SERVER_GUID"

FILE_GUID=$(./create_entities_fileWithParm.sh -n marcel_1 -d /data/landing/abc -f daily -fq weekly -s core-banking)
echo "$FILE_GUID"

DB_TABLE_GUID=$(./create_entities_dbtableWithParm.sh -n abc_db_marcel_1 -d /tmp/tep -f rec -fq weekly -s core-banking)
echo "$DB_TABLE_GUID"

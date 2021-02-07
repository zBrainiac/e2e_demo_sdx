#!/bin/bash -x
./create_typedef.sh

CLASS="systemOfRecord"
APPLICATION_ID="XYZ"
APPLICATION="loans"
ASSET="$APPLICATION_ID"-"$APPLICATION"

SERVER_GUID_LANDING_ZONE=$(./create_entities_serverWithParm.sh \
 -h load-node-0 \
 -e prod \
 -c landing_zone_incoming)
echo "$SERVER_GUID_LANDING_ZONE"

SERVER_GUID_MAINFRAME=$(./create_entities_serverWithParm.sh \
 -ip 10.71.68.007 \
 -h mainframe \
 -e prod \
 -c core_banking)
echo "$SERVER_GUID_MAINFRAME"

SERVER_GUID_DB_NODE=$(./create_entities_serverWithParm.sh \
 -ip 10.71.68.108 \
 -h db_max \
 -e prod \
 -c db_server)
echo "$SERVER_GUID_DB_NODE"

SERVER_GUID_STREAMING_NODE_0=$(./create_entities_serverWithParm.sh \
 -ip 10.71.68.120 \
 -h strimi \
 -e prod \
 -c streaming_node)
echo "$SERVER_GUID_STREAMING_NODE_0"

SERVER_GUID_STREAMING_NODE_1=$(./create_entities_serverWithParm.sh \
 -ip 10.71.68.121 \
 -h flinki \
 -e prod \
 -c streaming_node)
echo "$SERVER_GUID_STREAMING_NODE_1"


$(./create_classification.sh -a "$APPLICATION_ID")


FILE_GUID_CORE_BANING=$(./create_entities_fileWithParm.sh \
 -a "$APPLICATION_ID" \
 -n "$ASSET"_"corebanking" \
 -d /data/corebanking/"$APPLICATION_ID" \
 -f rec \
 -fq daily \
 -s "$ASSET" \
 -g "$SERVER_GUID_MAINFRAME" \
 -c "$CLASS")
echo "$FILE_GUID_CORE_BANING"


FILE_GUID_LANDING_ZONE=$(./create_entities_fileWithParm.sh \
 -a "$APPLICATION_ID" \
 -n "$ASSET"_"landing" \
 -d /incommingdata/corebanking/"$APPLICATION_ID" \
 -f rec \
 -fq daily \
 -s "$ASSET" \
 -g "$SERVER_GUID_LANDING_ZONE" \
 -c "$CLASS")
echo "$FILE_GUID_LANDING_ZONE"


FILE_GUID_LANDING_ZONE_ERROR=$(./create_entities_fileWithParm.sh \
 -a "$APPLICATION_ID" \
 -n "$ASSET"_"landing_error" \
 -d /incommingdata/corebanking/"$APPLICATION_ID" \
 -f rec \
 -fq daily \
 -s "$ASSET"_"error" \
 -g "$SERVER_GUID_LANDING_ZONE" \
 -c "$CLASS")
echo "$FILE_GUID_LANDING_ZONE_ERROR"


DB_TABLE_GUID=$(./create_entities_dbtableWithParm.sh \
 -a "$APPLICATION_ID" \
 -n "$ASSET"_"table" \
 -d /DB/"$APPLICATION_ID" \
 -f rec \
 -fq daily \
 -s "$ASSET")
echo "$DB_TABLE_GUID"


# add file transfer "core banking" to "landing zone"
FILE_MOVE_GUID=$(./create_entities_dataflowWithParm.sh \
 -a "$APPLICATION_ID" \
 -t transfer \
 -ip 192.168.0.102 \
 -i "$ASSET"_"raw_dataset" \
 -it dataset \
 -ig "$FILE_GUID_CORE_BANING" \
 -o "$ASSET"_"landing_dataset"   \
 -ot dataset \
 -og "$FILE_GUID_LANDING_ZONE" \
 -c sftp
 )
echo "$FILE_MOVE_GUID"

# add etl "landing zone" to "DB Table"
FILE_LOAD_GUID=$(./create_entities_dataflowWithParm.sh \
 -a "$APPLICATION_ID" \
 -t etl_load \
 -ip 192.168.0.102 \
 -i "$ASSET"_"landing_dataset" \
 -it dataset \
 -ig "$FILE_GUID_LANDING_ZONE" \
 -o "$ASSET"_"database_table"   \
 -og "$DB_TABLE_GUID" \
 -ot db_table \
 -c etl_db_load
 )
echo "$FILE_LOAD_GUID"

# add etl "landing zone" to "error file"
FILE_LOAD_GUID_ERROR=$(./create_entities_dataflowWithParm.sh \
 -a "$APPLICATION_ID" \
 -t etl_load \
 -ip 192.168.0.102 \
 -i "$ASSET"_"landing_dataset" \
 -it dataset \
 -ig "$FILE_GUID_LANDING_ZONE" \
 -o "$ASSET"_"error_dataset"  \
 -og "$FILE_GUID_LANDING_ZONE_ERROR" \
 -ot dataset \
 -c etl_db_load
 )
echo "$FILE_LOAD_GUID_ERROR"

#!/bin/bash -x
./create_typedef.sh

SERVER_GUID_LANDING_ZONE=$(./create_entities_serverWithParm.sh -h load-node-0 -e prod -c landing_zone_incoming)
echo "$SERVER_GUID_LANDING_ZONE"

SERVER_GUID_MAINFRAME=$(./create_entities_serverWithParm.sh -ip 10.71.68.007 -h mainframe -e prod -c core_banking)
echo "$SERVER_GUID_MAINFRAME"

SERVER_GUID_DB_NODE=$(./create_entities_serverWithParm.sh -ip 10.71.68.108 -h db_max -e prod -c db_server)
echo "$SERVER_GUID_DB_NODE"

SERVER_GUID_STREAMING_NODE_0=$(./create_entities_serverWithParm.sh -ip 10.71.68.120 -h strimi -e prod -c streaming_node)
echo "$SERVER_GUID_STREAMING_NODE_0"

SERVER_GUID_STREAMING_NODE_1=$(./create_entities_serverWithParm.sh -ip 10.71.68.121 -h flinki -e prod -c streaming_node)
echo "$SERVER_GUID_STREAMING_NODE_1"

CLASS="systemOfRecord"
APPLICATION="4711"
ASSET="mortgage"

FILE_GUID_CORE_BANING=$(./create_entities_fileWithParm.sh -n "SOURCE_$APPLICATION"_"$ASSET" -d /data/corebanking/"$APPLICATION" -f rec -fq daily -s "$APPLICATION"_"$ASSET" -g "$SERVER_GUID_MAINFRAME" -c "$CLASS")
echo "$FILE_GUID_CORE_BANING"

FILE_GUID_LANDING_ZONE=$(./create_entities_fileWithParm.sh -n "LANDING_$APPLICATION"_"$ASSET" -d /incommingdata/corebanking/"$APPLICATION" -f rec -fq daily -s "$APPLICATION"_"$ASSET" -g "$SERVER_GUID_LANDING_ZONE" -c "$CLASS")
echo "$FILE_GUID_LANDING_ZONE"

DB_TABLE_GUID=$(./create_entities_dbtableWithParm.sh -n "T_$APPLICATION"_"$ASSET" -d /DB/"$APPLICATION" -f rec -fq daily -s "$APPLICATION"_"$ASSET")
echo "$DB_TABLE_GUID"


FILE_MOVE_GUID=$(./create_entities_dataflowWithParm.sh -t transfer -ip 192.168.0.102 -i raw_ds -it dataset -ig  "$FILE_GUID_CORE_BANING" -o landing_ds -ot dataset -og "$FILE_GUID_LANDING_ZONE" -c sftp)
echo "$FILE_MOVE_GUID"

FILE_LOAD_GUID=$(./create_entities_dataflowWithParm.sh -t etl_load -ip 192.168.0.102 -i landing_ds -it dataset -ig "$FILE_GUID_LANDING_ZONE" -o database_table_1 -og "$DB_TABLE_GUID" -c etl_db_load)
echo "$FILELOAD_GUID"

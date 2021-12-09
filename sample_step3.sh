#!/bin/bash -x
./create_typedef.sh


CLASS="systemOfRecord"
APPLICATION_ID="zyx"
APPLICATION="loan"
ASSET="$APPLICATION_ID"-"$APPLICATION"


$(./create_classificationSuper.sh -a APPLICATION)
$(./create_classification.sh -a "$APPLICATION_ID" -s APPLICATION)

# create file send by MFT
FILE_GUID_CORE_BANING_MFT=$(./create_entities_fs_path.sh \
 -a "$APPLICATION_ID" \
 -n "$ASSET"_"corebanking" \
 -d nfs:/data/corebanking/"$APPLICATION_ID" \
 -f csv \
 -s "$CLASS")
echo "$FILE_GUID_CORE_BANING_MFT"


# create file moved from MFT to HDFS
FILE_GUID_CORE_BANING_HDFS=$(./create_entities_hdfs_path.sh \
 -a "$APPLICATION_ID" \
 -n "$ASSET"_"corebanking" \
 -d hdfs:/data/corebanking/"$APPLICATION_ID" \
 -f csv \
 -s "$CLASS")
echo "$FILE_GUID_CORE_BANING_HDFS"


# add file transfer "core banking" to "landing zone"
FILE_MOVE_GUID=$(./create_entities_data_processing.sh \
 -a "$APPLICATION_ID" \
 -t etl_load \
 -i "$ASSET"_"raw_dataset" \
 -it dataset \
 -ig "$FILE_GUID_CORE_BANING_MFT" \
 -o "$ASSET"_"landing_dataset"   \
 -ot dataset \
 -og "$FILE_GUID_CORE_BANING_HDFS" \
 -c etl_task)
echo "$FILE_MOVE_GUID"





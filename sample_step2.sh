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
 -d /data/corebanking/"$APPLICATION_ID" \
 -f csv \
 -s "$CLASS")
echo "$FILE_GUID_CORE_BANING_MFT"



# create file moved from MFT to HDFS
FILE_GUID_CORE_BANING_HDFS=$(./create_entities_hdfs_path.sh \
 -a "$APPLICATION_ID" \
 -n "$ASSET"_"corebanking" \
 -d hdfs://data/"$APPLICATION_ID"/data/corebanking/ \
 -f csv \
 -s "$CLASS")
echo "$FILE_GUID_CORE_BANING_HDFS"








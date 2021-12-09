#!/bin/bash -x
./create_typedef.sh

APPLICATION_ID="zyx"


$(./create_classificationSuper.sh -a APPLICATION)
$(./create_classification.sh -a "$APPLICATION_ID" -s APPLICATION)


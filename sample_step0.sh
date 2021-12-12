#!/bin/bash -x

APPLICATION_ID="zyx"


$(./create_classificationSuper.sh -a APPLICATION)
$(./create_classification.sh -a "$APPLICATION_ID" -s APPLICATION)


#!/bin/bash -x

# typedef
./create_entities_serverWithParm.sh -ip 10.71.68.008 -h load-node-1 -e prod -c landing_zone_incoming
./create_entities_serverWithParm.sh -ip 10.71.68.008 -h minmax -e prod -c edge_node
./create_entities_serverWithParm.sh -ip 10.71.68.008 -h minmax -e prod -c edge_node
./create_entities_serverWithParm.sh -ip 10.71.68.100 -h strimi -e prod -c streaming_node
./create_entities_serverWithParm.sh -ip 10.71.68.101 -h flinki -e prod -c streaming_node
./create_entities_serverWithParm.sh -h load-node-0 -e prod -c landing_zone_incoming
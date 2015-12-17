#!/bin/bash

for IP in $(seq 194 2 206)
do
    ALL_SERVERS[IP]=ubuntu@9.3.158.${IP}
done

#./create_new_keys.sh ${ALL_SERVERS[@]}
./distribute_keys.sh ${ALL_SERVERS[@]}


#!/bin/bash

# Setup ubuntu users
for IP in $(seq 194 2 206)
do
    ALL_SERVERS[IP]=ubuntu@9.3.158.${IP}
done

./create_new_keys.sh ${ALL_SERVERS[@]}
./distribute_keys.sh ${ALL_SERVERS[@]}

for SERVER in ${ALL_SERVERS[@]}
do
  scp setup_node.sh $SERVER:~/.
  ssh $SERVER "sudo ./setup_node.sh"
done

# Setup stack users
for IP in $(seq 194 2 206)
do
    ALL_SERVERS[IP]=stack@9.3.158.${IP}
done

./create_new_keys.sh ${ALL_SERVERS[@]}
./distribute_keys.sh ${ALL_SERVERS[@]}


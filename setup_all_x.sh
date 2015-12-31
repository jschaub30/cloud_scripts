#!/bin/bash

for IP in $(seq 221 227)
do
    ALL_SERVERS[IP]=ubuntu@9.3.158.${IP}
done

# Install common packages and setup each node
for SERVER in ${ALL_SERVERS[@]}
do
  scp setup_x_node.sh $SERVER:/tmp/.
  ssh $SERVER "sudo /tmp/setup_x_node.sh"
  if [ $? -ne 0 ] 
  then
      echo In another terminal, \"ssh $SERVER\" then run this command:
      echo     \"sudo /tmp/setup_x_node.sh\"
      echo Press return when finished...
      read tmp
  fi
done

# Add alternate hostnames "xcloud[1-7]" to list
for NUM in $(seq 1 7)
do
    ALL_SERVERS[NUM]=ubuntu@xcloud${NUM}
done

./create_new_keys.sh ${ALL_SERVERS[@]}
./distribute_keys.sh ${ALL_SERVERS[@]}


#!/bin/bash

# Setup ubuntu users
for IP in $(seq 194 2 206)
do
    ALL_SERVERS[IP]=ubuntu@9.3.158.${IP}
done

for IDX in $(seq 1 7)
do
  ALL_SERVERS[IDX]=ubuntu@pcloud${IDX}
done

./create_new_keys.sh ${ALL_SERVERS[@]}
./distribute_keys.sh ${ALL_SERVERS[@]}

echo Exiting before running setup_p_node.sh
exit 0

for SERVER in ${ALL_SERVERS[@]}
do
  scp setup_p_node.sh $SERVER:/tmp/.
  ssh $SERVER "sudo /tmp/setup_p_node.sh"
  if [ $? -ne 0 ]
  then
      echo In another terminal, \"ssh $SERVER\" then run this command:
      echo     \"sudo /tmp/setup_p_node.sh\"
      echo Press return when finished...
      read tmp
  fi
done


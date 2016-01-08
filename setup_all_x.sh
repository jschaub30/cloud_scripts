#!/bin/bash
# Setup x86-nodes after fresh Ubuntu install

. key_functions.sh

for IDX in 1 2 3 4 #6 7 # skip pcloud5
do
  ALL_SERVERS[IDX]=ubuntu@xcloud${IDX}
done

refresh_known_hosts

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
  rm -f /tmp/*html
  scp $SERVER:~/linux_summary/*.html /tmp/.
  scp /tmp/*.html schaubj@9.3.158.93:/www/files/machines/.
  rm -f /tmp/*html
done

if [ 0 -eq 1 ]
then
  # Add alternate hostnames "xcloud[1-7]" to list
  for NUM in $(seq 1 7)
  do
      ALL_SERVERS[NUM]=ubuntu@xcloud${NUM}
  done

  refresh_known_hosts
  read_all_keys > authorized_keys
  distribute_keys  # Copy authorized_keys to ${ALL_SERVERS[@]}
fi

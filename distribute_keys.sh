#!/bin/bash

[ "$#" -lt 1 ] && echo "USAGE: $0 SERVER1 [SERVER2] ..."  && exit 1

ALL_SERVERS=( "$@" )

echo All keys created, now updating each server with all keys


update_key (){
  scp authorized_keys $SERVER:~/.ssh/authorized_keys
  CMD="ssh-keyscan -H localhost ${ALL_HOSTS[@]} > .ssh/known_hosts"
  ssh $SERVER $CMD
}

# In case the servers have the form "user@server", create array of just hostnames
ALL_HOSTS=()
for SERVER in ${ALL_SERVERS[@]}
do
    ALL_HOSTS+=( $(echo $SERVER | cut -d'@' -f2) )
done

for SERVER in ${ALL_SERVERS[@]}
do
    update_key
done

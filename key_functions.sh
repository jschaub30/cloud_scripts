#!/bin/bash

echoerr() { echo "$@" 1>&2; }

read_create_key(){
    # Reads public key on $SERVER. If the key doesn't exist, it creates it first
  ssh $SERVER "[ ! -e ~/.ssh/id_rsa.pub ] && ssh-keygen -q -f ~/.ssh/id_rsa -t rsa -N '' > /dev/null; cat ~/.ssh/id_rsa.pub"
}

read_all_keys(){
  # Reads all keys from $ALL_SERVERS to stdout
  # Messages to stderr
  echoerr Adding key from Jeremys macbook pro
  echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDaZFfywNJyypW+ueSj7TfVVTwVQZ35Kqd90JM6teZOvyUKccLwrYKfQRvt+HGFK+xdRg1IWneMKAaQMINKExtzG3R52+rxCx7kz0UXOx8CDxX5NI38zLi4nLAxA8V5EVhdynBN10mZ9KI77NQXfJ0OTmCNehioXZcHDe0kLb7szJInJHD53DkyjBSuYgepk4MNFHDxWu9XCLEIrIWcRGmmzN5O5FV3hxaq4LiiU2tpNn7Hs8PKj5WP49//wXFFSpYBodmrF+W0oBkj9fCQhKXo0m4nv/uCxt7ZTQ3Jf6Kda1+BLp3psuMxBU/42GrtgEIfhhfzhZU48DdzASGBYo3D schaubj@jeremys-mbp-2.austin.ibm.com"
  echoerr Adding key from Jeremys mac server
  echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEdOR3KE1aWB3tCTaGcTM5a5t+OBHsSvFpYv02l63WYsZaN8OycawkLTTFgYtQw1isgh/3n6SjHge7e59FJ4uEWso34FpRxW2Pa3Jrsell2hx989sxoR3sBUs5xD+2ljoK2RXb/e2C9VFj8iNH7i9FOpxP30prfPu6D/y+qbusSQA3rTWVqOYUdJoNpvT2VppZ2hX9Be8YHQxbtsKdPERu03WRNAGhzuoAFDltMG3fNBU05NbodrV3kd8Ak0OQHkj+zt7bwKtWiytuwMn5UEX+0zqVqRSu4IkQgADQGKroXzxcNT6N5eidFRi3fBx9QSFkyziOvm3s9kuLIND7Hzp1 schaubj@arly249.austin.ibm.com"
  for SERVER in ${ALL_SERVERS[@]}
  do
    echoerr Reading/creating ssh key on $SERVER
    read_create_key
  done
}

refresh_known_hosts(){
   # This removes then adds the servers to the local known_hosts file
   # Requires 1 variable:
   # ALL_SERVERS=( pcloud1 pcloud2 pcloud3 )
   #   or
   # ALL_SERVERS=( ubuntu@pcloud1 ubuntu@pcloud2 ubuntu@pcloud3 )

   # Get only hostnames in case SERVER is of form "user@server"
   for TMPSERVER in ${ALL_SERVERS[@]}
   do
       ALL_HOSTS+=( $(echo $TMPSERVER | cut -d'@' -f2) )
   done

   for TMPHOST in ${ALL_HOSTS[@]}
   do
       echo Removing $TMPHOST from known_hosts
       ssh-keygen -R $TMPHOST
   done

   echo Now adding new servers to known hosts
   ssh-keyscan -H ${ALL_HOSTS[@]} >> ~/.ssh/known_hosts
}

distribute_keys(){
  for SERVER in ${ALL_SERVERS[@]}
  do
    echoerr Copying authorized_keys to $SERVER
    scp authorized_keys $SERVER:~/.ssh/authorized_keys
  done
}

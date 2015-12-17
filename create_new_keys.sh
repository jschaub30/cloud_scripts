#!/bin/bash

[ "$#" -lt 1 ] && echo "USAGE: $0 SERVER1 [SERVER2] ..."  && exit 1

ALL_SERVERS=( "$@" )

create_key(){
  ssh $SERVER "[ ! -e ~/.ssh/id_rsa.pub ] && ssh-keygen -q -f ~/.ssh/id_rsa -t rsa -N '' > /dev/null; cat ~/.ssh/id_rsa.pub"
}

echo "Adding key from Jeremy's macbook pro"
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDaZFfywNJyypW+ueSj7TfVVTwVQZ35Kqd90JM6teZOvyUKccLwrYKfQRvt+HGFK+xdRg1IWneMKAaQMINKExtzG3R52+rxCx7kz0UXOx8CDxX5NI38zLi4nLAxA8V5EVhdynBN10mZ9KI77NQXfJ0OTmCNehioXZcHDe0kLb7szJInJHD53DkyjBSuYgepk4MNFHDxWu9XCLEIrIWcRGmmzN5O5FV3hxaq4LiiU2tpNn7Hs8PKj5WP49//wXFFSpYBodmrF+W0oBkj9fCQhKXo0m4nv/uCxt7ZTQ3Jf6Kda1+BLp3psuMxBU/42GrtgEIfhhfzhZU48DdzASGBYo3D schaubj@jeremys-mbp-2.austin.ibm.com" > authorized_keys
echo "Adding key from Jeremy's mac server"
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDEdOR3KE1aWB3tCTaGcTM5a5t+OBHsSvFpYv02l63WYsZaN8OycawkLTTFgYtQw1isgh/3n6SjHge7e59FJ4uEWso34FpRxW2Pa3Jrsell2hx989sxoR3sBUs5xD+2ljoK2RXb/e2C9VFj8iNH7i9FOpxP30prfPu6D/y+qbusSQA3rTWVqOYUdJoNpvT2VppZ2hX9Be8YHQxbtsKdPERu03WRNAGhzuoAFDltMG3fNBU05NbodrV3kd8Ak0OQHkj+zt7bwKtWiytuwMn5UEX+0zqVqRSu4IkQgADQGKroXzxcNT6N5eidFRi3fBx9QSFkyziOvm3s9kuLIND7Hzp1 schaubj@arly249.austin.ibm.com" >> authorized_keys
for SERVER in ${ALL_SERVERS[@]}
do
  echo Creating ssh key on $SERVER
  create_key >> authorized_keys
done

echo All keys created, written to authorized_keys


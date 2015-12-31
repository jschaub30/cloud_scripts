#!/bin/bash

FLAG=$(grep ubuntu /etc/sudoers | grep NOPASSWD | wc -l)
if [ $FLAG -eq 0 ]
then
  echo Setting NOPASSWD option for user ubuntu
  echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

if [ ! -e /opt/stack ]
then
  echo Adding stack user
  groupadd -g 5432 stack
  useradd --uid 5432 -g stack -s /bin/bash -d /opt/stack -m stack
  usermod -a -G sudo stack
  echo "stack ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
else
  echo user "stack" already created
fi
echo stack:stack | chpasswd

apt-get install -y lvm2
FLAG=$(pvdisplay | grep stack-volumes | wc -l)
if [ $FLAG -eq 0 ]
then
  echo Setting up stack-volumes on sdb
  pvcreate /dev/sdb
  vgcreate stack-volumes /dev/sdb
else
  echo Stack volumes already created
fi

if [ ! -e /nvme ]
then
  echo Creating RAID5 on NVME cards
  if [ -e /dev/md0 ] 
  then
    mdadm --stop /dev/md0
    mdadm --zero-superblock /dev/nvme0n1
    mdadm --zero-superblock /dev/nvme1n1
  fi
  mdadm --create /dev/md0 --level=5 --raid-devices=2 /dev/nvme0n1 /dev/nvme1n1
  mkfs.ext4 /dev/md0 > mkfs.log
  UUID=$(grep "Filesystem UUID" mkfs.log | perl -pe "s/.*Filesystem UUID: //")
  mkdir /nvme
  cp /etc/fstab /etc/fstab.old
  grep -v nvme /etc/fstab.old > /etc/fstab
  echo "UUID=$UUID /nvme           ext4    nofail          1       1" >> /etc/fstab
  mount -a
  chmod 777 /nvme
  chown -R ubuntu:ubuntu /nvme
else
  echo "/nvme already exists"
fi

echo Setting up hosts 
cp /etc/hosts /etc/hosts.old
grep -v pcloud /etc/hosts.old > /etc/hosts

IDX=1
for IP in $(seq 194 2 206)
do
  echo "9.3.158.${IP}  pcloud$IDX pcloud${IDX}.austin.ibm.com" >> /etc/hosts
  IDX=$((IDX+1))
done


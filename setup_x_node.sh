#!/bin/bash
# Must be run as root
[ $USER != root ] && echo "Run this script ($0) as root" && exit 1

echo INSTALLING COMMON PACKAGES
cd /root
rm -rf ubuntu_setup
git clone https://github.com/jschaub30/ubuntu_setup
cd ubuntu_setup
apt-get update
./setup_system.sh

echo CONFIGURING /data
cd /root
if [ ! -e /data ]
then
  echo Creating RAID5 on 9 SSDs
  if [ -e /dev/md0 ] 
  then
    mdadm --stop /dev/md0
    mdadm --zero-superblock /dev/nvme0n1
    mdadm --zero-superblock /dev/nvme1n1
  fi
  mdadm --create /dev/md0 --level=5 --raid-devices=9 /dev/sd[b-j]
  mkfs.ext4 /dev/md0 > mkfs.log
  UUID=$(grep "Filesystem UUID" mkfs.log | perl -pe "s/.*Filesystem UUID: //")
  mkdir /data
  cp /etc/fstab /etc/fstab.old
  grep -v data /etc/fstab.old > /etc/fstab
  echo "UUID=$UUID /data ext4    nofail          1       1" >> /etc/fstab
  mount -a
  chmod 777 /data
  chown -R ubuntu:ubuntu /data
else
  echo "/data already exists on $HOSTNAME"
fi

echo Setting up /etc/hosts
cp /etc/hosts /etc/hosts.old
grep -v xcloud /etc/hosts.old > /etc/hosts

for IDX in $(seq 1 7)
do
    echo "9.3.158.$((IDX+220))  xcloud$IDX xcloud${IDX}.austin.ibm.com" >> /etc/hosts
done


#!/bin/bash

FLAG=$(grep ubuntu /etc/sudoers | grep NOPASSWD | wc -l)
if [ $FLAG -eq 0 ]
then
  echo Setting NOPASSWD option for user ubuntu
  echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

#if [ ! -e /mnt/nvme ]
if [ 0 -eq 1 ]
then
  umount /nvme
  umount /mnt/nvme
  rm -rf /nvme
  mkdir -p /mnt/nvme
  echo Creating RAID0 on NVME cards
  DEV=$(lsblk | grep raid | head -n1 | perl -pe "s/.*md([0-9]*).*/md\1/")
  if [ "$DEV" != "" ]
  then
    mdadm --stop /dev/$DEV
    mdadm --zero-superblock /dev/nvme0n1
    mdadm --zero-superblock /dev/nvme1n1
  fi
  mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/nvme0n1 /dev/nvme1n1
  mkfs.ext4 /dev/md0 | tee /tmp/mkfs.log
  UUID=$(grep "Filesystem UUID" /tmp/mkfs.log | perl -pe "s/.*Filesystem UUID: //")
  cp /etc/fstab /etc/fstab.old
  grep -v nvme /etc/fstab.old > /etc/fstab
  echo "UUID=$UUID /mnt/nvme           ext4    nofail          1       1" >> /etc/fstab
  mount -a
  chmod 777 /mnt/nvme
  chown -R ubuntu:ubuntu /mnt/nvme
  ln -sf /mnt/nvme /data
  chown ubuntu:ubuntu /data
else
  echo "/mnt/nvme already exists"
fi

echo Setting up hosts
cp /etc/hosts /etc/hosts.old
grep -v pcloud /etc/hosts.old > /etc/hosts

for IP in 194 196 198 200 202 204 206
do
  IDX=$((IP/2 - 96))
  echo "9.3.158.${IP}  pcloud$IDX pcloud${IDX}.austin.ibm.com" >> /etc/hosts
done

echo Uploading 1 page html summary of machine
[ ! -e ~/linux_summary ] && git clone https://github.com/jschaub30/linux_summary
cd ~/linux_summary
git pull
./linux_summary.sh
mv index.html $(hostname).html

#!/bin/bash
# Setup x86-node after fresh Ubuntu install

# Must be run as root
[ $USER != root ] && echo "Run this script ($0) as root" && exit 1

if [ 0 -eq 1 ]
then
    echo INSTALLING COMMON PACKAGES
    cd /root
    rm -rf ubuntu_setup
    git clone https://github.com/jschaub30/ubuntu_setup
    cd ubuntu_setup
    apt-get update
    ./setup_system.sh
fi

if [ 0 -eq 1 ]
then
  echo CONFIGURING /mnt/data
  cd /root
  #if [ ! -e /mnt/data ]
  if [ 1 ]
  then
    umount /data
    umount /mnt/data
    rm -rf /data
    mkdir -p /mnt/data
    echo Creating RAID0 on 9 SSDs
    if [ $(lsblk | grep sda | wc -l) -lt 4 ]
    then
        echo "Volume sda doesn't appear to be root volume, exiting..."
        lsblk
        exit 1
    fi
    DEV=$(lsblk | grep raid | head -n1 | perl -pe "s/.*md([0-9]*).*/md\1/")
    if [ "$DEV" != "" ]
    then
      mdadm --stop /dev/$DEV
      mdadm --zero-superblock /dev/sd[b-j]
    fi
    mdadm --create /dev/md0 --level=0 --raid-devices=9 /dev/sd[b-j]
    mkfs.ext4 /dev/md0 | tee mkfs.log
    UUID=$(grep "Filesystem UUID" mkfs.log | perl -pe "s/.*Filesystem UUID: //")
    cp /etc/fstab /etc/fstab.old
    grep -v data /etc/fstab.old > /etc/fstab
    echo "UUID=$UUID /mnt/data ext4    nofail          1       1" >> /etc/fstab
    mount -a
    chmod 777 /mnt/data
    chown -R ubuntu:ubuntu /mnt/data
    ln -sf /mnt/data /data
    chown ubuntu:ubuntu /data
  else
    echo "/mnt/data already exists on $HOSTNAME"
  fi
fi
echo Setting up /etc/hosts
cp /etc/hosts /etc/hosts.old
grep -v xcloud /etc/hosts.old > /etc/hosts

for IDX in $(seq 1 7)
do
    echo "9.3.158.$((IDX+220))  xcloud$IDX xcloud${IDX}.austin.ibm.com" >> /etc/hosts
done

echo Uploading 1 page html summary of machine
[ ! -e ~/linux_summary ] && git clone https://github.com/jschaub30/linux_summary
cd ~/linux_summary
git pull
./linux_summary.sh
mv index.html $(hostname).html

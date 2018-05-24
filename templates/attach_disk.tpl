#!/usr/bin/env bash

backup_data_dir='/var/lib/cassandra/data'
backup_data_device='/dev/sdb'
if [ ! -f $backup_data_dir ]; then
  if [[ $(sudo file -s $backup_data_device) = "$backup_data_device: data" ]]; then
    sudo mkfs -t ext4 $backup_data_device
    sudo mkdir -p $backup_data_dir
    echo "$backup_data_device $backup_data_dir ext4 defaults,nofail 0 2" | sudo tee --append /etc/fstab
    sudo mount -av
    sudo rm -rf $backup_data_dir/*
  fi
fi

sudo df -h

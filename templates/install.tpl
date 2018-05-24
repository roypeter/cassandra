#!/usr/bin/env bash

if [ -d /var/lib/cassandra/data/system ]; then
  echo "file /var/lib/cassandra/data/system already exists"
  exit 0
fi

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install default-jdk -y

java -version

echo "deb http://www.apache.org/dist/cassandra/debian ${cassandra_version} main"\
 | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list

curl https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -
sudo apt-key adv --keyserver pool.sks-keyservers.net --recv-key A278B781FE4B2BDA

sudo apt-get update -y

sudo apt-get install cassandra -y

sleep 15

sudo systemctl stop cassandra.service

sudo rm -rf /var/lib/cassandra/data/system

sleep 2

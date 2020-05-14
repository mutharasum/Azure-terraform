#!/bin/bash
sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt-cache policy docker-ce
sudo apt install -y docker-ce
sudo usermod -aG docker ${USER}
apt-get install -y docker-compose
docker-compose -f docker-comp.yaml up -d

echo "==================Installation complete==============";
sleep 10
echo "=========Checking the Elasticsearch health status...will take few seconds====";
sleep 15

curl http://127.0.0.1:9200/_cat/health

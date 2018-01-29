#!/bin/bash

set -e # -x

echo "-----> `date`: Upload stemcell"
bosh -n upload-stemcell "https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=3468.15" \
  --sha1 8b5b4d842d829d3c9e0582b2f53de3b3bb576ff5 \
  --name bosh-warden-boshlite-ubuntu-trusty-go_agent \
  --version 3468.15

echo "-----> `date`: Delete previous deployment"
bosh -n -d bosh-cron delete-deployment --force

echo "-----> `date`: Deploy"
( set -e; cd ./..;
  bosh -n -d bosh-cron deploy ./manifests/example.yml \
  -o ./manifests/dev.yml \
  -v director_ip=192.168.56.6 \
  -v director_client=admin \
  -v director_client_secret=$(bosh int ~/workspace/deployments/vbox/creds.yml --path /admin_password) \
  --var-file director_ssl.ca=<(bosh int ~/workspace/deployments/vbox/creds.yml --path /director_ssl/ca)
 )

echo "-----> `date`: Set up cron"
bosh -n update-config cron-item zookeeper-status.yml --name zookeeper-status

echo "-----> `date`: Delete deployment"
# todo bosh -n -d bosh-cron delete-deployment

echo "-----> `date`: Done"

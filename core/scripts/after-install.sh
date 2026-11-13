#!/bin/bash

cd /home/ubuntu/LimeLight-Core/ 
sudo docker image rm -f django-limelight-core
sudo docker image rm -f celeryworker-limelight-core
sudo docker image rm -f celerybeat-limelight-core
sudo docker compose -f docker-compose-production.yml 

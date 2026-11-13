#!/bin/bash

cd /home/ubuntu/LimeLight-Video/ &&

sudo docker image rm -f django-limelight-video
sudo docker image rm -f celeryworker-limelight-video
sudo docker image rm -f celerybeat-limelight-video
sudo docker image rm -f redis-limelight-video
sudo docker image rm -f celerycpu-limelight-video



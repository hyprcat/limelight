#!/bin/bash

cd /home/ubuntu/LimeLight-Core
COMPOSE_HTTP_TIMEOUT=200  docker compose -f docker-compose-production.yml up -d

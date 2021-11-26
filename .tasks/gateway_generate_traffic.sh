#!/bin/bash

PROJECT_NAME=$1
APPS_HOSTNAME_SUFFIX=$(oc whoami --show-console | sed 's%.*\(apps.*\)$%\1%g')

url=http://ingressgateway-${PROJECT_NAME}.${APPS_HOSTNAME_SUFFIX}/api/products

while true; do 
    if curl -s ${url} | grep -q OFFICIAL
    then
        echo -e "\e[96mGateway => Catalog GoLang (v2)\e[0m";
    else
        echo -e "\e[92mGateway => Catalog Spring Boot (v1)\e[0m";
    fi
    sleep 1
done
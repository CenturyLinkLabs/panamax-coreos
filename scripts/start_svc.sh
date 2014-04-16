#!/bin/bash

CONTAINER_NAME_UI="panamax_container_ui"
CONTAINER_NAME_API="panamax_container_api"

sudo systemctl start etcd
sudo systemctl start fleet
sudo useradd --system systemd-journal-gateway
sudo systemctl start systemd-journal-gatewayd.socket

if [[ `docker ps -a | grep $CONTAINER_NAME_API | grep -o $CONTAINER_NAME_API` == "" ]]; then
    echo "No Container....building."
    /usr/bin/docker run --name $CONTAINER_NAME_API -v /var/run/docker.sock:/run/docker.sock:rw  -e FLEETCTL_ENDPOINT=http://172.17.42.1:4001 -d  -p 3001:3000 74.201.240.198:5000/panamax-api
else
    echo "Container Found....Trying restart..."
    sudo rm -Rf /var/panamax/tmp/*
    /usr/bin/docker restart $CONTAINER_NAME_API
    #Dead container
    if [[ `docker ps -a | grep $CONTAINER_NAME_API` =~ *127* ]]; then
        echo "Dead Container....rebuilding."
        /usr/bin/docker stop $CONTAINER_NAME_API
        /usr/bin/docker rm $CONTAINER_NAME_API
        rm -Rf  /var/panamax/tmp/*
        /usr/bin/docker run --name $CONTAINER_NAME_API -v /var/run/docker.sock:/run/docker.sock:rw -e FLEETCTL_ENDPOINT=http://172.17.42.1:4001 -d  -p 3001:3000 74.201.240.198:5000/panamax-api
    elif [[ `docker ps -a | grep $CONTAINER_NAME_API` =~ *0* ]]; then
        echo "Stopped Container....restarting."
        /usr/bin/docker restart $CONTAINER_NAME_API
    fi
fi

API_CONTAINER_IP=`sudo docker inspect $CONTAINER_NAME_API | grep IPAddress | cut -d '"' -f 4`

if [[ `docker ps -a | grep $CONTAINER_NAME_UI | grep -o $CONTAINER_NAME_UI` == "" ]]; then
    echo "No Container....building."
    /usr/bin/docker run --name $CONTAINER_NAME_UI -v /var/run/docker.sock:/run/docker.sock:rw  -e PMX_API_PORT=3000 -e PMX_API_HOST=$API_CONTAINER_IP  -d  -p 3000:3000 74.201.240.198:5000/panamax-ui
else
    echo "Container Found....Trying restart..."
    sudo rm -Rf /var/panamax/tmp/*
    /usr/bin/docker restart $CONTAINER_NAME_UI
    #Dead container
    if [[ `docker ps -a | grep $CONTAINER_NAME_UI` =~ *127* ]]; then
        echo "Dead Container....rebuilding."
        /usr/bin/docker stop $CONTAINER_NAME_UI
        /usr/bin/docker rm $CONTAINER_NAME_UI
        rm -Rf  /var/panamax/tmp/*
        /usr/bin/docker run --name $CONTAINER_NAME_UI -v /var/run/docker.sock:/run/docker.sock:rw   -e PMX_API_PORT=3001 -e PMX_API_HOST=$API_CONTAINER_IP  -d  -p 3000:3000 74.201.240.198:5000/panamax-ui
    elif [[ `docker ps -a | grep $CONTAINER_NAME_UI` =~ *0* ]]; then
        echo "Stopped Container....restarting."
        /usr/bin/docker restart $CONTAINER_NAME_UI
    fi
fi

echo "Panamax setup complete"

#!/bin/bash

CONTAINER_NAME_UI="pmx-container-ui"
CONTAINER_NAME_API="pmx-container-api"

function startPmx {
    sudo systemctl start etcd
    sudo systemctl start fleet
    sudo useradd --system systemd-journal-gateway
    sudo systemctl start systemd-journal-gatewayd.socket
    
    if [[ `docker images | grep panamax-api` == "" ]]; then
        echo "Image not found. Downloading...."
        /usr/bin/docker pull 74.201.240.198:5000/panamax-api
    fi
    if [[ `docker images | grep panamax-ui` == "" ]]; then
        echo "Image not found. Downloading...."
        /usr/bin/docker pull 74.201.240.198:5000/panamax-ui
    fi 

    if [[ `docker ps -a | grep $CONTAINER_NAME_API | grep -o $CONTAINER_NAME_API` == "" ]]; then
        echo "No Container....building."
        /usr/bin/docker run --name $CONTAINER_NAME_API -v /var/run/docker.sock:/run/docker.sock:rw  -e JOURNAL_ENDPOINT=http://172.17.42.1:19531 -e FLEETCTL_ENDPOINT=http://172.17.42.1:4001 -d  -p 3001:3000 74.201.240.198:5000/panamax-api
    else
        echo "Container Found....Trying restart..."
        /usr/bin/docker restart $CONTAINER_NAME_API
        sleep 30
        #Dead container
        if [[ `docker ps -a | grep $CONTAINER_NAME_API | grep -i exit` != "" ]]; then
            echo "Dead Container....rebuilding."
            /usr/bin/docker rm -f $CONTAINER_NAME_API
            /usr/bin/docker run --name $CONTAINER_NAME_API -v /var/run/docker.sock:/run/docker.sock:rw -e JOURNAL_ENDPOINT=http://172.17.42.1:19531 -e FLEETCTL_ENDPOINT=http://172.17.42.1:4001 -d  -p 3001:3000 74.201.240.198:5000/panamax-api
        fi
    fi

    API_CONTAINER_IP=`sudo docker inspect $CONTAINER_NAME_API | grep IPAddress | cut -d '"' -f 4`

    if [[ `docker ps -a | grep $CONTAINER_NAME_UI | grep -o $CONTAINER_NAME_UI` == "" ]]; then
        echo "No Container....building."
        /usr/bin/docker run --name $CONTAINER_NAME_UI -v /var/run/docker.sock:/run/docker.sock:rw  -e PMX_API_PORT=3000 -e PMX_API_HOST=$API_CONTAINER_IP  -d  -p 3000:3000 74.201.240.198:5000/panamax-ui
    else
        echo "Container Found....Trying restart..."
        /usr/bin/docker restart $CONTAINER_NAME_UI
        sleep 30 
        #Dead container
        if [[ `docker ps -a | grep $CONTAINER_NAME_UI | grep -i exit` != "" ]]; then
            echo "Dead Container....rebuilding."
            /usr/bin/docker rm -f $CONTAINER_NAME_UI
            /usr/bin/docker run --name $CONTAINER_NAME_UI -v /var/run/docker.sock:/run/docker.sock:rw   -e PMX_API_PORT=3001 -e PMX_API_HOST=$API_CONTAINER_IP  -d  -p 3000:3000 74.201.240.198:5000/panamax-ui
        fi
    fi
}

function stopPmx {
    echo Stopping panamax containers
    /usr/bin/docker stop $CONTAINER_NAME_API
    /usr/bin/docker stop $CONTAINER_NAME_UI
    echo Stopped panamax conatiners
}


if [[ "$1" == "stop" ]]; then 
   stopPmx
else 
   startPmx
fi

echo "Panamax setup complete"
exit 0

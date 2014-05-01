#!/bin/bash

CONTAINER_NAME_UI="PMX_UI"
CONTAINER_NAME_API="PMX_API"
URL_API=74.201.240.198:5000/panamax-api
URL_UI=74.201.240.198:5000/panamax-ui
COREOS_ENDPOINT="http://172.17.42.1"

RUN_API="/usr/bin/docker run --name $CONTAINER_NAME_API -v /var/run/docker.sock:/run/docker.sock:rw  -e JOURNAL_ENDPOINT=$COREOS_ENDPOINT:19531 -e FLEETCTL_ENDPOINT=$COREOS_ENDPOINT:4001 -d -t  -p 3001:3000 $URL_API"
RUN_UI="/usr/bin/docker run --name $CONTAINER_NAME_UI -v /var/run/docker.sock:/run/docker.sock:rw  --link $CONTAINER_NAME_API:PMX_API   -d  -p 3000:3000 $URL_UI"

function startPmx {
   sudo systemctl enable etcd
   sudo systemctl start etcd
   sudo systemctl enable fleet.service
   sudo systemctl start fleet.service

   sudo useradd --system systemd-journal-gateway
   sudo systemctl enable systemd-journal-gatewayd.socket
   sudo systemctl start systemd-journal-gatewayd.socket
   
   sudo systemctl stop update-engine-reboot-manager.service
   sudo systemctl mask update-engine-reboot-manager.service

    if [[ `docker ps -a | grep $CONTAINER_NAME_API | grep -o $CONTAINER_NAME_API` == "" ]]; then
        echo "No Container....building."
        echo `$RUN_API`
    else
        echo "Container Found....Trying restart..."
        /usr/bin/docker restart $CONTAINER_NAME_API
        #Dead container
        if [[ `docker ps -a | grep $CONTAINER_NAME_API | grep -i exit` != "" ]]; then
            echo "Dead Container....rebuilding."
            /usr/bin/docker rm -f $CONTAINER_NAME_API
            echo `$RUN_API`
        fi
    fi

    API_CONTAINER_IP=`sudo docker inspect $CONTAINER_NAME_API | grep IPAddress | cut -d '"' -f 4`

    if [[ `docker ps -a | grep $CONTAINER_NAME_UI | grep -o $CONTAINER_NAME_UI` == "" ]]; then
        echo "No Container....building."
       echo `$RUN_UI` 
    else
        echo "Container Found....Trying restart..."
        /usr/bin/docker restart $CONTAINER_NAME_UI
        #Dead container
        if [[ `docker ps -a | grep $CONTAINER_NAME_UI | grep -i exit` != "" ]]; then
            echo "Dead Container....rebuilding."
            /usr/bin/docker rm -f $CONTAINER_NAME_UI
            echo `$RUN_UI`
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

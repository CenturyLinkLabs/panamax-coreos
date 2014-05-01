#!/bin/bash

CONTAINER_NAME_UI="PMX_UI"
CONTAINER_NAME_API="PMX_API"
PRIVATE_REPO=74.201.240.198:5000
URL_API=$PRIVATE_REPO/panamax-api
URL_UI=$PRIVATE_REPO/panamax-ui
COREOS_ENDPOINT="http://172.17.42.1"
IMAGE_TAG=latest

RUN_API="/usr/bin/docker run --name $CONTAINER_NAME_API -v /var/run/docker.sock:/run/docker.sock:rw  -e JOURNAL_ENDPOINT=$COREOS_ENDPOINT:19531 -e FLEETCTL_ENDPOINT=$COREOS_ENDPOINT:4001 -d -t  -p 3001:3000 "
RUN_UI="/usr/bin/docker run --name $CONTAINER_NAME_UI -v /var/run/docker.sock:/run/docker.sock:rw  --link $CONTAINER_NAME_API:PMX_API   -d  -p 3000:3000 "

function startCoreOSServices {
   sudo systemctl stop update-engine-reboot-manager.service
   sudo systemctl mask update-engine-reboot-manager.service
   sudo systemctl stop update-engine.service
   sudo systemctl mask update-engine.service
   sudo systemctl enable etcd
   sudo systemctl start etcd
   sudo systemctl enable fleet.service
   sudo systemctl start fleet.service
   sudo useradd --system systemd-journal-gateway
   sudo systemctl enable systemd-journal-gatewayd.socket
   sudo systemctl start systemd-journal-gatewayd.socket
}

function buildPmxImages {
    local buildAlways=0
    if [[ "$1" != "a" ]];  then #build always
        buildAlways=1
    fi
    if [[ "$buildAlways" == "1" ||   `docker images | grep ruby` == "" ]]; then
        echo "Base Image not found. Building...."
        /usr/bin/docker build --rm=false -t panamax/ruby /var/panamax/panamax-base
        /usr/bin/docker tag panamax/ruby $PRIVATE_REPO/ruby
        docker rm `docker ps -a | grep -v -e Up | awk '{print $1}'`
    fi
    if [[ "$buildAlways" == "1" || `docker images | grep panamax-ui` == "" ]]; then
        echo "UI Image not found. Building...."
        /usr/bin/docker build --rm=false -t panamax/panamax-ui /var/panamax/panamax-ui
        /usr/bin/docker tag panamax/panamax-ui $PRIVATE_REPO/panamax-ui
        docker rm `docker ps -a | grep -v -e Up | awk '{print $1}'`
    fi
    if [[ "$buildAlways" == "1" || `docker images | grep panamax-api` == "" ]]; then
        echo "API Image not found. Building...."
        /usr/bin/docker build --rm=false -t panamax/panamax-api /var/panamax/panamax-api
        /usr/bin/docker tag panamax/panamax-api $PRIVATE_REPO/panamax-api
        docker rm `docker ps -a | grep -v -e Up | awk '{print $1}'`
    fi
}

function startPmx {
    if [[ `docker ps -a | grep $CONTAINER_NAME_API | grep -o $CONTAINER_NAME_API` == "" ]]; then
        echo "No Container....building."
        echo `$RUN_API $URL_API:$IMAGE_TAG`
    else
        echo "Container Found....Trying restart..."
        /usr/bin/docker restart $CONTAINER_NAME_API
        #Dead container
        if [[ `docker ps -a | grep $CONTAINER_NAME_API | grep -i exit` != "" ]]; then
            echo "Dead Container....rebuilding."
            /usr/bin/docker rm -f $CONTAINER_NAME_API
            echo `$RUN_API $URL_API:$IMAGE_TAG`
        fi
    fi

    if [[ `docker ps -a | grep $CONTAINER_NAME_UI | grep -o $CONTAINER_NAME_UI` == "" ]]; then
        echo "No Container....building."
       echo `$RUN_UI $URL_UI:$IMAGE_TAG`
    else
        echo "Container Found....Trying restart..."
        /usr/bin/docker restart $CONTAINER_NAME_UI
        #Dead container
        if [[ `docker ps -a | grep $CONTAINER_NAME_UI | grep -i exit` != "" ]]; then
            echo "Dead Container....rebuilding."
            /usr/bin/docker rm -f $CONTAINER_NAME_UI
            echo `$RUN_UI $URL_UI:$IMAGE_TAG`
        fi
    fi
}

function stopPmx {
    echo Stopping panamax containers
    /usr/bin/docker stop $CONTAINER_NAME_API
    /usr/bin/docker stop $CONTAINER_NAME_UI
    echo Stopped panamax conatiners
}

function cleanupCoreOS {
    if [[ "fleetctl list-units | grep service "  != "" ]]; then
        echo Destroying all fleet units
        units=( `fleetctl list-units | grep service | gawk '{print $1 }'` )
        for i in "${units[@]}"
        do
            fleetctl destroy $i
        done
        #fleetctl destroy  `fleetctl list-units | grep service | gawk '{print $1 }'`
    fi
    if [[ "`docker ps -a | grep ago`" != "" ]]; then
        echo Destroying remaining docker containers
        /usr/bin/docker stop `docker ps -a -q` && \
        /usr/bin/docker rm `docker ps -a -q`
    fi
}

if [[ "$1" == "stop" ]]; then
   stopPmx
else
    if [[ "$1" == "dev" ]]; then
      IMAGE_TAG="dev"
    fi
   startCoreOSServices
   startPmx
fi

echo "Panamax setup complete"
exit 0

#!/bin/bash

CONTAINER_NAME_UI="PMX_UI"
CONTAINER_NAME_API="PMX_API"
PRIVATE_REPO=74.201.240.198:5000
NAMESPACE=panamax
IMAGE_API=panamax-api
IMAGE_UI=panamax-ui
COREOS_ENDPOINT="http://172.17.42.1"
IMAGE_TAG=latest

RUN_API="/usr/bin/docker run --name $CONTAINER_NAME_API -v /var/panamax-data:/var/app/panamax-api/db/mnt -v /var/run/docker.sock:/run/docker.sock:rw  -e JOURNAL_ENDPOINT=$COREOS_ENDPOINT:19531 -e FLEETCTL_ENDPOINT=$COREOS_ENDPOINT:4001 -d -t  -p 3001:3000 "
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
   if [[ `grep systemd-journal-gateway /etc/passwd` == "" ]]; then
    sudo useradd --system systemd-journal-gateway
   fi
   sudo systemctl enable systemd-journal-gatewayd.socket
   sudo systemctl start systemd-journal-gatewayd.socket
}

function buildPmxImages {
    local forceBuild=0
    if [[ "$1" == "a" ]];  then #build always
        forceBuild=1
    fi
    if [[ "$forceBuild" == "1" ||   `docker images | grep ruby` == "" ]]; then
        echo "Base Image not found. Building...."
        docker build --rm=false -t $NAMESPACE/ruby /var/panamax/panamax-base
    fi
    if [[ "$forceBuild" == "1" || `docker images | grep panamax-ui` == "" ]]; then
        echo "UI Image not found. Building...."
        docker build --rm=false -t $NAMESPACE/$IMAGE_UI /var/panamax/panamax-ui
    fi
    if [[ "$forceBuild" == "1" || `docker images | grep panamax-api` == "" ]]; then
        echo "API Image not found. Building...."
        docker build --rm=false -t $NAMESPACE/$IMAGE_API /var/panamax/panamax-api
    fi
    docker rm `docker ps -a | grep -v -e Up | grep ago | awk '{print $1}'`
}

function startPmx {
    if [[ `docker ps -a | grep $CONTAINER_NAME_API | grep -o $CONTAINER_NAME_API` == "" ]]; then
        echo "No Container....building."
        echo `$RUN_API $PRIVATE_REPO/$IMAGE_API:$IMAGE_TAG`
    else
        echo "API Container Found....Trying restart..."
        docker restart $CONTAINER_NAME_API
        #Dead container
        if [[ `docker ps -a | grep $CONTAINER_NAME_API | grep -i exit` != "" ]]; then
            echo "Dead Container....rebuilding."
            docker rm -f $CONTAINER_NAME_API
            echo `$RUN_API $PRIVATE_REPO/$IMAGE_API:$IMAGE_TAG`
        fi
    fi

    if [[ `docker ps -a | grep $CONTAINER_NAME_UI | grep -o $CONTAINER_NAME_UI` == "" ]]; then
        echo "No Container....building."
       echo `$RUN_UI $PRIVATE_REPO/$IMAGE_UI:$IMAGE_TAG`
    else
        echo "UI Container Found....Trying restart..."
        docker restart $CONTAINER_NAME_UI
        #Dead container
        if [[ `docker ps -a | grep $CONTAINER_NAME_UI | grep -i exit` != "" ]]; then
            echo "Dead Container....rebuilding."
            docker rm -f $CONTAINER_NAME_UI
            echo `$RUN_UI $PRIVATE_REPO/$IMAGE_UI:$IMAGE_TAG`
        fi
    fi
}

function stopPmx {
    echo Stopping panamax containers
    docker stop $CONTAINER_NAME_API
    docker stop $CONTAINER_NAME_UI
    echo Stopped panamax conatiners
}

function updatePmxImages {
    echo Updating Panamax...!!!
    docker pull $PRIVATE_REPO/$IMAGE_UI:$IMAGE_TAG
    docker pull $PRIVATE_REPO/$IMAGE_API:$IMAGE_TAG
    echo Panamax Image Update Complete....
}

function cleanupCoreOSContainers {
    if [[ "fleetctl list-units | grep service "  != "" ]]; then
        echo Destroying all fleet units
        units=( `fleetctl list-units | grep service | gawk '{print $1 }'` )
        for i in "${units[@]}"
        do
            fleetctl destroy $i
        done
        #fleetctl destroy  `fleetctl list-units | grep service | gawk '{print $1 }'`
    fi
    echo "Deleting Containers"
    if [[ "`docker ps -a | grep ago`" != "" ]]; then
        echo Destroying remaining docker containers
        docker stop `docker ps -a -q` && \
        docker rm `docker ps -a -q`
    fi
}

function readParams {
    for i in "$@"
    do
    case $i in
        --dev)
        IMAGE_TAG=dev
        ;;
        --stable)
        IMAGE_TAG=latest
        ;;
        install)
        operation=install
        ;;
        uninstall)
        operation=uninstall
        ;;
        stop)
        operation=stop
        ;;
        start)
        operation=restart
        ;;
        restart)
        operation=restart
        ;;
        update)
        operation=update
        ;;
        *)
        exit 1;
        ;;
    esac
    done
}

function main {
    readParams "$@"
    case $operation in
        "stop")
            stopPmx
            ;;
        "install")
            startCoreOSServices
            startPmx
            ;;
        "update")
            updatePmx
            ;;
        *)
            echo "Not Implemented"
            exit 1
            ;;
    esac

    echo "Panamax setup complete"
    exit 0
}


main "$@"

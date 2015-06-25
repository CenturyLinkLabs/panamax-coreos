#!/bin/bash

function operateDray {
 sudo systemctl $1 panamax-redis.service
 sudo systemctl $1 panamax-dray.service
}

function operatePanamax {
 operateDray $1
 sudo systemctl $1 panamax-metrics.service
 sudo systemctl $1 panamax-api.service
 sudo systemctl $1 panamax-ui.service
}

function sysd_uninstallPanamax {
    echo "Uninstalling Panamax."
    operatePanamax stop
    operatePanamax disable
    sudo rm -f $UNIT_FILES_PATH/panamax*.service
    rm -f units
}

function sysd_PanamaxComponentsInstalled {
 [[ $(docker ps -a| grep "${CONTAINER_NAME_UI}\|${CONTAINER_NAME_API}\|${CONTAINER_NAME_API}\| \
            ${CONTAINER_NAME_CADVISOR}\|${CONTAINER_NAME_DRAY_REDIS}\|${CONTAINER_NAME_DRAY}") != "" ]] && { echo "1"; } || { echo "0"; }
}

function downloadImage {
    echo ""
    echo "docker pull $1"
    docker pull $1 >/dev/null &
    PID=$!
    while $(kill -n 0 $PID 2> /dev/null)
    do
      echo -n '.'
      sleep 2
    done
}

function downloadPmxImages {
    downloadImage $REPO_URL_NAMESPACE/$IMAGE_API:$IMAGE_TAG
    downloadImage $REPO_URL_NAMESPACE/$IMAGE_UI:$IMAGE_TAG
    downloadImage $CADVISOR_IMAGE
    downloadImage $DRAY_REDIS_IMAGE
    downloadImage $DRAY_IMAGE
}

function sysd_installPanamax {
    echo "Installing Panamax..."
    curl -L $ETCD_URL | tar xz --strip-components="1" --no-anchored 'etcd'
    curl -L $FLEET_URL | tar xz --strip-components="1" --no-anchored 'fleetd'
    mv etcd /usr/local/bin/
    mv fleetd /usr/local/bin

    mkdir -p units
    rm -Rf units/*
    writeUnitFiles
    sudo cp units/* $UNIT_FILES_PATH
    downloadPmxImages
    operatePanamax enable
    operatePanamax start
    waitUntilStarted
    echo "Panamax install complete"
}


function writeUnitFiles {
 echo "[Unit]
      Description=etcd

      [Service]
      User=root
      PermissionsStartOnly=true
      Environment=ETCD_DATA_DIR=/var/lib/etcd
      Environment=ETCD_NAME=%m
      ExecStart=/usr/local/bin/etcd
      Restart=always
      RestartSec=10s
      LimitNOFILE=40000" >  units/etcd.service

 echo "[Socket]
      ListenStream=/var/run/fleet.sock"  >  units/fleet.socket

 echo  "[Unit]
      Description=fleet daemon
      Wants=etcd.service
      After=etcd.service
      Wants=fleet.socket
      After=fleet.socket

      [Service]
      ExecStart=/usr/local/bin/fleetd
      Restart=always
      RestartSec=10s"  > units/fleet.service

 echo "[Unit]
      Description=Panamax API
      After=docker.service fleet.service fleet.socket
      Requires=docker.service fleet.service fleet.socket

      [Service]
      ExecStartPre=-/usr/bin/docker rm -f $CONTAINER_NAME_API
      ExecStart=$(getRunCmdAPI)
      ExecStop=/usr/bin/docker stop $CONTAINER_NAME_API
      Restart=always

      [Install]
      WantedBy=multi-user.target" > units/panamax-api.service

 echo "[Unit]
      Description=Panamax UI
      After=panamax-api.service
      Requires=panamax-api.service

      [Service]
      ExecStartPre=-/usr/bin/docker rm -f $CONTAINER_NAME_UI
      ExecStart=$(getRunCmdUI)
      ExecStop=/usr/bin/docker stop $CONTAINER_NAME_UI
      Restart=always

      [Install]
      WantedBy=multi-user.target" > units/panamax-ui.service

  echo "[Unit]
        Description=Panamax Metrics

        [Service]
        ExecStartPre=-/usr/bin/docker rm -f $CONTAINER_NAME_CADVISOR
        ExecStart=/usr/bin/docker  run --volume=/var/run:/var/run:rw --volume=/sys:/sys:ro   \
             --volume=/var/lib/docker/:/var/lib/docker:ro  --publish=3002:8080 --name=$CONTAINER_NAME_CADVISOR  $CADVISOR_IMAGE
        ExecStop=/usr/bin/docker stop $CONTAINER_NAME_CADVISOR
        Restart=always

        [Install]
        WantedBy=multi-user.target" > units/panamax-metrics.service

 echo "[Unit]
        Description=Panamax Redis
        Before=panamax-dray.service
        After=docker.service
        [Service]
        ExecStartPre=-/usr/bin/docker rm -f $CONTAINER_NAME_DRAY_REDIS
        ExecStart=/usr/bin/docker  run --expose=6379 --name=$CONTAINER_NAME_DRAY_REDIS  $DRAY_REDIS_IMAGE
        ExecStop=/usr/bin/docker stop $CONTAINER_NAME_DRAY_REDIS
        Restart=always
        [Install]
        WantedBy=multi-user.target" > units/panamax-redis.service

echo "[Unit]
        Description=Panamax Dray
        Before=panamax-api.service
        After=docker.service panamax-redis.service
        Requires=panamax-redis.service
        [Service]
        ExecStartPre=-/usr/bin/docker rm -f $CONTAINER_NAME_DRAY
        ExecStart=/usr/bin/docker  run --link $CONTAINER_NAME_DRAY_REDIS:REDIS --volume=/var/run/docker.sock:/var/run/docker.sock:rw \
        --publish=3003:3000 --name=$CONTAINER_NAME_DRAY  $DRAY_IMAGE
        ExecStop=/usr/bin/docker stop $CONTAINER_NAME_DRAY
        Restart=always
        [Install]
        WantedBy=multi-user.target" > units/panamax-dray.service

}

function getRunCmdAPI {
    local dbMount=""
    if [[ "$PERSIST_DB" == "true" ]]; then
        dbMount="-v /var/panamax-data:/usr/src/app/db/mnt"
    fi

    docker_ip="`ifconfig docker0 2>/dev/null | grep 'inet ' | awk '{print $2}' | grep -o "[0-9]*\.[0-9]*\.[0-9]*"`"
    if [[ "$docker_ip" != "" ]]; then
        DOCKER_IP="http://$docker_ip"
    fi
    echo "/usr/bin/docker run --name $CONTAINER_NAME_API $dbMount -m=1g -c=10 \
    -v /var/run/docker.sock:/var/run/docker.sock:rw -v /var/run/fleet.sock:/var/run/fleet.sock \
    -e DRAY_PORT=$DOCKER_IP:3003 -e PANAMAX_ID=$PANAMAX_ID -e INSECURE_REGISTRY=$INSECURE_REGISTRY \
    -e JOURNAL_ENDPOINT=$DOCKER_IP:19531  -t  -p 3001:3000  $REPO_URL_NAMESPACE/$IMAGE_API:$IMAGE_TAG"
}

function getRunCmdUI {
    echo "/usr/bin/docker run --name $CONTAINER_NAME_UI -m=1g -c=10 -v /var/run/docker.sock:/var/run/docker.sock:rw \
    --link $CONTAINER_NAME_API:PMX_API  --link $CONTAINER_NAME_CADVISOR:CADVISOR -e INSECURE_REGISTRY=$INSECURE_REGISTRY -p 3000:3000  $REPO_URL_NAMESPACE/$IMAGE_UI:$IMAGE_TAG"
}

function sysd_restartPanamax {
  echo "Restarting Panamax"
  operatePanamax restart
  echo "Panamax restarted"
}

function sysd_stopPanamax {
  echo Stopping Panamax
  operatePanamax stop
  echo Panamax Stopped.
}

function sysd_updatePanamax {
    echo Updating Panamax
    sysd_uninstallPanamax
    sysd_installPanamax
    echo Panamax Updated
}

function waitUntilStarted {
    logStartTime="`date +'%Y-%m-%d %H:%M:%S'`"
    until [[ "`curl -sL -w "%{http_code}" "http://localhost:3000"  -o /dev/null`" == "200" ]];
    do
       journalctl --since="$logStartTime" | grep  'PMX\|Panamax'                     
       sleep 1
       logStartTime="`date +'%Y-%m-%d %H:%M:%S'`"
    done
}

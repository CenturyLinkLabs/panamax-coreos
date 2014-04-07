#!/bin/bash 

pmxCntUI='panamax-container-ui'
pmxCntAPI='panamax-container-api'
#pmxImgUI='panamax/panamax-ui'
#pmxImgAPI='panamax/panamax-api'
pmxSvcUI='panamax-ui.service'
pmxSvcAPI='panamax-api.service'

function operatePanamax {
    sudo fleetctl $1 $pmxSvcAPI
    sudo fleetctl $1 $pmxSvcUI
}


function installPanamax {

    sudo systemctl start etcd
    sudo systemctl start fleet

    echo "Stopping Panamax fleet if running"
    operatePanamax stop
    echo "Destroying Panamax fleet if present"
    operatePanamax destroy
    echo "Submitting Panamax fleet"
    operatePanamax submit
    echo "Starting Panamax fleet"
    operatePanamax start
}


function openPanamax {
    echo "waiting for panamax to start....."
    containersCreated=0
    until [ $containersCreated -eq 1 ]
    do
        sleep 2
        printf "#"
        if [[ ( `docker ps -a | grep $pmxCntUI | grep -o $pmxCntUI` != "" ) &&  ( `docker ps -a | grep $pmxCntAPI | grep -o $pmxCntAPI` != "" ) ]]; then
            echo "Containers Created"
            containersCreated=1
        fi
    done
}

function main {

    operation=$1
    
    if [[ $# -gt 0 ]]; then
        case $operation in
             install)
                installPanamax;
                openPanamax;
                installPanamax;
                ;;
            reinstall)
                installPanamax;
                ;;
            restart)
                stopPanamax
                startPanamax
                ;;

        esac
        
    else
        echo "Please select one of the following options: "
        select operation in "install" "restart" "reinstall"; do
        case $operation in
             install)
                installPanamax;
                openPanamax;
                installPanamax;
                ;;
            restart) restartPanamax; break;;
            reinstall) installPanamax; break;;
        esac
        done
    fi
}


main "$@";

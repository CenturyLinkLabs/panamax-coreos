#!/bin/bash 

#pmxCntUI='panamax-container-ui'
#pmxCntAPI='panamax-container-api'
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

    openPanamax
    exit 0;
}


function openPanamax {
    echo "waiting for panamax to start....."
    until [ `curl -sL -w "%{http_code}" "http://localhost:3000"  -o /dev/null` == "200" ];
    do
      sleep 2

      oldUiOutput=''
      uiOutput=`journalctl -u panamax-ui.service -r -n 1`
      echo $uiOutput
      if [[ "$uiOuput" -ne "$oldUiOutput" ]]; then
        echo $uiOutput
        $oldUiOutput=$uiOutput
      fi

      oldApiOutput=''
      apiOutput=`journalctl -u panamax-api.service -r -n 1`
      if [[ "$apiOuput" -ne "$oldApiOutput" ]]; then
        echo $apiOutput
        $oldAPiOutput=$apiOutput
      fi

    done
}

function main {

    operation=$1
    
    if [[ $# -gt 0 ]]; then
        case $operation in
            install) installPanamax; break;;
            reinstall) installPanamax; break;;
            restart)
                    stopPanamax
                    startPanamax
                    break;;

        esac
        
    else
        echo "Please select one of the following options: "
        select operation in "install" "restart" "reinstall"; do
        case $operation in
            install) installPanamax; break;;
            restart) restartPanamax; break;;
            reinstall) installPanamax; break;;
        esac
        done
    fi
}


main "$@";

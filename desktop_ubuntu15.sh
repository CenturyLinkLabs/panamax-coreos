#!/bin/bash

BASEBOX_DEFAULT="panamax-coreos-box-647.0.0"
BASEBOX_URL_DEFAULT="http://stable.release.core-os.net/amd64-usr/647.0.0/coreos_production_vagrant.box"
PMX_IMAGE_TAG_DEFAULT=stable
PMX_UI_TAGS="https://index.docker.io/v1/repositories/centurylink/panamax-ui/tags"
PMX_API_TAGS="https://index.docker.io/v1/repositories/centurylink/panamax-api/tags"
SETUP_UPDATE_URL="http://download.panamax.io/installer/.versions"
DOCUMENTATION_URL="https://github.com/CenturyLinkLabs/panamax-ui/wiki/Release-Notes"
CWD="${HOME}/.panamax"
ENV="$CWD"/.env_tmp
ENV_COMMIT="$CWD"/.env
PMX_NAME="panamax"
PMX_INSECURE_REGISTRY="n"

. "$CWD"/ubuntu_sysd.sh

echo_install="init:          First time installing Panamax! - Downloads installs latest Panamax version."
echo_restart="restart:       Stops and Starts Panamax."
echo_reinstall="reinstall:     Deletes your applications; reinstalls to latest Panamax version."
echo_update="download:      Updates to latest Panamax version."
echo_checkUpdate="check:         Checks for available updates for Panamax."
echo_info="info:          Displays version of your local panamax install."
echo_stop="pause:         Stops Panamax"
echo_start="up:            Starts Panamax"
echo_uninstall="delete:        Uninstalls Panamax."
echo_help="help:          Show this help"
echo_debug="debug:         Display your current Panamax settings."


function displayLogo {
    tput clear
    echo ""
    echo -e "\033[0;31;32m███████╗ ██████╗  █████████╗ ██████╗ \033[0m\033[31;37m ██████████╗ ██████╗  ██╗  ██╗\033[0m"
    echo -e "\033[0;31;32m██╔══██║  ╚═══██╗ ███╗  ███║  ╚═══██╗\033[0m\033[31;37m ██║ ██╔ ██║  ╚═══██╗ ╚██╗██╔╝\033[0m"
    echo -e "\033[0;31;32m██   ██║ ███████║ ███║  ███║ ███████║\033[0m\033[31;37m ██║╚██║ ██║ ███████║  ╚███╔╝ \033[0m"
    echo -e "\033[0;31;32m███████╝ ███████║ ███║  ███║ ███████║\033[0m\033[31;37m ██║╚██║ ██║ ███████║  ██╔██╗ \033[0m"
    echo -e "\033[0;31;32m██║      ███████║ ███║  ███║ ███████║\033[0m\033[31;37m ██║╚██║ ██║ ███████║ ██╔╝ ██╗\033[0m"
    echo -e "\033[0;31;32m╚═╝      ╚══════╝ ╚══╝  ╚══╝ ╚══════╝\033[0m\033[31;37m ╚═╝ ╚═╝ ╚═╝ ╚══════╝ ╚═╝  ╚═╝\033[0m"
    echo ""
    echo "CenturyLink Labs - http://www.centurylinklabs.com/"
}

function  checkPreReqs {
    while [ -n "$1" ]
    do
      command -v "$1" >/dev/null 2>&1 || { echo >&2 "'$1' is required but not installed.  Aborting; please execute $cd $CWD && ./ubuntu15_prereqs_install.sh"; exit 1; }
      if [[ "$1" == "docker" ]]; then
          docker -v | grep -w '1\.[2-9]'  >/dev/null 2>&1 || { echo "docker 1.2 or later is required but not installed. Aborting."; exit 1; }
      fi
      shift
    done
}

function checkPanamaxExists {
    if [[ "$(pmxContainersInstalled)" != "1" ]]; then
        echo -e "$PMX_NAME does not exist. Please run ($./panamax init) to install Panamax.\n"
        exit 1;
    fi
}

function getLatestVersion {
    local vs=($@)
    local arr_vs=( $(
    for tag in "${vs[@]}"
    do
        echo "$tag" | sed 's/\b\([0-9]\)\b/0\1/g'
    done | sort -r | sed 's/\b0\([0-9]\)/\1/g') )
    echo "${arr_vs[0]}"
}

function checkForSetupUpdate {
    if [[ "$checkedSetupForUpdates" != "1" || "$1" == "u" ]]; then
        checkedSetupForUpdates="1"
        updateAvailableForSetup="0"
        if [[ -f "$ENV" ]]; then
            source "$ENV"
            local vlist=`curl -sL $SETUP_UPDATE_URL | grep tar`
            local latestv==$(getLatestVersion $vlist)
            if [[ "$latestv" != "$PMX_SETUP_VERSION" ]]; then
              echo "Local Panamax Installer version:"
              echo -e "$PMX_SETUP_VERSION\n"
              echo "*** Panamax Installer is out of date! Please run ($ brew upgrade http://download.panamax.io/installer/brew/panamax.rb && panamax reinstall) to update. ***"
              updateAvailableForSetup="1"
            elif [[ "$1" == "e" ]]; then
              echo "Local Panamax Installer version:"
              echo -e "  $PMX_SETUP_VERSION\n"
            fi
        else
            echo ""
        fi
    fi
}

function checkForPanamaxUpdate {
   if [[ "$checkedPmxForUpdates" != "1" || "$1" == "u" ]]; then
       checkedPmxForUpdates="1"
       updateAvailableForPmx="0"
       if [[ -f "$ENV" ]]; then
        source "$ENV"
        if [[ "$PMX_IMAGE_TAG" == "dev" ]]; then
            if [[ "$PMX_INSTALL_DATE" -le "` date -j -v-1d +%s`" ]]; then
                echo "You are currently running a Dev version of Panamax which is updated nightly."
                echo "A newer Dev version is available. Use the update option to get the latest Dev version."
                updateAvailableForPmx="1"
            elif [[ "$1" == "e" ]]; then
                echo "Local Panamax component versions:"
                echo "   UI: dev nightly build"
                echo "  API: dev nightly build"
            fi

        elif [[ "$PMX_INSTALL_TAG_UI" != "" || "$PMX_INSTALL_TAG_API" != "" || "$1" == "e" ]]; then
            latestTagUi="`getLatestVersion $PMX_INSTALL_TAG_UI \"$(getDockerTags $PMX_UI_TAGS)\"`"
            latestTagApi="`getLatestVersion $PMX_INSTALL_TAG_API \"$(getDockerTags $PMX_API_TAGS)\"`"
            if [[ "$PMX_INSTALL_TAG_UI" != "$latestTagUi" || "$PMX_INSTALL_TAG_API" != "$latestTagApi" ]]; then
                echo "Local Panamax component versions:"
                echo "   UI: $PMX_INSTALL_TAG_UI"
                echo "  API: $PMX_INSTALL_TAG_API"
                echo "Latest Panamax component versions:"
                echo "   UI: $latestTagUi"
                echo "  API: $latestTagApi"
                echo ""
                echo "*** Panamax is out of date! Please use the download/update option to get the latest. Release notes are available at ($DOCUMENTATION_URL) . ***"
                echo ""
                updateAvailableForPmx="1"
            elif [[ "$1" == "e" ]]; then
                echo "Local Panamax component versions:"
                echo "   UI: $PMX_INSTALL_TAG_UI"
                echo "  API: $PMX_INSTALL_TAG_API"
            fi
        fi
      else
        echo ""
      fi
   fi
}

function getPanamaxSetupVersion {
    echo "\"$(<"$CWD.version")\""
    exit 0;
}

function checkForUpdate {
    if [[ "$1" == "e" || "$1" == "u" ]]; then
         curl docker
        checkPanamaxExists
    fi
    echo ""
    checkForPanamaxUpdate "$1"
    checkForSetupUpdate "$1"
    if [[ "$1" == "u" && $updateAvailableForSetup == "0" && $updateAvailableForPmx == "0" ]]; then
        echo "Panamax is already up to date!"
    fi
    echo ""
}

function getDockerTags {
    echo `curl --silent $1  | grep -o "[0-9]*\.[0-9]*\.[0-9]*"  | awk '{ print $1}'`
}

function saveVersionInfo {
    setEnvVar "PMX_SETUP_VERSION" "\"$(<"$CWD\.version")\""
    setEnvVar "PMX_INSTALL_DATE" "\"`date +%s`\""
    if [[ "$PMX_IMAGE_TAG" == "stable" ]]; then
        setEnvVar "PMX_INSTALL_TAG_UI" "`getLatestVersion  \"$(getDockerTags $PMX_UI_TAGS)\"`"
        setEnvVar "PMX_INSTALL_TAG_API" "`getLatestVersion  \"$(getDockerTags $PMX_API_TAGS)\"`"
    fi
    setEnvVar "PMX_IMAGE_TAG" "$PMX_IMAGE_TAG"
}

function pmxContainersInstalled {
   echo "$(sysd_PanamaxComponentsInstalled)"
}

function installPanamax {
    echo "" > $ENV
    source $ENV

    if [[ "$operation" == "install"  &&  "$(pmxContainersInstalled)" == "1"  ]]; then
        echo "Some components of $PMX_NAME have been created already. Please re-install or delete $PMX_NAME and try again."
        exit 1;
    fi

    if [[ "$operation" == "reinstall" && "$(pmxContainersInstalled)" == "0"  ]]; then
        echo "$PMX_NAME is not installed. Please run ./panamax and select init."
        exit 1;
    fi

    if [[ $# == 0 ]]; then
        echo ""
        read -p "Enter version you want to use(dev/stable, defaults to:$PMX_IMAGE_TAG_DEFAULT)" panamaxVersion
        read -p "Do you want to let Docker daemon allow connections to insecure registries [y/N]: " pmxInsecureRegistry
        echo ""
    fi

    pmxInsecureRegistry=${pmxInsecureRegistry:-$PMX_INSECURE_REGISTRY}
    PMX_IMAGE_TAG=${panamaxVersion:-${PMX_IMAGE_TAG:-$PMX_IMAGE_TAG_DEFAULT}}

    if [ ! -d "$CWD" ]; then
        mkdir -p "$CWD"
        cp -Rf . "$CWD" > /dev/null
    fi
    
    if [[ "$PMX_PANAMAX_ID" == "" ]]; then
        PMX_PANAMAX_ID="`uuidgen`"
    fi

    saveVersionInfo
    setEnvVar "PMX_OPERATION" "$operation"
    setEnvVar "PMX_NAME" "$PMX_NAME"
    setEnvVar "PMX_PANAMAX_ID" \"${PMX_PANAMAX_ID}\"
    setEnvVar "PMX_INSECURE_REGISTRY" "$pmxInsecureRegistry"
    source "$ENV"

    if [[  $operation == "reinstall" ]]; then
        echo ""
        echo "Reinstalling Panamax..."
        sysd_installPanamax
    else
        sysd_installPanamax
    fi
    openPanamax;
}

function setEnvVar {
    local envVarName=`echo "$1" | sed 's/[PMX_]+//g'`
    echo $"`sed  "/$envVarName=/d" "$ENV"`" > "$ENV"
    echo export $1=$2 >> "$ENV"
}

function openPanamax {
    echo "waiting for panamax to start....."
    local pmxUrl="http://localhost:3000"
    until [ `curl -sL -w "%{http_code}" "${pmxUrl}"   -o /dev/null` == "200" ];
    do
      printf .
      sleep 2
    done

    echo ""
    open "${pmxUrl}" || { echo "Please go to ${pmxUrl}" to access panamax; }
    echo "Please go to ${pmxUrl} to access panamax."
    echo ""
    echo ""
}

function getContainerNames {
    echo $CONTAINER_NAME_UI  $CONTAINER_NAME_API  $CONTAINER_NAME_CADVISOR  $CONTAINER_NAME_DRAY_REDIS $CONTAINER_NAME_DRAY
}

function restartPanamax {
    checkPanamaxExists
    echo Restarting Panamax
    setEnvVar "PMX_OPERATION" "$operation"
    source "$ENV"
    sysd_restartPanamax
    openPanamax;
    echo Restart complete
}

function startPanamax {
    checkPanamaxExists
    echo Starting Panamax
    setEnvVar "PMX_OPERATION" "$operation"
    source "$ENV"
    sysd_restartPanamax
    openPanamax
    echo Start Complete
}

function stopPanamax {
    
    checkPanamaxExists
    echo Stopping Panamax
    setEnvVar "PMX_OPERATION" "$operation"
    source "$ENV"
    sysd_stopPanamax
    echo Panamax stopped.
}

function updatePanamax {
    
    checkPanamaxExists
    setEnvVar "PMX_OPERATION" "$operation"
    setEnvVar "PMX_IMAGE_TAG" "$PMX_IMAGE_TAG"
    source "$ENV"
    checkForPanamaxUpdate
    if [[ $updateAvailableForPmx == "1" ]]; then
        echo Updating Panamax
        sysd_updatePanamax
        openPanamax
        saveVersionInfo
        checkForSetupUpdate
        echo Update Complete
    else
        echo "Panamax is already up to date."
    fi
}

function uninstallPanamax {
    checkPanamaxExists
    setEnvVar "PMX_OPERATION" "$operation"
    echo Uninstalling Panamax
    sysd_uninstallPanamax
    echo Uninstall complete.
}

function debug {
  checkPanamaxExists
  echo "Printing current env settings..."
  sed 's/export //g' $ENV
}

function showShortHelp {
    echo "panamax {init|up|pause|restart|info|check|download|reinstall|delete|help} [-ppUi=<panamax UI port>] [-ppApi=<panamax API port>] [--dev|stable] [-Id=y|n] [-sp=<sudo password>] [--memory=1536] [--cpu=2]"
    echo ""
}

function showLongHelp {
    showShortHelp
    echo ""
    echo $'\n' $'\n' "$echo_install" $'\n' "$echo_stop" $'\n' "$echo_start" $'\n' "$echo_restart" $'\n' "$echo_reinstall" $'\n' "$echo_info" $'\n' "$echo_checkUpdate" $'\n' "$echo_update" $'\n' "$echo_uninstall" $'\n' "$echo_help"
    echo ""
}

function readParams {
    for i in "$@"
    do
    case `echo $i | tr '[:upper:]' '[:lower:]'` in
        --dev)
        PMX_IMAGE_TAG=dev;;
        --stable)
        PMX_IMAGE_TAG=stable;;
        install|init)
        operation=install;;
        uninstall|delete)
        operation=uninstall;;
        stop|pause)
        operation=stop;;
        start|up)
        operation=start;;
        restart)
        operation=restart;;
        update|download)
        operation=update;;
        check)
        operation=check;;
        info|--version|-v)
        operation=info;;
        reinstall)
        operation=reinstall;;
        debug)
        operation=debug;;
        -op=*|--operation=*)
        operation="${i#*=}";;
        -ld=*|--localdomain=*)
        localDomain="${i#*=}";;
        -sp=*|--sudopassword=*)
        sudoPassword="${i#*=}";;
        --help|-h|help)
        showLongHelp;
        exit 1;;
        -sv)
        getPanamaxSetupVersion;;
        --insecure-registry)
        pmxInsecureRegistry="y";;
        *)
        showLongHelp;
        exit 1;;
    esac
    done
}

function main {
    checkPreReqs curl docker bc

    if [[ ! -f "$CWD" ]]; then
        mkdir -p "$CWD"
    fi

    source "$CWD"/.pmx_container_env

    if [[ -f "$ENV_COMMIT" ]]; then
        cp "$ENV_COMMIT" "$ENV"
        source "$ENV"
    else
        rm -f "$ENV"
        touch "$ENV"
    fi

    if [[ "$1" != "-sv" ]]; then
        displayLogo
    fi

    readParams "$@"

    if [[ $# -gt 0 ]]; then
        case $operation in
            install)   installPanamax "$@" || { showHelp; exit 1; } ;;
            reinstall)   installPanamax "$@" || { showHelp; exit 1; } ;;
            restart) restartPanamax;;
            stop) stopPanamax;;
            start) startPanamax;;
            check) checkForUpdate "u";;
            info) checkForUpdate "e";;
            update) updatePanamax;;
            uninstall) uninstallPanamax;;
            debug) debug;;
            *) showLongHelp;;
        esac
    
    else
        PS3="Please select one of the preceding options: "
        select operation in "$echo_install" "$echo_stop" "$echo_start" "$echo_restart" "$echo_reinstall" "$echo_info" "$echo_checkUpdate" "$echo_update" "$echo_uninstall" "$echo_help" "$echo_debug" "quit"; do
        case $operation in
            "$echo_install") operation="install";  installPanamax; break;;
            "$echo_reinstall") operation="reinstall"; installPanamax; break;;
            "$echo_restart") operation="restart"; restartPanamax; break;;
            "$echo_start") operation="start"; startPanamax; break;;
            "$echo_stop") operation="stop"; stopPanamax; break;;
            "$echo_checkUpdate") operation="check"; checkForUpdate "u"; break;;
            "$echo_info")operation="info"; checkForUpdate "e"; break;;
            "$echo_update") operation="update"; updatePanamax; break;;
            "$echo_uninstall") operation="uninstall"; uninstallPanamax; break;;
            "$echo_help")showLongHelp; break;;
            "$echo_debug") debug; break;;
            quit) exit 0;;
        esac
        done
    fi
    checkForUpdate
    mv "$ENV" "$ENV_COMMIT"
    exit 0;
}

main "$@";

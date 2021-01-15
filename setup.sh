#!/bin/bash

if [ -z "$LAB_NAME" ]
then
    echo "Missing LAB_NAME environment variable"
    exit 1
fi

if [ -z "$DYNATRACE_ENVIRONMENT_ID" ]
then
    echo "Missing DYNATRACE_ENVIRONMENT_ID environment variable"
    exit 1
fi

if [ -z "$DYNATRACE_TOKEN" ]
then
    echo "Missing DYNATRACE_TOKEN environment variable"
    exit 1
fi

copy_k8() {
    echo "----------------------------------------------------"
    echo "Start copy_k8()"
    echo "----------------------------------------------------"
    mkdir -p scripts

    echo "copy k8 files"
    git clone https://github.com/dt-orders/overview.git
    cp -r overview/k8/ scripts/ 
    rm -rf overview/
    echo "----------------------------------------------------"
    echo "End copy_k8()"
    echo "----------------------------------------------------"
}

start_k8() {
    echo "----------------------------------------------------"
    echo "Start start_k8()"
    echo "----------------------------------------------------"
    
    echo "Starting app"
    . scripts/start-app.sh

    echo "Waiting 30 seconds for app to come up"
    sleep 30

    echo "kubectl -n dt-orders get pods"
    kubectl -n dt-orders get pods

    echo "kubectl -n dt-orders get svc"
    kubectl -n dt-orders get svc

    echo "Starting load traffic"
    . scripts/start-load.sh

    echo "Starting browser traffic"
    . scripts/start-browser.sh

    sleep 10
    echo "kubectl -n dt-orders get pods"
    kubectl -n dt-orders get pods

    echo "----------------------------------------------------"
    echo "End start_k8()"
    echo "----------------------------------------------------"
}

get_monaco() {
    echo "----------------------------------------------------"
    echo "Start get_monaco()"
    echo "----------------------------------------------------"
    if [ $(uname -s) == "Darwin" ]
    then
        MONACO_BINARY="v1.1.0/monaco-darwin-10.6-amd64"
    else
        MONACO_BINARY="v1.1.0/monaco-linux-amd64"
    fi
    echo "Getting MONACO_BINARY = $MONACO_BINARY"
    wget -q -O monaco https://github.com/dynatrace-oss/dynatrace-monitoring-as-code/releases/download/$MONACO_BINARY
    chmod +x monaco
    sudo mv ./monaco /usr/local/bin/
    echo "Installed monaco version: $(monaco --version)"
    echo "----------------------------------------------------"
    echo "End get_monaco()"
    echo "----------------------------------------------------"
}

setup_dynatrace() {
    echo "----------------------------------------------------"
    echo "Start setup_dynatrace()"
    echo "----------------------------------------------------"
    echo "set the environment variables setup scripts expect"
    export DT_BASEURL="https://$DYNATRACE_ENVIRONMENT_ID.sprint.dynatracelabs.com"
    export DT_API_TOKEN=$DYNATRACE_TOKEN
    echo "  DT_BASEURL   : $DT_BASEURL"
    echo "  DT_API_TOKEN : $DT_API_TOKEN"

    echo "Calling createDynatraceConfig.sh"
    cd dynatrace
    ./createDynatraceConfig.sh
    cd ..

    echo "----------------------------------------------------"
    echo "End  setup_dynatrace()"
    echo "----------------------------------------------------"
}

copy_docker() {
    echo "----------------------------------------------------"
    echo "Start copy_docker()"
    echo "----------------------------------------------------"
    mkdir -p scripts

    echo "copy docker compose files"
    git clone https://github.com/dt-orders/overview.git
    cp overview/docker-compose/docker-compose-monolith.yaml scripts/docker-compose-monolith.yaml
    rm -rf overview/

    echo "copy browser files"
    git clone https://github.com/dt-orders/browser-traffic.git
    cp browser-traffic/run.sh scripts/run-browser-traffic.sh
    rm -rf browser-traffic/

    echo "copy load files"
    git clone https://github.com/dt-orders/load-traffic.git
    cp load-traffic/run.sh scripts/run-load-traffic.sh
    rm -rf load-traffic/
    echo "----------------------------------------------------"
    echo "End copy_docker()"
    echo "----------------------------------------------------"
}

start_docker() {
    echo "----------------------------------------------------"
    echo "Start start_docker()"
    echo "----------------------------------------------------"
    PUBLIC_IP=$(curl -s http://checkip.amazonaws.com/)
    
    echo "Starting docker-compose"
    sudo docker-compose -f scripts/docker-compose-monolith.yaml up -d

    echo "Waiting 30 seconds for app to come up"
    sleep 30

    echo "Starting browser traffic on: $PUBLIC_IP"
    sudo . scripts/run-browser-traffic.sh $PUBLIC_IP 10000

    echo "Starting load traffic"
    sudo . scripts/run-load-traffic.sh 172.17.0.1 80 100000

    sleep 10
    echo "docker ps"
    sudo docker ps

    echo "----------------------------------------------------"
    echo "End start_docker()"
    echo "----------------------------------------------------"
}

case "$LAB_NAME" in
    "monolith") 
        clear
        echo "===================================================="
        echo "Setting up: monolith" 
        echo "===================================================="
        copy_docker
        start_docker
        ;;
    "bastion") 
        clear
        echo "===================================================="
        echo "Setting up: bastion" 
        echo "===================================================="
        #get_monaco
        setup_dynatrace
        copy_k8
        #start_k8 
        ;;
    *) 
        echo "Missing or invalid LAB_NAME environment variable"
        echo "Must be 'monolith' or 'bastion'" 
        exit 1
        ;;
esac

echo "===================================================="
echo "Setup Complete" 
echo "===================================================="
echo ""
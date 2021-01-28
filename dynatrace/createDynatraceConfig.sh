#!/bin/bash

# this will read in creds.json and export URL and TOKEN as environment variables
source ./dynatraceConfig.lib

echo ""
echo "-----------------------------------------------------------------------------------"
echo "Setting up Dynatrace config"
echo "-----------------------------------------------------------------------------------"
echo ""

# custom API calls
addConfig v2 slo "K8-Error-Rate-SLO" ./custom/k8-slo.json
addConfig v2 slo "Monolith-Error-Rate-SLO" ./custom/monolith-slo.json

setFrequentIssueDetectionOff

# run monaco configuration
if [ -x "$(command -v monaco)" ]; then
    # add the -dry-run argument to test
    #monaco -dry-run --environments ./monaco/environments.yaml --project workshop ./monaco/projects
    echo "Running monaco version: $(monaco --version)"
    monaco --environments ./monaco/environments.yaml --project workshop ./monaco/projects
else
    echo "ERROR: missing monaco"
fi

echo ""
echo "-----------------------------------------------------------------------------------"
echo "Done Setting up Dynatrace config"
echo "-----------------------------------------------------------------------------------"

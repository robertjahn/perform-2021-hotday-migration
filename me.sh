#!/bin/bash

echo ""
echo "===================================================="
echo "LAB_NAME                 : $LAB_NAME"
echo "DYNATRACE_ENVIRONMENT_ID : $DYNATRACE_ENVIRONMENT_ID"
echo "DYNATRACE_TOKEN          : $DYNATRACE_TOKEN"
echo "Public IP                : $(curl -s http://checkip.amazonaws.com/)"
echo "hostname                 : $(hostname)"
echo "whoami                   : $(whoami)"
echo "==================================================="
echo ""
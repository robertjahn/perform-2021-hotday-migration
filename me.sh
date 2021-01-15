#!/bin/bash

echo ""
echo "===================================================="
echo "Lab Name  : $(LAB_NAME)"
echo "Public IP : $(curl -s http://checkip.amazonaws.com/)"
echo "Hostname  : $(hostname)"
echo "Who am I  : $(whoami)"
echo "==================================================="
echo ""
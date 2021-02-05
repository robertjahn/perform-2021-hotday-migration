#!/bin/bash

# reference: https://www.dynatrace.com/support/help/dynatrace-api/environment-api/events/post-event/

if [ -z "$1" ]
then
    APP_TAG="monolith"
else
    APP_TAG="$1"
fi

# these were set by DTU
if [ -z "$DYNATRACE_ENVIRONMENT_ID" ]
then
    echo "Missing DYNATRACE_ENVIRONMENT_ID environment variable"
    exit 1
fi

# these were set by DTU
if [ -z "$DYNATRACE_TOKEN" ]
then
    echo "Missing DYNATRACE_TOKEN environment variable"
    exit 1
fi

DT_BASEURL="https://$DYNATRACE_ENVIRONMENT_ID.sprint.dynatracelabs.com"
DT_API_TOKEN=$DYNATRACE_TOKEN
DT_API_URL="$DT_BASEURL/api/v1/events"

DEPLOYMENT_NAME="My Deployment"
DEPLOYMENT_VERSION="My Version"
DEPLOYMENT_PROJECT="My Project"
CI_BACK_LINK="https://www.dynatrace.com"

echo "================================================================="
echo "Dynatrace Deployment event:"
echo ""
echo "DT_API_URL                 = $DT_API_URL"
echo "DEPLOYMENT_NAME            = $DEPLOYMENT_NAME"
echo "DEPLOYMENT_VERSION         = $DEPLOYMENT_VERSION"
echo "DEPLOYMENT_PROJECT         = $DEPLOYMENT_PROJECT"
echo "CI_BACK_LINK               = $CI_BACK_LINK"
echo "APP_TAG                    = $APP_TAG"
echo "================================================================="
POST_DATA=$(cat <<EOF
    {
        "eventType" : "CUSTOM_DEPLOYMENT",
        "source" : "push-dt-deployment-event.sh" ,
        "deploymentName" : "$DEPLOYMENT_NAME",
        "deploymentVersion" : "$DEPLOYMENT_VERSION"  ,
        "deploymentProject" : "$DEPLOYMENT_PROJECT" ,
        "ciBackLink" : "$CI_BACK_LINK",
        "customProperties": {
            "custom1" : "My Custom Value 1",
            "custom2" : "My Custom Value 2",
            "custom3" : "My Custom Value 3"
        },
        "attachRules" : {
               "tagRule" : [
                   {
                        "meTypes":"SERVICE" ,
                        "tags" : [
                            {
                                "context" : "CONTEXTLESS",
                                "key": "app",
                                "value" : "$APP_TAG"    
                            }
                            ]
                   }
                   ]
        }
    }
EOF)
echo $POST_DATA
curl --url "$DT_API_URL" -H "Content-type: application/json" -H "Authorization: Api-Token "$DT_API_TOKEN -X POST -d "$POST_DATA"

echo ""
echo ""

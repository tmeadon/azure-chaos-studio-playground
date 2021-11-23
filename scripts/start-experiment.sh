#!/bin/sh

RESOURCE_GROUP=$1
EXPERIMENT_NAME=$2

# get the resource id for the experiment and construct the start rest api url
EXPERIMENT_ID=$(az resource show -n $EXPERIMENT_NAME -g $RESOURCE_GROUP --resource-type Microsoft.Chaos/experiments --query id -o tsv)
START_URL="https://management.azure.com${EXPERIMENT_ID}/start?api-version=2021-09-15-preview"

# start the experiment and capture the status url
STATUS_URL=$(az rest --method post --uri $START_URL --body '{}' --query statusUrl --output tsv)
STATUS=""

# wait for the experiment to transition to 'running' 
while [ "$STATUS" != "Running" ]
do
    STATUS=$(az rest --method get --uri $STATUS_URL --query properties.status --output tsv)
    echo "Experiment status: ${STATUS}"
    sleep 5
done
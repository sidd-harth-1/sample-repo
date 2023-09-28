#!/bin/bash
OWNER=$1
REPO=$2
BRANCH=$3
WORKFLOW_NAME=$4


# Get the workflow YAML content
wget -c -q -O workflow.yml https://raw.githubusercontent.com/$OWNER/$REPO/$BRANCH/.github/workflows/$WORKFLOW_NAME

# Validate the workflow YAML
#Check if the workflow has two jobs named testing and deployment
if ! (yq '.jobs | keys' workflow.yml  |  grep -q 'testing') && (yq '.jobs | keys' workflow.yml |  grep -q 'deploying'); then
echo "The workflow does not have two jobs named testing and deployment."
exit 1
fi

# #Check if the testing job has the on-error-continue property set to true
if ! yq eval '.jobs.testing.continue-on-error'  workflow.yml | grep -v "null"; then
echo "ERROR: The testing job does not have the on-error-continue property"
exit 1
fi

# The workflow is valid
echo "The workflow is valid."
exit 0
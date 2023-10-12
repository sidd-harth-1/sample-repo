#!/bin/bash
OWNER=$1
REPO=$2
BRANCH=$3
WORKFLOW_NAME=$4

#  Get the workflow YAML content
WORKFLOW_YAML=$(curl -X GET  -sk -H "Accept: application/vnd.github+json" \
https://raw.githubusercontent.com/$OWNER/$REPO/$BRANCH/.github/workflows/$WORKFLOW_NAME?token=$(date +%s))

# Check if the workflow has two jobs named testing and deployment
if ! (yq '.jobs | keys' <<< $WORKFLOW_YAML  |  grep -q 'testing') && (yq '.jobs | keys' <<< $WORKFLOW_YAML |  grep -q 'deploying'); then
echo "The workflow does not have two jobs named testing and deployment."
exit 1
fi

# Check if the testing job has the continue-on-error property
if ! yq eval '.jobs.testing.continue-on-error' <<< $WORKFLOW_YAML | grep -v "null"; then
echo "ERROR: The testing job does not have the continue-on-error property"
exit 1
fi

echo "The workflow Passed all the tests"
exit 0

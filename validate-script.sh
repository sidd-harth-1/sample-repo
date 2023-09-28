#!/bin/bash
OWNER=$1
REPO=$2
WORKFLOW_NAME=$3

# Get the workflow YAML content
WORKFLOW_YAML=$(curl -X GET  -s -H "Accept: application/vnd.github+json" \
https://api.github.com/repos/$OWNER/$REPO/contents/.github/workflows/$WORKFLOW_NAME)

# Validate the workflow YAML
#Check if the workflow has two jobs named testing and deployment
if ! yq e '.jobs[].name | @unique | @contains(["testing", "deployment"])' "$WORKFLOW_YAML" | grep -q "true"; then
echo "The workflow does not have two jobs named testing and deployment."
exit 1
fi

#Check if the testing job has the on-error-continue property set to true
if ! yq e '.jobs? | select(.name == "testing") | .on-error-continue' "$WORKFLOW_YAML" | grep -q "true"; then
echo "The testing job does not have the on-error-continue property set to true."
exit 1
fi

# The workflow is valid
echo "The workflow is valid."
exit 0
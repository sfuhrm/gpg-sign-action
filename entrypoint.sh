#!/bin/sh -l

echo "Reading artifact ${INPUT_ARTIFACT_VAR}"

##
## https://docs.github.com/en/rest/actions/artifacts?apiVersion=2022-11-28
##
gh api \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/${REPO_OWNER_VAR}/actions/artifacts/${INPUT_ARTIFACT_VAR} > input_artifact.json

ARCHIVE_URL=$(jq -r .archive_download_url < input_artifact.json)

echo "Archive URL: ${ARCHIVE_URL}"

gh api \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/${REPO_OWNER_VAR}/actions/artifacts/${INPUT_ARTIFACT_VAR}/zip > input.zip

echo "Listing"
zip -t input.zip

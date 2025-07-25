#!/bin/bash
set -eufo pipefail

# This script generates two files:
#   - .commit_sha
#   - .docker_tag
#
# By default, this script grabs the full commit sha of the HEAD of master of the
# graphite-project/graphite-web repo. That value is dropped into `.commit_sha`. It then
# generates a docker tag from that full commit sha and drops that value into
# `.docker_tag`.

# Check dependencies
command -v git >/dev/null 2>&1 || { echo "git is not installed"; exit 1; }
if [[ ${OSTYPE:-notdarwin} == "darwin"* ]]; then
  command -v gdate >/dev/null 2>&1 || { echo "gdate is not installed"; exit 1; }
else
  command -v date >/dev/null 2>&1 || { echo "date is not installed"; exit 1; }
fi

# Grab graphite-project/graphite-web repo
TMPFILE=$(mktemp -d)
git clone https://github.com/graphite-project/graphite-web.git $TMPFILE

# Jump into the cloned repo
pushd $TMPFILE

# Grab full and short commit shas
COMMIT_SHA=$(git rev-parse HEAD | tr -d '\n')
GIT_COMMIT_SHORT="$(git rev-parse --short "$COMMIT_SHA")"

# Grab timestamp of commit
UNIX_TIMESTAMP=$(git show -s --format=%ct "$COMMIT_SHA")
if [[ ${OSTYPE:-notdarwin} == "darwin"* ]]; then
  ISO_TIMESTAMP=$(gdate -u --rfc-3339=seconds "-d@${UNIX_TIMESTAMP}" | sed "s/+.*$//g" | sed "s/[^0-9]*//g")
else
  ISO_TIMESTAMP=$(date -u --rfc-3339=seconds "-d@${UNIX_TIMESTAMP}" | sed "s/+.*$//g" | sed "s/[^0-9]*//g")
fi

# Jump back out
popd

# Get current repo commit SHA
GRAPHITE_MT_SHA=$(git rev-parse HEAD | tr -d '\n')
GRAPHITE_MT_SHORT="$(git rev-parse --short "$GRAPHITE_MT_SHA")"

# Generate docker tag with both SHAs
DOCKER_TAG=$(echo "${ISO_TIMESTAMP}-${GIT_COMMIT_SHORT}-${GRAPHITE_MT_SHORT}" | tr "/" "_")

# Generate output files
echo $COMMIT_SHA > .commit_sha
echo $DOCKER_TAG > .docker_tag

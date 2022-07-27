#!/bin/bash
set -x

# This script generates two files:
#   - .commit_sha
#   - .docker_tag
#
# By default, this script grabs the full commit sha of the HEAD of master of the
# grafana/graphite-web repo. That value is dropped into `.commit_sha`. It then
# generates a docker tag from that full commit sha and drops that value into
# `.docker_tag`.

# Check dependencies
command -v git >/dev/null 2>&1 || { echo "git is not installed"; exit 1; }
if [[ ${OSTYPE:-notdarwin} == "darwin"* ]]; then
  command -v gdate >/dev/null 2>&1 || { echo "gdate is not installed"; exit 1; }
else
  command -v date >/dev/null 2>&1 || { echo "date is not installed"; exit 1; }
fi

# Grab grafana/graphite-web repo
TMPFILE=$(mktemp -d)
git clone https://github.com/grafana/graphite-web.git $TMPFILE

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

# Generate docker tag
DOCKER_TAG=$(echo "${ISO_TIMESTAMP}-master-${GIT_COMMIT_SHORT}" | tr "/" "_")

# Jump back out
popd

# Generate output files
echo $COMMIT_SHA > .commit_sha
echo $DOCKER_TAG > .docker_tag

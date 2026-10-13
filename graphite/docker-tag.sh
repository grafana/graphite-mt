#!/bin/bash
set -eufo pipefail

# This script generates two files:
#   - .commit_sha
#   - .docker_tag
#
# By default, this script grabs the full commit sha of the HEAD of master of the
# graphite-project/graphite-web repo. That value is dropped into `.commit_sha`. It then
# generates a docker tag from this repo's commit time and both commit shas and
# drops that value into `.docker_tag`.

# Check dependencies
command -v git >/dev/null 2>&1 || { echo "git is not installed"; exit 1; }

# Grab graphite-project/graphite-web repo
TMPFILE=$(mktemp -d)
git clone https://github.com/graphite-project/graphite-web.git $TMPFILE

# Jump into the cloned repo
pushd $TMPFILE

# Grab full and short commit shas
COMMIT_SHA=$(git rev-parse HEAD | tr -d '\n')
GRAPHITE_WEB_COMMIT_SHORT="$(git rev-parse --short "$COMMIT_SHA")"

# Jump back out
popd

# Get current repo commit SHA
GRAPHITE_MT_SHA=$(git rev-parse HEAD | tr -d '\n')
GRAPHITE_MT_BRANCH=$(git branch --show-current)
GRAPHITE_MT_SHORT="$(git rev-parse --short "$GRAPHITE_MT_SHA")"

WORKING_SUFFIX=$(if [ -n "$(git status --porcelain --untracked-files=no)" ]; then echo "-WIP"; else echo ""; fi)
# Commit time of this repo comes first so newer images sort after older ones
GRAPHITE_MT_TIMESTAMP=$(TZ=UTC git show -s --date=format-local:%Y%m%d%H%M%S --format=%cd "$GRAPHITE_MT_SHA")
# Generate docker tag with both SHAs
DOCKER_TAG=$(echo "${GRAPHITE_MT_TIMESTAMP}-${GRAPHITE_WEB_COMMIT_SHORT}-${GRAPHITE_MT_BRANCH}-${GRAPHITE_MT_SHORT}${WORKING_SUFFIX}" | tr "/" "_")

# Generate output files
echo $COMMIT_SHA > .commit_sha
echo $DOCKER_TAG > .docker_tag

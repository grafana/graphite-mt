#!/bin/bash
set -euo pipefail

command -v docker >/dev/null 2>&1 || { echo "docker is not installed"; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "curl is not installed"; exit 1; }

IMAGE_TAG=$(cat .docker_tag)
IMAGE_NAME="us.gcr.io/kubernetes-dev/graphite-mt:${IMAGE_TAG}"
CONTAINER_NAME="graphite-mt-test-$$"
PASS=0
FAIL=0

cleanup() {
    docker stop "${CONTAINER_NAME}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "Testing ${IMAGE_NAME}"
echo ""

docker run --rm -d -p "127.0.0.1::80" --name "${CONTAINER_NAME}" "${IMAGE_NAME}" >/dev/null
PORT=$(docker port "${CONTAINER_NAME}" 80 | cut -d: -f2)
BASE="http://127.0.0.1:${PORT}"

echo -n "Waiting for container to be ready..."
for i in $(seq 1 30); do
    if curl -sf -o /dev/null -H "Host: graphite" "${BASE}/version" 2>/dev/null; then
        echo " ready"
        break
    fi
    echo -n "."
    sleep 1
    if [ "${i}" -eq 30 ]; then
        echo " timed out"
        docker logs "${CONTAINER_NAME}" >&2
        exit 1
    fi
done
echo ""

check_status() {
    local desc="$1"
    local got="$2"
    local expected="$3"
    if [ "${got}" = "${expected}" ]; then
        echo "  PASS  ${desc}"
        PASS=$((PASS + 1))
    else
        echo "  FAIL  ${desc} (expected ${expected}, got ${got})"
        FAIL=$((FAIL + 1))
    fi
}

check_contains() {
    local desc="$1"
    local body="$2"
    local needle="$3"
    if echo "${body}" | grep -qF "${needle}"; then
        echo "  PASS  ${desc}"
        PASS=$((PASS + 1))
    else
        echo "  FAIL  ${desc} (expected to find: ${needle})"
        echo "        got: ${body:0:120}"
        FAIL=$((FAIL + 1))
    fi
}

STATUS=$(curl -s -o /dev/null -w "%{http_code}" -H "Host: graphite" "${BASE}/")
check_status "GET / returns 200" "${STATUS}" "200"

BODY=$(curl -s -H "Host: graphite" "${BASE}/version")
check_contains "GET /version returns version string" "${BODY}" "1."

BODY=$(curl -s -H "Host: graphite" "${BASE}/render?target=randomWalkFunction('test')&from=-1h&format=json")
check_contains "GET /render randomWalkFunction - has datapoints" "${BODY}" '"datapoints"'
check_contains "GET /render randomWalkFunction - correct target name" "${BODY}" '"target": "test"'

STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Host: graphite" \
    "${BASE}/render?target=constantLine(42)&from=-1h&format=png")
check_status "GET /render constantLine PNG returns 200" "${STATUS}" "200"

CTYPE=$(curl -s -o /dev/null -w "%{content_type}" \
    -H "Host: graphite" \
    "${BASE}/render?target=constantLine(42)&from=-1h&format=png")
check_status "GET /render constantLine PNG content-type is image/png" "${CTYPE}" "image/png"

BODY=$(curl -s -H "Host: graphite" \
    "${BASE}/render?target=sumSeries(randomWalkFunction('a'),constantLine(10))&from=-30min&format=json")
check_contains "GET /render sumSeries - has datapoints" "${BODY}" '"datapoints"'

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
[ "${FAIL}" -eq 0 ]

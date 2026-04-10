#!/usr/bin/env bash
set -euo pipefail
IMAGE="${NPS_TEST_IMAGE:-nopaystation-scripts-container:test}"
docker build -t "$IMAGE" "$(dirname "$0")/.."
container-structure-test test --image "$IMAGE" --config "$(dirname "$0")/structure-tests.yaml"

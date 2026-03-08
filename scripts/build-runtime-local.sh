#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

IMAGE_TAG="${IMAGE_TAG:-homelab-openclaw-runtime:local}"
OPENCLAW_VERSION="${OPENCLAW_VERSION:-2026.3.7-amd64}"

echo "Building ${IMAGE_TAG} (OPENCLAW_VERSION=${OPENCLAW_VERSION})"

docker build \
  --platform linux/amd64 \
  --file "${REPO_ROOT}/Dockerfile" \
  --build-arg "OPENCLAW_VERSION=${OPENCLAW_VERSION}" \
  --tag "${IMAGE_TAG}" \
  "${REPO_ROOT}"

echo "Build complete: ${IMAGE_TAG}"
echo "Run smoke test with:"
echo "  ${REPO_ROOT}/scripts/smoke-test-runtime.sh ${IMAGE_TAG}"

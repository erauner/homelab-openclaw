#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${1:-homelab-openclaw-runtime:local}"

echo "Smoke testing image: ${IMAGE_TAG}"

docker run --rm --platform linux/amd64 --entrypoint sh "${IMAGE_TAG}" -lc '
  set -e
  echo "== Version checks =="
  node /app/openclaw.mjs --version
  gh --version | head -1
  gog --version
  mdbase --help | head -1
  mcporter --version
  jq --version
  rg --version | head -1
  kubectl version --client=true --output=yaml >/dev/null
  td version || true

  echo "== Path checks =="
  command -v gh
  command -v gog
  command -v mdbase
  command -v mcporter
  command -v jq
  command -v rg
  command -v kubectl
  command -v summarize
  command -v td
'

echo "Smoke test passed."

# OpenClaw runtime image with pre-installed tools.
# Goal: eliminate per-pod init-container downloads.
ARG OPENCLAW_VERSION=2026.3.2-amd64
FROM ghcr.io/openclaw/openclaw:${OPENCLAW_VERSION}

ARG GH_VERSION=2.61.0
ARG GOG_VERSION=0.9.0
ARG MDBASE_CLI_VERSION=0.7.0
ARG TODOIST_CLI_VERSION=0.8.23
ARG JQ_VERSION=1.7.1
ARG RIPGREP_VERSION=14.1.1
ARG KUBECTL_VERSION=v1.31.3
ARG MCPORTER_VERSION=latest
ARG SUMMARIZE_VERSION=latest

ENV TOOLS_DIR=/tools
ENV PATH="/tools/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV PYTHONPATH="${TOOLS_DIR}/lib/python"

USER root

RUN set -eux; \
    mkdir -p "${TOOLS_DIR}/bin" "${TOOLS_DIR}/lib/python"; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl tar python3-pip; \
    rm -rf /var/lib/apt/lists/*; \
    printf '%s\n' 'export PATH="/tools/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' > /etc/profile.d/openclaw-tools-path.sh

RUN set -eux; \
    cd /tmp; \
    curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" -o gh.tar.gz; \
    tar xzf gh.tar.gz; \
    mv "gh_${GH_VERSION}_linux_amd64/bin/gh" "${TOOLS_DIR}/bin/gh"; \
    rm -rf gh.tar.gz "gh_${GH_VERSION}_linux_amd64"; \
    chmod +x "${TOOLS_DIR}/bin/gh"

RUN set -eux; \
    cd /tmp; \
    curl -fsSL "https://github.com/steipete/gogcli/releases/download/v${GOG_VERSION}/gogcli_${GOG_VERSION}_linux_amd64.tar.gz" -o gog.tar.gz; \
    tar xzf gog.tar.gz; \
    mv gog "${TOOLS_DIR}/bin/gog"; \
    rm -f gog.tar.gz CHANGELOG.md LICENSE README.md; \
    chmod +x "${TOOLS_DIR}/bin/gog"

RUN set -eux; \
    curl -fsSL "https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-amd64" -o "${TOOLS_DIR}/bin/jq"; \
    chmod +x "${TOOLS_DIR}/bin/jq"

RUN set -eux; \
    cd /tmp; \
    curl -fsSL "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl.tar.gz" -o rg.tar.gz; \
    tar xzf rg.tar.gz; \
    cp "ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl/rg" "${TOOLS_DIR}/bin/rg"; \
    rm -rf rg.tar.gz "ripgrep-${RIPGREP_VERSION}-x86_64-unknown-linux-musl"; \
    chmod +x "${TOOLS_DIR}/bin/rg"

RUN set -eux; \
    curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o "${TOOLS_DIR}/bin/kubectl"; \
    chmod +x "${TOOLS_DIR}/bin/kubectl"

RUN set -eux; \
    npm config set @erauner:registry https://nexus.erauner.dev/repository/npm-hosted/; \
    npm install -g "@erauner/mdbase-cli@${MDBASE_CLI_VERSION}" --prefix "${TOOLS_DIR}" --no-audit --no-fund || \
      npm install -g "@erauner/mdbase-cli@${MDBASE_CLI_VERSION}" --prefix "${TOOLS_DIR}" --no-audit --no-fund --registry https://registry.npmjs.org; \
    npm install -g "mcporter@${MCPORTER_VERSION}" --prefix "${TOOLS_DIR}" --no-audit --no-fund; \
    npm install -g "summarize@${SUMMARIZE_VERSION}" --prefix "${TOOLS_DIR}" --no-audit --no-fund

RUN set -eux; \
    install_todoist() { \
      python3 -m pip install --no-cache-dir --break-system-packages --target "${TOOLS_DIR}/lib/python" "$@"; \
    }; \
    if install_todoist --index-url https://nexus.erauner.dev/repository/pypi-hosted/simple --extra-index-url https://pypi.org/simple "todoist-cli==${TODOIST_CLI_VERSION}" requests; then \
      printf '%s\n' \
        '#!/bin/sh' \
        'export PYTHONPATH="/tools/lib/python:${PYTHONPATH}"' \
        'exec python3 -m todoist_cli.cli "$@"' \
        > "${TOOLS_DIR}/bin/td"; \
    elif install_todoist --index-url https://pypi.org/simple "todoist-cli==${TODOIST_CLI_VERSION}" requests; then \
      printf '%s\n' \
        '#!/bin/sh' \
        'export PYTHONPATH="/tools/lib/python:${PYTHONPATH}"' \
        'exec python3 -m todoist_cli.cli "$@"' \
        > "${TOOLS_DIR}/bin/td"; \
    else \
      printf '%s\n' \
        '#!/bin/sh' \
        'echo "td unavailable: todoist-cli failed to install at image build time." >&2' \
        'exit 127' \
        > "${TOOLS_DIR}/bin/td"; \
    fi; \
    chmod +x "${TOOLS_DIR}/bin/td"

RUN set -eux; \
    node /app/openclaw.mjs --version; \
    "${TOOLS_DIR}/bin/gh" --version | head -1; \
    "${TOOLS_DIR}/bin/gog" --version; \
    "${TOOLS_DIR}/bin/mdbase" --help | head -1; \
    "${TOOLS_DIR}/bin/mcporter" --version; \
    "${TOOLS_DIR}/bin/jq" --version; \
    "${TOOLS_DIR}/bin/rg" --version | head -1; \
    "${TOOLS_DIR}/bin/kubectl" version --client=true --output=yaml >/dev/null; \
    "${TOOLS_DIR}/bin/td" version || true; \
    command -v "${TOOLS_DIR}/bin/summarize" >/dev/null

RUN chown -R node:node "${TOOLS_DIR}"

USER node

LABEL org.opencontainers.image.source="https://github.com/erauner/homelab-openclaw"
LABEL org.opencontainers.image.description="OpenClaw runtime image with pre-installed homelab tools"

# Custom OpenClaw image with pre-installed CLI tools
# This eliminates init container downloads and speeds up pod restarts
ARG OPENCLAW_VERSION=2026.1.29-amd64
FROM ghcr.io/openclaw/openclaw:${OPENCLAW_VERSION}

# Tool versions - update these when upgrading
ARG MDBASE_VERSION=0.7.0
ARG TODOIST_VERSION=0.23.0
ARG GOG_VERSION=0.9.0
ARG GH_VERSION=2.61.0

USER root

# Create tools directory
RUN mkdir -p /tools/bin && chown -R node:node /tools

# Install todoist CLI
RUN cd /tmp && \
    curl -fsSL https://github.com/sachaos/todoist/releases/download/v${TODOIST_VERSION}/todoist_Linux_x86_64.tar.gz -o todoist.tar.gz && \
    tar xzf todoist.tar.gz && \
    mv todoist /tools/bin/ && \
    rm -f todoist.tar.gz && \
    chmod +x /tools/bin/todoist

# Install gog CLI (Google Workspace)
RUN cd /tmp && \
    curl -fsSL https://github.com/steipete/gogcli/releases/download/v${GOG_VERSION}/gogcli_${GOG_VERSION}_linux_amd64.tar.gz -o gog.tar.gz && \
    tar xzf gog.tar.gz && \
    mv gog /tools/bin/ && \
    rm -f gog.tar.gz CHANGELOG.md LICENSE README.md 2>/dev/null || true && \
    chmod +x /tools/bin/gog

# Install gh CLI
RUN cd /tmp && \
    curl -fsSL https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz -o gh.tar.gz && \
    tar xzf gh.tar.gz && \
    mv gh_${GH_VERSION}_linux_amd64/bin/gh /tools/bin/ && \
    rm -rf gh.tar.gz gh_${GH_VERSION}_linux_amd64 && \
    chmod +x /tools/bin/gh

# Install mdbase-cli via npm (requires npm available in base image)
RUN npm install -g @erauner/mdbase-cli@${MDBASE_VERSION} --prefix /tools --no-audit --no-fund \
    --registry https://nexus.erauner.dev/repository/npm-hosted/ 2>/dev/null || \
    npm install -g @erauner/mdbase-cli@${MDBASE_VERSION} --prefix /tools --no-audit --no-fund

# Verify installations
RUN echo "=== Installed tools ===" && \
    /tools/bin/todoist --version && \
    /tools/bin/gog --version && \
    /tools/bin/gh --version && \
    /tools/bin/mdbase --help | head -1

# Add tools to PATH for all users
ENV PATH="/tools/bin:${PATH}"

USER node

# Labels
LABEL org.opencontainers.image.source="https://github.com/erauner12/homelab-openclaw"
LABEL org.opencontainers.image.description="OpenClaw with pre-installed homelab CLI tools"

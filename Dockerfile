FROM ghcr.io/rubio-enterprises/base:main@sha256:4f33adf26c233309126abf159fe5c89b53a0b2251cd5187d62c2fadbac482b12 AS dev

USER root
# Mise 2026.11.1 reads the system config's lock at /etc/mise/mise.lock
# Native dependency sidecars under image/.mise/ are part of the lock
COPY image/ /etc/mise/
RUN --mount=type=secret,id=GITHUB_TOKEN /opt/standards/image/install.sh

FROM dev AS ci
COPY --link --from=ghcr.io/rubio-enterprises/runner:main@sha256:7bd552aee2ad36a14057a958d66e322910c69569d857cdca82a7520ebed7afd7 --chown=1000:1000 /home/runner /opt/actions-runner
WORKDIR /opt/actions-runner

# Same home and cache paths as the eventual runner, not root's throwaway caches
COPY --chown=1000:1000 . /workspaces/warmup
RUN /opt/standards/image/warmup.sh
USER vscode

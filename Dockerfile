FROM debian:stable-slim
LABEL maintainer="docker@ix.ai" \
      ai.ix.repository="ix.ai/docker-buildx-qemu"

# TODO remove config.json this flag once it's not needed for `buildx` anymore
COPY config.json /root/.docker/
COPY debian-backports-pin-600.pref /etc/apt/preferences.d/
COPY debian-backports.list /etc/apt/sources.list.d/

# Upgrades the image, Installs docker and qemu
RUN  set -eux; \
    \
    export DEBIAN_FRONTEND=noninteractive; \
    export TERM=linux; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      apt-transport-https \
      gnupg2 \
      software-properties-common \
      \
      ca-certificates \
      \
      git \
      jq \
      curl \
      \
      binfmt-support \
      qemu-user-static \
    ; \
    # Workaround for https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=923479
    c_rehash; \
    \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -; \
    add-apt-repository "deb https://download.docker.com/linux/debian $(lsb_release -cs) stable"; \
    apt-get update; \
    apt-get install -y  --no-install-recommends \
      docker-ce-cli \
    ; \
    apt-get autoremove --purge -y \
      apt-transport-https \
      gnupg2 \
      software-properties-common \
    ; \
    apt-get autoremove --purge -y; \
    rm -rf /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*; \
    \
    # Versions
    qemu-i386-static --version; \
    docker buildx version

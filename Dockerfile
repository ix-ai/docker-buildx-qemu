FROM debian:stable-slim as BUILDER

FROM debian:stable-slim
LABEL maintainer="docker@ix.ai" \
      ai.ix.repository="ix.ai/docker-buildx-qemu"

# Upgrades the image, Installs docker and qemu
RUN set -eux; \
  export DEBIAN_FRONTEND=noninteractive; \
  export TERM=linux; \
  apt-get update; \
  apt-get -y dist-upgrade; \
  apt-get install -y --no-install-recommends \
    apt-transport-https \
    gnupg2 \
    software-properties-common \
    \
    ca-certificates \
    \
    binfmt-support \
    qemu-user-static \
    \
    git \
    jq \
    curl \
  ; \
  \
  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - ; \
  add-apt-repository "deb https://download.docker.com/linux/debian $(lsb_release -cs) stable"; \
  apt-get update; \
  apt-get install -y  --no-install-recommends \
    docker-ce-cli \
  ; \
  \
  apt-get autoremove --purge -y \
    apt-transport-https \
    gnupg2 \
    software-properties-common \
  ; \
  apt-get -y --purge autoremove; \
  rm -rf /var/lib/apt/lists/* /var/log/* /var/tmp/* /tmp/*; \
  \
# TODO disable this flag once it's not needed for `buildx` anymore
  mkdir -p ~/.docker; \
  echo '{"experimental":"enabled"}' > ~/.docker/config.json; \
  docker buildx version

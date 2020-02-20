FROM debian:latest
LABEL maintainer="docker@ix.ai" \
      ai.ix.repository="ix.ai/docker-buildx-qemu"

ENV DEBIAN_FRONTEND=noninteractive TERM=linux

# Upgrades the image, Installs docker and qemu, installs buildx plugin and prints the version to the file
# TODO Use docker stable once it properly supports buildx
RUN apt-get update && apt-get -y dist-upgrade && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common && \
        git && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && apt-get install -y  --no-install-recommends \
        docker-ce-cli \
        binfmt-support \
        qemu-user-static && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p ~/.docker/cli-plugins && \
    ARCH=`dpkg --print-architecture` && echo Running on $ARCH && curl -s https://api.github.com/repos/docker/buildx/releases/latest | \
        grep "browser_download_url.*linux-$ARCH" | cut -d : -f 2,3 | tr -d \" | \
    xargs curl -L -o ~/.docker/cli-plugins/docker-buildx && \
    chmod a+x ~/.docker/cli-plugins/docker-buildx && \
    printf "$(docker --version | perl -pe 's/^.*\s(\d+\.\d+\.\d+.*),.*$/$1/')_$(docker buildx version | perl -pe 's/^.*v?(\d+\.\d+\.\d+).*$/$1/')" > /version && \
    cat /version

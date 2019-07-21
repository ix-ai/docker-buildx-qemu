FROM debian

ENV BUILDX_VERSION=v0.2.2

# Install Docker and qemu
# TODO Use docker stable once it properly supports buildx
RUN apt-get update && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable test" && \
    apt-get update && apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        binfmt-support \
        qemu-user-static

# Install buildx plugin
RUN mkdir -p ~/.docker/cli-plugins && \
    curl -L -o ~/.docker/cli-plugins/docker-buildx \
        https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64 && \
    chmod a+x ~/.docker/cli-plugins/docker-buildx

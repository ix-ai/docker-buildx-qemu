# docker-buildx-qemu

[![Pipeline Status](https://gitlab.com/ix.ai/docker-buildx-qemu/badges/master/pipeline.svg)](https://gitlab.com/ix.ai/docker-buildx-qemu/)
[![Docker Stars](https://img.shields.io/docker/stars/ixdotai/docker-buildx-qemu.svg)](https://hub.docker.com/r/ixdotai/docker-buildx-qemu/)
[![Docker Pulls](https://img.shields.io/docker/pulls/ixdotai/docker-buildx-qemu.svg)](https://hub.docker.com/r/ixdotai/docker-buildx-qemu/)
[![Docker Image Version (latest)](https://img.shields.io/docker/v/ixdotai/docker-buildx-qemu/latest)](https://hub.docker.com/r/ixdotai/docker-buildx-qemu/)
[![Docker Image Size (latest)](https://img.shields.io/docker/image-size/ixdotai/docker-buildx-qemu/latest)](https://hub.docker.com/r/ixdotai/docker-buildx-qemu/)
[![Gitlab Project](https://img.shields.io/badge/GitLab-Project-554488.svg)](https://gitlab.com/ix.ai/docker-buildx-qemu/)

This Debian-slim-based image allows you to easily build cross-platform images.
It's been tested with GitLab CI on gitlab.com, but it should work anywhere that docker-in-docker already works, and with a `binfmt_misc` enabled kernel.

The `registry.gitlab.com/ix.ai/docker-buildx-qemu` image supports the following architectures:
* `amd64`
* `arm64`
* `arm/v7`

The following additional tools are installed, to be used in your pipelines:
* `curl`
* `git`
* `jq`

## Example Usage

This GitLab example should give you an idea of how to use the image.

Dockerfile
```dockerfile
FROM alpine

RUN echo "Hello, my CPU architecture is $(uname -m)"
```

.gitlab-ci.yml
```yaml
variables:
  DOCKER_TLS_CERTDIR: "/certs"
  DOCKER_CERT_PATH: "/certs/client"
  DOCKER_TLS: 'true'
  DOCKER_HOST: tcp://docker:2376/
  BUILDKIT_INLINE_CACHE: '1'
  DOCKER_DRIVER: overlay2
  CI_BUILD_ARCHS: "linux/arm/v7,linux/arm64,linux/amd64"
  CI_BUILD_IMAGE: "registry.gitlab.com/ix.ai/docker-buildx-qemu:latest"

build:
  image: $CI_BUILD_IMAGE
  stage: build
  services:
    - docker:dind
  retry: 2
  before_script:
    - echo "$CI_REGISTRY_PASSWORD" | docker login -u "$CI_REGISTRY_USER" --password-stdin $CI_REGISTRY
    - update-binfmts --enable # Important: Ensures execution of other binary formats is enabled in the kernel
    # Use docker-container driver to allow useful features (push/multi-platform)
    - docker context create MyContext
    - docker buildx create --driver docker-container --name MyContext --use MyContext
    - docker buildx inspect --bootstrap
  script:
    - docker buildx ls
    - docker buildx build --platform $CI_BUILD_ARCHS --progress plain --pull -t "$CI_REGISTRY_IMAGE" --push .
  after_script:
    - docker buildx rm
```

And the (partial) output:
```
#6 [linux/amd64 2/2] RUN echo "Hello, my CPU architecture is $(uname -m)"
#6 0.120 Hello, my CPU architecture is x86_64
#6 DONE 0.3s

#8 [linux/arm/v7 2/2] RUN echo "Hello, my CPU architecture is $(uname -m)"
#8 0.233 Hello, my CPU architecture is armv7l
#8 DONE 0.2s
```

## Resources:
* GitLab: https://gitlab.com/ix.ai/docker-buildx-qemu
* GitHub: https://github.com/ix-ai/docker-buildx-qemu
* Docker Hub: https://hub.docker.com/r/ixdotai/docker-buildx-qemu

### Registry

This image can be found on both GitLab Registry and Docker Hub:
* `registry.gitlab.com/ix.ai/docker-buildx-qemu`
* `ixdotai/docker-buildx-qemu`

## Credits:
This work is based on [ericvh/docker-buildx-qemu](https://gitlab.com/ericvh/docker-buildx-qemu)

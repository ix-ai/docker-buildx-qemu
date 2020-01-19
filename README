# docker-buildx-qemu

This Debian-based image allows you to easily build cross-platform images.
It's been tested with GitLab CI on gitlab.com, but it should work anywhere that docker-in-docker already works, and with a binfmt_misc enabled kernel.

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
  CI_BUILD_ARCHS: "linux/arm/v7,linux/arm64,linux/amd64"
  CI_BUILD_IMAGE: "registry.gitlab.com/ericvh/docker-buildx-qemu"

build:
  image: $CI_BUILD_IMAGE
  stage: build
  services:
    - name: docker:dind
      entrypoint: ["env", "-u", "DOCKER_HOST"]
      command: ["dockerd-entrypoint.sh"]
  variables:
    DOCKER_HOST: tcp://docker:2375/
    DOCKER_DRIVER: overlay2
    # See https://github.com/docker-library/docker/pull/166
    DOCKER_TLS_CERTDIR: ""
  retry: 2
  before_script:
    - echo "$CI_REGISTRY_PASSWORD" | docker login -u "$CI_REGISTRY_USER" --password-stdin $CI_REGISTRY
    # Use docker-container driver to allow useful features (push/multi-platform)
    - update-binfmts --enable # Important: Ensures execution of other binary formats is enabled in the kernel
    - docker buildx create --driver docker-container --use
    - docker buildx inspect --bootstrap
  script:
    - docker buildx ls
    - docker buildx build --platform $CI_BUILD_ARCHS --progress plain --pull -t "$CI_REGISTRY_IMAGE" --push .
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

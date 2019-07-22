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
  DOCKER_HOST: tcp://docker:2375/

build:
  image: jonoh/docker-buildx-qemu
  stage: build
  services:
    - docker:dind
  before_script:
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
  script:
    - update-binfmts --enable # Important: Ensures execution of other binary formats is enabled in the kernel
    - docker buildx build --platform linux/arm/v7,local --pull -t "$CI_REGISTRY_IMAGE" --push .
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

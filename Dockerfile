FROM ubuntu:22.04

LABEL maintainer="phish108 <info@mobinaut.io>"
LABEL version="3.0.0"
LABEL org.opencontainers.image.source https://github.com/phish108/Ansible-Docker

USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    openssh-client \
    git \
    less \
    # vim-tiny \
    curl \
    # iputils-ping \
    python3 \
    python3-wheel \
    python3-pip \
    python3-setuptools \
    # Ubuntu ships an old ansible version (2.10.8 aka 3.8 vs. 2.12 aka 5.8) 
    # ansible \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    && \
    # fetch latest version of ansible via pip3 fails for arm platforms
    pip3 --no-cache-dir install ansible 

COPY docker-entrypoint.sh /usr/local/bin/

RUN useradd -m -d /ansible ansible && \
    chmod 755 /usr/local/bin/docker-entrypoint.sh 

WORKDIR /ansible

USER ansible

RUN  mkdir -p /ansible/.ssh

ENTRYPOINT ["docker-entrypoint.sh"]

# CMD ["bash"]

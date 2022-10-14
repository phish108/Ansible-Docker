FROM ubuntu:22.04

LABEL maintainer="phish108 <cpglahn@gmail.com>"
LABEL version="6.1.0"
LABEL org.opencontainers.image.source https://github.com/phish108/Ansible-Docker

USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    openssh-client \
    git \
    # less \
    # vim-tiny \
    curl \
    gcc \
    libffi-dev \
    # iputils-ping \
    python3 \
    python3-dev \
    python3-wheel \
    python3-pip \
    # The next line appears to have no effect.
    python3-setuptools \
    # Ubuntu ships an old ansible version (2.10.8 aka 3.8 vs. 2.12 aka 5.8) 
    # ansible \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    && \
    # python3 -m pip install --no-cache-dir --upgrade pip && \
    # python3 -m pip install --no-cache-dir --upgrade setuptools && \
    # fetch latest version of ansible via pip3 fails for arm platforms
    python3 -m pip --no-cache-dir install ansible 

COPY docker-entrypoint.sh /usr/local/bin/

RUN useradd -m -d /ansible ansible && \
    chmod 755 /usr/local/bin/docker-entrypoint.sh 

WORKDIR /ansible

USER ansible

RUN  mkdir -p /ansible/.ssh

ENTRYPOINT ["docker-entrypoint.sh"]

# CMD ["bash"]

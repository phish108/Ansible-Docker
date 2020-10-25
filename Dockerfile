FROM ubuntu:focal

LABEL maintainer="phish108 <info@mobinaut.io>"
LABEL version="1.0.4"

USER root

COPY docker-entrypoint.sh /usr/local/bin/

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    openssh-client \
    git \
    less \
    vim-tiny \
    curl \
    python3 \
    python3-wheel \
    python3-pip \
    python3-setuptools \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m -d /ansible ansible && \
    pip3 --no-cache-dir install ansible && \
    chmod 755 /usr/local/bin/docker-entrypoint.sh 

WORKDIR /ansible

USER ansible

RUN  mkdir -p /ansible/.ssh

# ENTRYPOINT ["docker-entrypoint.sh"]

# CMD ["bash"]

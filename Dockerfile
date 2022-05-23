FROM ubuntu:22.04

LABEL maintainer="phish108 <info@mobinaut.io>"
LABEL version="5.8.0"

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
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip3 --no-cache-dir install ansible 

COPY docker-entrypoint.sh /usr/local/bin/

RUN useradd -m -d /ansible ansible && \
    chmod 755 /usr/local/bin/docker-entrypoint.sh 

WORKDIR /ansible

USER ansible

RUN  mkdir -p /ansible/.ssh

ENTRYPOINT ["docker-entrypoint.sh"]

# CMD ["bash"]

FROM ubuntu:24.04

# Starting from Ansible Version > 7.1, this will use the dashed number to indicate the image build.
ARG VERSION_TAG=11.0.0-2

LABEL maintainer="phish108 <cpglahn@gmail.com>"

LABEL version=$VERSION_TAG
LABEL org.opencontainers.image.source https://github.com/phish108/Ansible-Docker

USER root

COPY requirements.txt /tmp/requirements.txt

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    openssh-client \
    # iputils-ping \
    # git \
    less \
    # vim-tiny \
    # curl \
    # gcc \
    libffi-dev \
    python3 \
    # python3-dev \
    python3-wheel \
    python3-pip \
    # python3-jmespath \
    # python3-yaml \
    # The next line appears to have no effect.
    python3-setuptools \
    python-is-python3 \
    # Ubuntu ships an old ansible version (2.10.8 aka 3.8 vs. 2.12 aka 5.8) 
    # ansible \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
    && \
    mkdir -p /ansible /etc/ansible /tmp/ssh/ && \
    # run pip and to install the ansible and its dependencies
    pip3 --no-cache-dir install -r /tmp/requirements.txt && \
    rm -f /tmp/requirements.txt

COPY docker-entrypoint.sh /usr/local/bin/
COPY ansible.cfg /etc/ansible/ansible.cfg

RUN useradd -m -d /ansible ansible && \
    chown ansible /ansible && \
    chmod 755 /usr/local/bin/docker-entrypoint.sh 

WORKDIR /ansible

USER ansible

ENTRYPOINT ["docker-entrypoint.sh"]

# CMD ["bash"]

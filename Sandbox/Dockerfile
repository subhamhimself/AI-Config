FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        openssh-server \
        git \
        curl \
        wget \
        vim \
        nano \
        unzip \
        zip \
        build-essential \
        python3 \
        python3-pip \
        ca-certificates \
        less \
        tmux && \
    rm -rf /var/lib/apt/lists/*

# SSH - no auth (sandbox)
RUN mkdir /var/run/sshd && \
    passwd -d root 2>/dev/null || true

RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config && \
    echo 'PermitEmptyPasswords yes' >> /etc/ssh/sshd_config

# Dotfiles
COPY dotfiles/ /root/

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Run init script
RUN curl -fsSL https://raw.githubusercontent.com/subhamhimself/AI-Config/main/init.sh | bash

CMD ["/usr/sbin/sshd", "-D"]

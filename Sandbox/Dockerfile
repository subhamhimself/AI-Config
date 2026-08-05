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

# SSH - password auth
RUN mkdir /var/run/sshd && \
    echo 'root:12345678' | chpasswd

RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Dotfiles
COPY dotfiles/ /root/

# Run init script on startup then start SSH
COPY scripts/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]

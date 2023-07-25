FROM debian:bullseye
MAINTAINER Adrian Dvergsdal [atmoz.net]

# Steps done in one RUN layer:
# - Install packages
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN apt-get install wget -y
RUN wget https://enterprise.proxmox.com/debian/proxmox-release-bullseye.gpg /tmp/
RUN mv /tmp/proxmox-release-bullseye.gpg /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
RUN echo deb http://download.proxmox.com/debian/pbs-client bullseye main > /etc/apt/sources.list.d/pbs-client.list
RUN apt-get update && \
    apt-get -y dist-upgrade $$ \
    apt-get -y install openssh-server proxmox-backup-client && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/create-sftp-user /usr/local/bin/
COPY files/entrypoint /

EXPOSE 22

ENTRYPOINT ["/entrypoint"]

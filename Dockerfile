FROM debian:stable-slim

# supply your pub key via `--build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)"` when running `docker build`
ARG SSH_PUB_KEY

# user and group settings
ARG USERNAME

#USER root

# timezone
RUN apt update && apt install -y \
    tzdata; \
  apt clean; \    
# sshd
  mkdir /var/run/sshd; \
  apt install -y \
    openssh-server \
    mc; \
# root permission
  sed -i 's/^#\(PermitRootLogin\) .*/\1 yes/' /etc/ssh/sshd_config; \
  sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config; \
  apt clean; \
# entrypoint
  { \
    echo '#!/bin/bash -eu'; \
    echo 'ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime'; \
    echo 'echo "root:${ROOT_PASSWORD}" | chpasswd'; \
    echo 'exec "$@"'; \
  } > /usr/local/bin/entry_point.sh; \
  chmod +x /usr/local/bin/entry_point.sh; \
# user account
  echo "####################################################"; \
  echo $USERNAME;\
  echo $SSH_PUB_KEY; \
  mkdir -p /home/$USERNAME/.ssh; \
  adduser --home /home/$USERNAME $USERNAME; \
#  useradd -m -U ${USERNAME}; \
  chmod 700 /home/$USERNAME/.ssh; \
  echo "$SSH_PUB_KEY" > /home/$USERNAME/.ssh/authorized_keys; \
  chown $USERNAME:$USERNAME -R /home/$USERNAME; \
  chmod 600 /home/$USERNAME/.ssh/authorized_keys;

ENV TZ Europe/Bratislava

ENV ROOT_PASSWORD root

#USER ${USERNAME}

EXPOSE 22

ENTRYPOINT ["entry_point.sh"]
CMD    ["/usr/sbin/sshd", "-D", "-e"]


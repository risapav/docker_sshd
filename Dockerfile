FROM debian:stable-slim

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
  chmod +x /usr/local/bin/entry_point.sh; 

# supply your pub key via `--build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)"` when running `docker build`
ARG SSH_PUB_KEY

# user and group settings
ARG USERNAME

# user account
RUN  { \
    echo '#!/bin/bash -eu'; \
    echo 'echo ${USERNAME};\
    echo 'echo ${SSH_PUB_KEY}; \
    echo 'mkdir -p /home/${USERNAME}/.ssh'; \
    echo 'adduser --home /home/${USERNAME} ${USERNAME}'; \
#  echo 'useradd -m -U ${USERNAME}'; \
    echo 'chmod 700 /home/${USERNAME}/.ssh'; \
    echo 'echo "${SSH_PUB_KEY}" > /home/${USERNAME}/.ssh/authorized_keys'; \
    echo 'chown ${USERNAME}:${USERNAME} -R /home/${USERNAME}'; \
    echo 'chmod 600 /home/${USERNAME}/.ssh/authorized_keys';
  } > /tmp/user_account.sh; \
  chmod +x /tmp/user_account.sh; \
  /tmp/user_account.sh;

ENV TZ Europe/Bratislava

ENV ROOT_PASSWORD root

EXPOSE 22

ENTRYPOINT ["entry_point.sh"]
CMD    ["/usr/sbin/sshd", "-D", "-e"]


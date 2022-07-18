FROM debian:stable-slim

# supply your pub key via `--build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)"` when running `docker build`
ARG SSH_PUB_KEY "$(cat ~/.ssh/id_rsa.pub)"

# user and group settings `--build-arg USERNAME=$USER`
ARG USERNAME $USER

#########################################################################################################
# prepare sshd server
#########################################################################################################
ENV TZ Europe/Bratislava

ENV ROOT_PASSWORD root

ENV USER_PASSWORD ${USERNAME}

EXPOSE 22

# timezone
RUN apt update && apt install -y \
    tzdata; \
  apt clean; \    
# sshd
  mkdir /var/run/sshd; \
  apt install -y \
    #mc \
    openssh-server; \
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
#########################################################################################################
# create user account
#########################################################################################################
  if [ ! -z "$USERNAME" ]; \ 
  then \ 
    echo "############################################"; \
    echo "Configuring with user ${USERNAME} access ..."; \
    echo "############################################"; \
    { \
      echo '#!/bin/bash'; \
      echo 'echo "username #### $1"';\
      echo 'echo "key #### $2"'; \
      echo 'useradd -d /home/$1 -m $1'; \
      echo 'echo "$1:${USER_PASSWORD}" | chpasswd'; \
      echo '# adduser $1 admin'; \
      echo '# adduser --home /home/$1'; \
      echo 'mkdir -p /home/$1/.ssh'; \
      echo 'chmod 700 /home/$1/.ssh'; \
      echo 'echo $2 > /home/$1/.ssh/authorized_keys'; \
      echo 'chown $1:$1 -R /home/$1'; \
      echo 'chmod 600 /home/$1/.ssh/authorized_keys'; \
    } > /tmp/user_account.sh; \
    chmod +x /tmp/user_account.sh; \
    cat /tmp/user_account.sh; \
    ls -la /tmp; \
    /tmp/user_account.sh "${USERNAME}" "${SSH_PUB_KEY}"; \
  else \
    echo "############################################"; \
    echo "Configuring with root access only..."; \
    echo "############################################"; \
  fi;

ENTRYPOINT ["entry_point.sh"]

CMD    ["/usr/sbin/sshd", "-D", "-e"]


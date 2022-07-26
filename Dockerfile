
FROM debian:stable-slim

# supply your pub key via `--build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)"` when running `docker build`
ARG SSH_PUB_KEY

# user and group settings `--build-arg USERNAME=$USER`
ARG USERNAME

#########################################################################################################
# prepare sshd server
#########################################################################################################

# environment settings timezone -e TZ=Asia/Tokyo
ENV TZ Europe/Bratislava

# environment settins -e ROOT_PASSWORD=pokus
ENV ROOT_PASSWORD root

# ToDo user password changed during build
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
# script to add user account
  { \
    echo '#!/bin/bash'; \
    echo 'echo "username #### $1"';\
    echo 'echo "key #### $2"'; \
    echo 'useradd -m -d /home/$1 -s /bin/bash $1'; \
    echo 'echo "$1:${USER_PASSWORD}" | chpasswd'; \
    echo 'mkdir -p /home/$1/.ssh'; \
    echo 'echo $2 > /home/$1/.ssh/authorized_keys'; \
    echo 'chown $1:$1 -R /home/$1'; \
    echo 'chmod 700 /home/$1/.ssh'; \
    echo 'chmod 600 /home/$1/.ssh/authorized_keys'; \
    echo '# usermod -a -G sudo $1'; \
    } > /usr/local/bin/user_account.sh; \
  chmod +x /usr/local/bin/user_account.sh; \
############################################################  
# add user account during build process, in that case 
# build arguments USERNAME and SSH_PUB_KEY are mandatory
# example:
# docker build --build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" --build-arg USERNAME=$USER -t sshd .
############################################################
echo "$USERNAME ${USERNAME}"; \
echo "$SSH_PUB_KEY ${SSH_PUB_KEY}"; \
  if [ -n "$USERNAME" ]; \
    then \
    if [ -n "$SSH_PUB_KEY" ]; \
    then \ 
      echo "############################################"; \
      echo "Configuring with user ${USERNAME} access ..."; \
      echo "############################################"; \
      cat /usr/local/bin/user_account.sh; \
      user_account.sh "${USERNAME}" "${SSH_PUB_KEY}"; \
    fi; \
  else \
    echo "############################################"; \
    echo "Configuring with root access only ..."; \
    echo "############################################"; \  
  fi;

ENTRYPOINT ["entry_point.sh"]

CMD    ["/usr/sbin/sshd", "-D", "-e"]


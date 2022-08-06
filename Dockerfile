
FROM debian:stable-slim

# supply your pub key via `--build-arg ssh_pub_key="$(cat ~/.ssh/id_rsa.pub)"` when running `docker build`
# docker build example:
# docker build --build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" --build-arg USERNAME=$USER -t sshd .

ARG SSH_PUB_KEY

# user and group settings `--build-arg USERNAME=$USER`
ARG USERNAME

#############################################################################################################
# prepare sshd server
#############################################################################################################
# example how to change environment variabes during docker run command:
# docker run -d --name sshd -e TZ=Asia/Tokyo -e ROOT_PASSWORD=root -p 8022:22 sshd

# sshd server options 
#ENV SSH_PORT=22 

# environment settings timezone -e TZ=Asia/Tokyo
ENV TZ Europe/Bratislava

# environment settins -e ROOT_PASSWORD=pokus
ENV ROOT_PASSWORD root

#EXPOSE ${SSH_PORT}
EXPOSE 22


# timezone & openssh_server install
RUN mkdir -p /var/run/sshd; \
    apt update && apt install -y \
    #mc \
    openssh-server \
    tzdata; \    
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
    echo '# script to add a user to Linux system'; \
    echo 'if [ $(id -u) -eq 0 ]; then'; \
    echo '  echo "username #### $1"'; \
    echo '  useradd -m -d /home/$1 -s /bin/bash $1'; \
    echo '  echo "$1:$1" | chpasswd'; \
    echo '  if [ "$2" ]; then'; \
    echo '    echo "key #### $2"'; \
    echo '    mkdir -p /home/$1/.ssh'; \
    echo '    echo $2 > /home/$1/.ssh/authorized_keys'; \
    echo '    chown $1:$1 -R /home/$1'; \
    echo '    chmod 700 /home/$1/.ssh'; \
    echo '    chmod 600 /home/$1/.ssh/authorized_keys'; \
    echo '  else'; \
    echo '    echo "no key presented ####"'; \
    echo '    chown $1:$1 -R /home/$1'; \
    echo '  fi'; \
    echo '# usermod -a -G sudo $1'; \
    echo 'else'; \
    echo '  echo "############################################"'; \
    echo '  echo "Only root may add a user to the system"';\
    echo '  echo "############################################"'; \
    echo '  exit 2';\
    echo 'fi'; \
    } > /usr/local/bin/user_account.sh; \
  chmod +x /usr/local/bin/user_account.sh; \
#############################################################################################################  
# options to add a user:
# 1. during build:
#      docker build --build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" --build-arg USERNAME=$USER -t sshd .
# 2. during run via exec:
#      docker run --name $(CONTAINER_NAME) --hostname $(CONTAINER_NAME) -p 8022:22 $(IMAGE_NAME)
#      docker exec $(CONTAINER_NAME) user_account.sh $(USER) "$(RSA_KEY)"
#############################################################################################################
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
#CMD    ["/usr/sbin/sshd", "-D", "-e", "-p ${SSH_PORT}" ]


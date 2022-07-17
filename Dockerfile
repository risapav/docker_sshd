FROM debian:stable-slim

# timezone
RUN apt update && apt install -y \
    tzdata; \
  apt clean; \    
# sshd
  mkdir /var/run/sshd; \
  apt install -y \
    openssh-server \
    mc; \
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

ENV TZ Europe/Bratislava

ENV ROOT_PASSWORD root

EXPOSE 22

ENTRYPOINT ["entry_point.sh"]
CMD    ["/usr/sbin/sshd", "-D", "-e"]

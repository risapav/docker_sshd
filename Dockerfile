FROM ubuntu:latest

MAINTAINER Pavol Risa "risapav at gmail"

#update OS
RUN apt-get update \
	&& apt-get install -y openssh-server \
	&& apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
	
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN mkdir /root/.ssh

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile    

EXPOSE 22

CMD    ["/usr/sbin/sshd", "-D"]

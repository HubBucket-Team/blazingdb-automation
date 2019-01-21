FROM ubuntu:16.04
MAINTAINER Mario Inga <mario21ic@gmail.com>

RUN apt-get update && apt-get install -y sudo python && \
  groupadd -g 1000 ec2-user && \
  useradd -u 1000 -g 1000 ec2-user && \
  echo "ec2-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

#USER ec2-user

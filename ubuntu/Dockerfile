### 
### Ubuntu 16.04 Lastest dist-upgrade
### 한국 패키지 저장소, 언어셋, 타임존
### Unzip
###
### docker build --force-rm=true -t gshn/ubuntu:16.04 .

FROM ubuntu:16.04

LABEL maintainer="gshn <gs@gs.hn>"

# 패키지 저장소 수정
RUN sed -i 's/archive.ubuntu.com/ftp.daumkakao.com/g' /etc/apt/sources.list

# 패키지 update & upgrade
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get -y upgrade

# 언어셋
RUN apt-get -y install locales && \
    locale-gen ko_KR.UTF-8

# 타임존
RUN apt-get -y install dpkg tzdata && \
    echo "Asia/Seoul" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# Unzip, wget, tar 설치
RUN apt-get -y install unzip wget

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]


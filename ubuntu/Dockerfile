### 
### Ubuntu 16.04 Lastest dist-upgrade
### 패키지 update & upgrade, 언어셋, 타임존
### install Unzip wget
###
### docker build --force-rm=true -t gshn/ubuntu:16.04 .

FROM ubuntu:16.04

LABEL maintainer="gshn <gs@gs.hn>"

# 패키지 update & upgrade
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y --no-install-recommends apt-utils unzip wget locales dpkg tzdata

# 언어셋 및 타임존 변수
ENV LANGUAGE ko_KR.UTF-8
ENV TIMEZONE Asia/Singapore

# 언어셋
RUN locale-gen ${LANGUAGE}

# 타임존
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo ${TIMEZONE} > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# overwrite this with 'CMD []' in a dependent Dockerfile
CMD ["/bin/bash"]

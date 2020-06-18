FROM ubuntu:bionic
MAINTAINER FRAM Data Team <nmfs.nwfsc.fram.data.team@noaa.gov>

RUN apt-get update
RUN apt-get install -y wget
RUN apt-get install -y build-essential
RUN apt-get install -y zip unzip

RUN wget https://github.com/admb-project/admb/releases/download/admb-12.1/admb-12.1-linux-64bit.zip

RUN unzip admb-12.1-linux-64bit.zip -d /usr/local

RUN chmod 755 /usr/local/admb-12.1/admb

ENV PATH /usr/local/admb-12.1:$PATH
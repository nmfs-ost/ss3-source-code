FROM ubuntu:bionic
MAINTAINER FRAM Data Team <nmfs.nwfsc.fram.data.team@noaa.gov>

RUN apt-get update && apt-get install -y wget
RUN apt-get update && apt-get install -y build-essential
RUN apt-get update && apt-get install -y git
RUN apt-get update && apt-get install -y flex

RUN cd /usr/local && git clone https://github.com/admb-project/admb.git
RUN cd /usr/local/admb && git checkout --track origin/admb-12.2
RUN cd /usr/local/admb && make

ENV PATH /usr/local/admb:$PATH
FROM ubuntu:bionic
MAINTAINER FRAM Data Team <nmfs.nwfsc.fram.data.team@noaa.gov>

RUN apt-get update
RUN apt-get install -y wget
RUN apt-get install -y build-essential
RUN apt-get install -y zip unzip
RUN apt-get install -y flex

RUN wget https://github.com/admb-project/admb/archive/admb-12.2pre.zip

RUN ls

RUN unzip admb-12.2pre.zip -d /usr/local

RUN head -n 120 /usr/local/admb-admb-12.2pre/src/linad99/fvar.hpp

RUN sed -i '/#define USE_VECTOR_SHAPE_POOL/d' /usr/local/admb-admb-12.2pre/src/linad99/fvar.hpp

RUN head -n 120 /usr/local/admb-admb-12.2pre/src/linad99/fvar.hpp

RUN cd /usr/local/admb-admb-12.2pre && make

RUN chmod 755 /usr/local/admb-admb-12.2pre/admb

ENV PATH /usr/local/admb-admb-12.2pre:$PATH

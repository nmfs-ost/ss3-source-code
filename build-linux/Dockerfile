FROM centos:7.8.2003
MAINTAINER FRAM Data Team <nmfs.nwfsc.fram.data.team@noaa.gov>

RUN yum -y update && yum clean all
RUN yum -y install wget
RUN yum install -y zip unzip
RUN yum install -y gcc-c++

RUN wget https://github.com/admb-project/admb/releases/download/admb-12.0/admb-12.0-centos7-gcc-64bit.zip

RUN unzip admb-12.0-centos7-gcc-64bit.zip -d /usr/local

RUN chmod 755 /usr/local/admb/admb

ENV PATH /usr/local/admb:$PATH
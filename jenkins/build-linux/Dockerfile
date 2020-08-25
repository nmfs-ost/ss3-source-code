FROM centos:7.8.2003
MAINTAINER FRAM Data Team <nmfs.nwfsc.fram.data.team@noaa.gov>

RUN yum -y update && yum clean all
RUN yum -y install wget
RUN yum install -y zip unzip
RUN yum install -y gcc-c++

RUN wget https://github.com/admb-project/admb/releases/download/admb-12.2/admb-12.2-linux.zip

RUN unzip admb-12.2-linux.zip -d /usr/local

RUN chmod 755 /usr/local/admb-12.2/admb

ENV PATH /usr/local/admb-12.2:$PATH
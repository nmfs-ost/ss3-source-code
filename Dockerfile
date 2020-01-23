FROM ubuntu:xenial
MAINTAINER FRAM Data Team <nmfs.nwfsc.fram.data.team@noaa.gov>

RUN groupadd --gid 502 jenkins && \
    useradd --shell /bin/bash --gid 502 --uid 501 jenkins
USER jenkins

RUN apt-get update \
  && apt-get install -y wget

RUN wget https://github.com/admb-project/admb/releases/download/admb-12.0/admb-12.0-ubuntu16-64bit_12.0.deb

RUN dpkg -i admb-12.0-ubuntu16-64bit_12.0.deb

RUN chmod 755 /usr/local/bin/admb

RUN groupadd --gid 502 jenkins && \
    useradd --shell /bin/bash --gid 502 --uid 501 jenkins
USER jenkins

CMD ["admb"]
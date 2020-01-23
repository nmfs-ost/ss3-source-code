FROM ubuntu:xenial
MAINTAINER FRAM Data Team <nmfs.nwfsc.fram.data.team@noaa.gov>

## Set a default user. Available via runtime flag `--user docker`
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (for rstudio or linked volumes to work properly).
RUN useradd admb \
	&& mkdir /home/admb \
	&& chown admb:admb /home/admb \
	&& addgroup admb staff

RUN apt-get update \
  && apt-get install -y wget

RUN wget https://github.com/admb-project/admb/releases/download/admb-12.0/admb-12.0-ubuntu16-64bit_12.0.deb

RUN dpkg -i admb-12.0-ubuntu16-64bit_12.0.deb

RUN chmod 755 /usr/local/bin/admb

CMD ["admb"]
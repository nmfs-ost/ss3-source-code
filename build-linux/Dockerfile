FROM centos:7.8.2003
MAINTAINER FRAM Data Team <nmfs.nwfsc.fram.data.team@noaa.gov>

RUN yum -y update && yum clean all
RUN yum -y install wget
RUN yum install -y zip unzip
RUN yum install -y gcc-c++

RUN wget https://github.com/admb-project/admb/releases/download/admb-12.0/admb-12.0-ubuntu16-64bit_12.0.deb

RUN dpkg -i admb-12.0-ubuntu16-64bit_12.0.deb

RUN chmod 755 /usr/local/bin/admb

# None of the below seemed to solve uid issue, solved by setting uid in Jenkinsfile but this seems to cause
# workspace deletion problems
# RUN groupadd --gid 498 jenkins && \
#     useradd --shell /bin/bash --gid 498 --uid 498 jenkins

# RUN usermod -a -G root jenkins
# RUN chown jenkins:jenkins /usr/local/bin/admb
# USER jenkins

CMD ["admb"]
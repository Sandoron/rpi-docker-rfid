#use armv7hf compatible OS
FROM balenalib/armv7hf-debian:stretch as builder

#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry) 
#RUN [ "cross-build-start" ]

#Label
LABEL maintainer="ibloe" \ 
      version="V0.0.1" \
      description="Raspberry Pi Docker with node-red and RFID"

#version
ENV PI_RFID 0.0.1

#java Options
ENV _JAVA_OPTIONS -Xms64M -Xmx128M

#copy files
COPY "./init.d/*" /etc/init.d/ 
COPY "./node-red-contrib-npix-io/*" /tmp/
COPY "./node-red-contrib-rfid/*" "./node-red-contrib-rfid/lib/*" /tmp/

#do installation
RUN apt-get update  \
    && apt-get install -y --no-install-recommends apt-utils \
    && apt-get install openjdk-11-jre \
    && apt-get install openjdk-11-jdk-headless \
#install node.js
    && curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -  \
    && apt-get install -y nodejs  \
    && npm install -g n \
    && n 11.15.0 \
#install Node-RED
    && npm install -g --unsafe-perm node-red \
#install node
    && mkdir /usr/lib/node_modules/node-red-contrib-npix-io \
    && mv /tmp/npixio.js /tmp/npixio.html /tmp/package.json -t /usr/lib/node_modules/node-red-contrib-npix-io \
    && cd /usr/lib/node_modules/node-red-contrib-npix-io \
    && npm install \
#clean up
    && rm -rf /tmp/* \
    && apt-get remove curl \
    && apt-get -yqq autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

#set the entrypoint
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#Node-RED Port
EXPOSE 1880

#set STOPSGINAL
STOPSIGNAL SIGTERM

#stop processing ARM emulation (comment out next line if built on Raspberry)
RUN [ "cross-build-end" ]

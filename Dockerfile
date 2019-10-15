#use armv7hf compatible OS
FROM balenalib/armv7hf-debian:stretch

#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry) 
RUN [ "cross-build-start" ]

#labeling
LABEL maintainer="netpi@hilscher.com" \ 
      version="V1.0.1" \
      description="Node-RED with dio nodes to communicate with NIOT-E-NPIX-4DI4DO extension module"

#version
ENV HILSCHERNETPI_NODERED_NPIX_IO_VERSION 1.0.1

#copy files
COPY "./init.d/*" /etc/init.d/ 
COPY "./node-red-contrib-npix-io/*" /tmp/

#do installation
RUN apt-get update  \
    && apt-get install curl build-essential python-dev \
#install node.js
    && curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -  \
    && apt-get install -y nodejs  \
#install Node-RED
    && npm install -g --unsafe-perm node-red \

#install nodes
#RUN mkdir /usr/lib/node_modules/node-red-contrib-rfid /usr/lib/node_modules/node-red-contrib-rfid/lib \
#    && mv ./tmp/rfid.js ./tmp/rfid.html /tmp/package.json ./tmp/RfidNode.jar /usr/lib/node_modules/node-red-contrib-rfid \
#    && mv ./tmp/ltkjava-1.0.0.6.jar /usr/lib/node_modules/node-red-contrib-rfid/lib \
#    && cd /usr/lib/node_modules/node-red-contrib-rfid/ \
#    && npm install 
#clean up
#RUN rm -rf /tmp/* \
#    && apt-get remove curl \
#    && apt-get -yqq autoremove \
#    && apt-get -y clean \
#    && rm -rf /var/lib/apt/lists/*

#set the entrypoint
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]

#Node-RED Port
EXPOSE 1880

#set STOPSGINAL
STOPSIGNAL SIGTERM

RUN [ "cross-build-end" ]

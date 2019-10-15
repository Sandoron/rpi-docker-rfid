#Base Image
FROM balenalib/armv7hf-debian:buster as builder 
RUN [ "cross-build-start" ]

#Label
LABEL maintainer="ibloe" \ 
      version="V0.0.1" \
      description="Raspberry Pi Docker with node-red and RFID"

#java 
ENV _JAVA_OPTIONS -Xms64M -Xmx128m

#copy files
COPY "./init.d/*" /etc/init.d/
COPY "./node-red-contrib-rfid/*" "./node-red-contrib-rfid/lib/*" /tmp/

#update repo and install compiler
RUN apt-get update  \
    && apt-get install curl build-essential python-dev \
#install node.js
    && curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -  \
    && apt-get install -y nodejs  \
#install Node-RED
    && npm install -g --unsafe-perm node-red 
#install open jdk 11 headless
RUN apt-get install openjdk-11-jdk-headless 

#install nodes
RUN mkdir /usr/lib/node_modules/node-red-contrib-rfid /usr/lib/node_modules/node-red-contrib-rfid/lib \
    && mv ./tmp/rfid.js ./tmp/rfid.html /tmp/package.json ./tmp/RfidNode.jar /usr/lib/node_modules/node-red-contrib-rfid \
    && mv ./tmp/ltkjava-1.0.0.6.jar /usr/lib/node_modules/node-red-contrib-rfid/lib \
    && cd /usr/lib/node_modules/node-red-contrib-rfid/ \
    && npm install 
#clean up
RUN rm -rf /tmp/* \
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

RUN [ "cross-build-end" ]

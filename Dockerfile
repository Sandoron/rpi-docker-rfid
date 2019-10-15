
Skip to content
Pull requests
Issues
Marketplace
Explore
@ibloe
Learn Git and GitHub without any code!

Using the Hello World guide, you’ll start a branch, write comments, and open a pull request.

2
0

    0

HilscherAutomation/netPI-nodered-npix-rfid
Code
Issues 0
Pull requests 0
Projects 0
Wiki
Security
Insights
netPI-nodered-npix-rfid/Dockerfile
@hilschernetpi hilschernetpi Initial commit 26a65ef on 2 Jan 2018
56 lines (45 sloc) 1.78 KB
#use latest armv7hf compatible raspbian OS version from group resin.io as base image
FROM resin/armv7hf-debian:jessie

#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry) 
RUN [ "cross-build-start" ]

#labeling
LABEL maintainer="netpi@hilscher.com" \ 
      version="V0.9.1.0" \
      description="Debian with a standard Node-RED installation, openJDK and additional rfid nodes for NIOT-E-NPIX-RFID expansion module"

#version
ENV HILSCHERNETPI_NODERED_NPIX_RFID_VERSION 0.9.1.0

#java options
ENV _JAVA_OPTIONS -Xms64M -Xmx128m

#copy files
COPY "./init.d/*" /etc/init.d/
COPY "./node-red-contrib-rfid/*" "./node-red-contrib-rfid/lib/*" /tmp/

#do installation
RUN apt-get update  \
    && apt-get install curl build-essential 
#install node.js
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -  \
    && apt-get install -y nodejs  \
#install Node-RED
    && npm install -g --unsafe-perm node-red \
#install openJDK7
    && apt-get install openjdk-7-jdk \
#install nodes
    && mkdir /usr/lib/node_modules/node-red-contrib-rfid /usr/lib/node_modules/node-red-contrib-rfid/lib \
    && mv ./tmp/rfid.js ./tmp/rfid.html /tmp/package.json ./tmp/RfidNode.jar /usr/lib/node_modules/node-red-contrib-rfid \
    && mv ./tmp/ltkjava-1.0.0.6.jar /usr/lib/node_modules/node-red-contrib-rfid/lib \
    && cd /usr/lib/node_modules/node-red-contrib-rfid/ \
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

    © 2019 GitHub, Inc.
    Terms
    Privacy
    Security
    Status
    Help

    Contact GitHub
    Pricing
    API
    Training
    Blog
    About



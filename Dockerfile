FROM arm32v7/debian:jessie
MAINTAINER Michael Sprague
LABEL maintainer.name="Michael Sprague" \
    maintainer.email="mikesprague@gmail.com" \
    version="0.0.7" \
    repo="https://github.com/mikesprague/docker-pi-suite"
## Update distro/existing packages, install apt-utils
RUN apt-get update \
    && apt-get upgrade -qy --force-yes \
    && apt-get dist-upgrade -qy --force-yes \
    && apt-get install -qy apt-utils
## Localization (set locale to en_US.UTF8 and timezone to 'America/New_York')
RUN apt-get install -qy locales tzdata \
    && locale-gen en_US.UTF-8 \
    && ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata
## Install some common dev-oriented packages, do some clean-up, install nodejs, install pi-suite
RUN apt-get install -qy --force-yes curl wget zip unzip git vim software-properties-common build-essential \
    && apt-get autoclean -qy \
    && apt-get autoremove -qy --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    ## Install node (pinned @ version 6.11.2 for pi-suite)
    && cd /tmp \
    && wget https://nodejs.org/dist/v6.11.2/node-v6.11.2-linux-armv7l.tar.xz \
    && tar -xf node-v6.11.2-linux-armv7l.tar.xz \
    && mv node-v6.11.2-linux-armv7l /usr/local/node \
    && cd /usr/local/bin \
    && ln -s /usr/local/node/bin/node node \
    && ln -s /usr/local/node/bin/npm npm \
    && rm /tmp/node-v6.11.2-linux-armv7l.tar.xz \
    ## Optional - install forever by uncommenting 2 lines below
    # && npm install forever -g \
    # && ln -s /usr/local/node/bin/forever forever \
    ## Clone/install pi-suite from repo
    && cd /tmp \
    && git clone https://github.com/mikesprague/pi-suite.git \
    && cd ./pi-suite && npm install
## Set pi-suite source-code directory as the working directory
WORKDIR /tmp/pi-suite
## Expose port 80 to make pi-suite app available
EXPOSE 80
## Run pi-suite when container starts
CMD ["node", "pi-suite.js"]

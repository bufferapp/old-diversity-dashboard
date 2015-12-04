FROM quantumobject/docker-baseimage
MAINTAINER Michael Erasmus <michael@buffer.com>

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN (echo "deb http://cran.rstudio.com/bin/linux/ubuntu wily/" >> /etc/apt/sources.list && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9)
RUN apt-get update
RUN apt-get install -y -q r-base  \
                    r-base-dev \
                    gdebi-core \
                    libapparmor1 \
                    supervisor \
                    sudo \
                    libssl0.9.8 \
                    libcurl4-openssl-dev \
                    wget \
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')" \
          && update-locale  \
          && wget http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.3.0.403-amd64.deb \
          && gdebi --n shiny-server-1.3.0.403-amd64.deb \
          && rm shiny-server-1.3.0.403-amd64.deb \
          && mkdir -p /srv/shiny-server \
          && cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/.

RUN  R -e "install.packages('rmarkdown', repos='http://cran.rstudio.com/')"

##startup scripts
#Pre-config scrip that maybe need to be run one time only when the container run the first time .. using a flag to don't
#run it again ... use for conf for service ... when run the first time ...
RUN mkdir -p /etc/my_init.d
COPY startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh

##Adding Deamons to containers
RUN mkdir -p /etc/service/shiny-server
COPY shiny-server.sh /etc/service/shiny-server/run
RUN chmod +x /etc/service/shiny-server/run

#pre-config scritp for different service that need to be run when container image is create
#maybe include additional software that need to be installed ... with some service running ... like example mysqld
# COPY pre-conf.sh /sbin/pre-conf
# RUN chmod +x /sbin/pre-conf \
#     && /bin/bash -c /sbin/pre-conf \
#     && rm /sbin/pre-conf


#add files and script that need to be use for this container
#include conf file relate to service/daemon
#additionsl tools to be use internally

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server.
EXPOSE 3838

#creatian of volume
#VOLUME

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]


RUN apt-get update
RUN apt-get install -y libxml2-dev
RUN mkdir /data
RUN chown -R shiny /data
RUN chown -R shiny /usr/local/lib/R/site-library
RUN R -e "install.packages(c('XML', 'ggplot2', 'downloader', 'data.table', 'dplyr', 'tidyr','RCurl', 'RJSONIO', 'whisker', 'scales', 'RColorBrewer', 'shinythemes','zoo', 'ISOweek'),  repos='http://cran.rstudio.com/')"
COPY dependencies /srv/shiny-server/dependencies
RUN R -e "install.packages('/srv/shiny-server/dependencies/rCharts/master.tar.gz', repos = NULL, type = 'source')"
RUN R -e "library(rCharts)"
COPY shiny-server /srv/shiny-server/

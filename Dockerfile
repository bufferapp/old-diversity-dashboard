FROM quantumobject/docker-baseimage:16.04
MAINTAINER Michael Erasmus <michael@buffer.com>

ENV SHINY_VERSION 1.4.4.802

#add repository and update the container
#Installation of nesesary package/software for this containers...
# RUN (echo "deb http://cran.rstudio.com/bin/linux/ubuntu wily/" >> /etc/apt/sources.list && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9)
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9 \
 && apt-get update -qq \
 && apt-get install -yqq \
      curl \
      gdebi-core \
      libapparmor1 \
      libcurl4-openssl-dev \
      libssl-dev \
      libxml2-dev \
      r-base  \
      r-base-dev \
      sudo \
      supervisor \
      wget \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/* \
 && rm -rf /var/lib/apt/lists/*

# RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
# VERSION=$(cat version.txt)  && \
# wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
# gdebi -n ss-latest.deb && \
# rm -f version.txt ss-latest.deb && \
# R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cran.rstudio.com/')" && \
# cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/

RUN R -e "install.packages(c('rmarkdown', 'shiny'), repos='https://cran.rstudio.com/')" \
 && update-locale  \
 && curl -O https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-$SHINY_VERSION-amd64.deb \
 && gdebi --n shiny-server-$SHINY_VERSION-amd64.deb \
 && rm shiny-server-$SHINY_VERSION-amd64.deb \
 && mkdir -p /srv/shiny-server \
 && cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/.

RUN mkdir /data \
 && chown -R shiny /data \
 && chown -R shiny /usr/local/lib/R/site-library \
 && R -e "install.packages(c('XML', 'ggplot2', 'downloader', 'data.table', 'dplyr', 'tidyr','RCurl', 'RJSONIO', 'whisker', 'scales', 'RColorBrewer', 'shinythemes','zoo', 'ISOweek'),  repos='https://cran.rstudio.com/')"

COPY dependencies /srv/dependencies

RUN R -e "install.packages('/srv/dependencies/rCharts/master.tar.gz', repos = NULL, type = 'source')" \
 && R -e "library(rCharts)"


COPY startup.sh /etc/my_init.d/startup.sh
COPY shiny-server.sh /etc/service/shiny-server/run

RUN chmod +x /etc/my_init.d/startup.sh \
             /etc/service/shiny-server/run

COPY shiny-server /srv/shiny-server/

EXPOSE 3838

CMD ["/sbin/my_init"]

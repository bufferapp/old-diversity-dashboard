FROM r-base

ENV SHINY_VERSION 1.4.4.802
# wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt"

RUN apt-get update -qq \
 && apt-get install -yqq \
      gdebi-core \
      libcurl4-openssl-dev \
      libssl-dev \
      libxml2-dev \
 && wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$SHINY_VERSION-amd64.deb" -O ss-latest.deb \
 && gdebi -n ss-latest.deb \
 && rm -f ss-latest.deb \
 && R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cran.rstudio.com/')" \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/* \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /data \
 && chown -R shiny /data \
 && chown -R shiny /usr/local/lib/R/site-library \
 && R -e "install.packages(c('devtools', 'litter', 'XML', 'ggplot2', 'downloader', 'data.table', 'dplyr', 'tidyr','RCurl', 'RJSONIO', 'whisker', 'scales', 'RColorBrewer', 'shinythemes','zoo', 'ISOweek'),  repos='https://cran.rstudio.com/')" \
 && R -e "devtools::install_github('ramnathv/rCharts')"

USER shiny

COPY shiny-server /srv/shiny-server/

EXPOSE 3838

CMD ["/usr/bin/shiny-server"]

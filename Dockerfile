# get shiny serves plus tidyverse packages image
FROM rocker/shiny-verse:latest

# system libraries of general use
RUN apt-get update && apt-get install -y \
  sudo \
  pandoc \
  pandoc-citeproc \
  libcurl4-gnutls-dev \
  libcairo2-dev \
  libxt-dev \
  libssl-dev \
  libssh2-1-dev \
  libudunits2-dev \
  libgdal-dev \
  libgeos-dev \
  libproj-dev

# install R packages required 
RUN R -e "install.packages('tbeptools', repos = c('https://fawda123.r-universe.dev', 'https://cloud.r-project.org'))"
RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('flexdashboard', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('mapview', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('leaflet', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tidyverse', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('sf', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('plotly', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('leafem', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('RColorBrewer', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('scales', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('reactable', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('patchwork', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinyWidgets', repos='http://cran.rstudio.com/')"

# select port
EXPOSE 3838

# allow permission
RUN chown shiny:shiny /var/lib/shiny-server/

COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]

CMD ["/usr/bin/shiny-server.sh"]
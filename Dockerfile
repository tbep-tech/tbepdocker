# get shiny server plus tidyverse packages image
FROM rocker/shiny-verse:latest

# system libraries of general use
RUN apt-get update && apt-get install -y \
  sudo \
  pandoc \
  pandoc-citeproc \
  yad \
  libc6-dev \
  libcurl4-gnutls-dev \
  libcairo2-dev \
  libxt-dev \
  libssl-dev \
  libssh2-1-dev \
  libudunits2-dev \
  libgdal-dev \
  libgeos-dev \
  libproj-dev \
  libfontconfig1-dev \
  libblas-dev

# install R packages required 
RUN R -e "install.packages('tbeptools', repos = c('https://fawda123.r-universe.dev', 'https://cloud.r-project.org'))"
RUN R -e "install.packages('WtRegDO', repos = c('https://fawda123.r-universe.dev', 'https://cloud.r-project.org'))"
RUN R -e "install.packages('data.table', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('extrafont', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('flexdashboard', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('foreign', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('gear', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('ggridges', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('gplots ', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('here', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('htmltools', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('htmlwidgets', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('kableExtra', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('knitr', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('leafem', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('leaflet', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('leaflet.extras', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('mapedit', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('maptools', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('mapview', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('networkD3', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('nlmrt', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('numDeriv', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('OpenMx', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('patchwork', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('plotly', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('plyr', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('RColorBrewer', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('reactable', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('reactablefmtr', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('remotes', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('rgdal', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('rhandsontable', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('rstudioapi', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('scales', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('sf', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinycssloaders', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinydashboard', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinyjs', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinyWidgets', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('sp', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('spdep ', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('stargazer', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('stringr', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('svDialogs', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('units', repos='http://cran.rstudio.com/')"
RUN R -e "remotes::install_github('trestletech/ShinyDash')"

# select port
EXPOSE 3838

# allow permission
RUN chown shiny:shiny /var/lib/shiny-server/

COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]

CMD ["/usr/bin/shiny-server.sh"]
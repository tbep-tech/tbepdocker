# get rocker geospatial image
FROM rocker/geospatial:latest

# install shiny server
RUN /rocker_scripts/install_shiny_server.sh

# get system dependencies
RUN apt-get update && apt-get install -y \
  git \
  cron \
  sudo \
  yad \
  libgit2-dev \
  && rm -rf /var/lib/apt/lists/*

# install standard CRAN packages
RUN install2.r --error --repos 'http://cran.rstudio.com/' \
   box bsicons bslib car curl data.table data.tree dplyr EnvStats extrafont foreign formatR gear gert \
   geosphere ggmap ggplot2 ggridges glue gplots here htmltools htmlwidgets inline kableExtra knitr leafem \
   leaflet leaflet.extras leaflet.extras2 leafpop leafsync librarian lubridate mapedit mapview \
   markdown multcompView networkD3 nlmrt numDeriv OpenMx patchwork plotly plyr purrr RColorBrewer \
   reactable reactablefmtr readr remotes rhandsontable rstan rstudioapi scales sf shiny \
   shinycssloaders shinydashboard shinyjs shinyWidgets sp spdep stargazer stringr svDialogs \
   terra tibble tidyr units webshot2
   
# install specific version of package
RUN R -e "remotes::install_version('flexdashboard', '0.5.2')"

# install github packages
RUN installGithub.r fawda123/WtRegDO
RUN installGithub.r tbep-tech/extractr # original from marinebon/extractr, our version includes a fix
RUN installGithub.r tbep-tech/tbeptools

# select port
EXPOSE 3838

# create directory and set permissions
RUN mkdir -p /var/lib/shiny-server/ \
    /var/log \
    && chown -R shiny:shiny /var/lib/shiny-server/ \
    && chown -R shiny:shiny /var/log
    
COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]

CMD ["/usr/bin/shiny-server.sh"]
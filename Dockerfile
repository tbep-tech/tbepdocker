# get rocker geospatial image
FROM rocker/geospatial:latest

# Install environment variable defaults (overridden by docker-compose or docker run)
ENV RSTUDIO_USER=rstudio
ENV RSTUDIO_PASSWORD=changeme

# install shiny server
RUN /rocker_scripts/install_shiny_server.sh

# install RStudio Server
RUN /rocker_scripts/install_rstudio.sh

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
   shinycssloaders shinydashboard shinyjs shinyWidgets slider sp spdep stargazer StormR stringr svDialogs \
   terra thematic tibble tidyr units webshot2
   
# install specific version of package
RUN R -e "remotes::install_version('flexdashboard', '0.5.2')"

# install github packages
RUN installGithub.r fawda123/WtRegDO
RUN installGithub.r tbep-tech/extractr # original from marinebon/extractr, our version includes a fix
RUN installGithub.r tbep-tech/tbeptools

# select ports (3838 for Shiny, 8787 for RStudio)
EXPOSE 3838 8787

# create directory and set permissions
RUN mkdir -p /var/lib/shiny-server/ \
    /var/log \
    && chown -R shiny:shiny /var/lib/shiny-server/ \
    && chown -R shiny:shiny /var/log

# Copy and set up starter script
COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]

# Create a new startup script that creates user and launches both services
RUN echo '#!/bin/bash\n\
# Create user with provided environment variables\n\
useradd -m ${RSTUDIO_USER}\n\
echo "${RSTUDIO_USER}:${RSTUDIO_PASSWORD}" | chpasswd\n\
adduser ${RSTUDIO_USER} sudo\n\
\n\
# Start services\n\
service rstudio-server start\n\
exec /usr/bin/shiny-server.sh\n\
' > /usr/bin/start-services.sh && \
chmod +x /usr/bin/start-services.sh

# Add cron job for data updates
RUN echo "*/15 * * * * /srv/shiny-server/apps/climate-dash/server/update_data.R >> /var/log/shiny-server/climate_data_update.log 2>&1" | crontab -

CMD ["/usr/bin/start-services.sh"]
# get rocker geospatial image
FROM rocker/geospatial:4.6.1

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
  nano \
  cmake \
  && rm -rf /var/lib/apt/lists/*

# install core data/utility packages
RUN install2.r --error --repos 'http://cran.rstudio.com/' \
   box bsicons bslib car curl data.table data.tree dplyr EnvStats extrafont foreign formatR gert \
   glue here inline kableExtra knitr librarian lubridate markdown patchwork plyr purrr RColorBrewer \
   readr remotes rstudioapi scales stringr tibble tidyr

# pin Deriv version
RUN R -e "remotes::install_version('Deriv', version='4.2.0', repos='http://cran.rstudio.com/')"

# install spatial/mapping packages
RUN install2.r --error --repos 'http://cran.rstudio.com/' \
   geosphere ggalluvial ggmap ggplot2 ggridges gplots highcharter htmltools htmlwidgets \
   leafem leaflet leaflet.extras leaflet.extras2 leafpop leafsync mapedit \
   mapview plotly sf sp spdep terra units

# install stats/modelling packages (rstan kept here so CRAN resolves its dependencies)
RUN install2.r --error --repos 'http://cran.rstudio.com/' \
   multcompView networkD3 nlmrt numDeriv OpenMx rstan slider stargazer StormR svDialogs

# install shiny/UI packages
RUN install2.r --error --repos 'http://cran.rstudio.com/' \
   reactable rhandsontable shiny shinycssloaders shinydashboard shinyjs shinyWidgets \
   thematic webshot2

# reactablefmtr removed from CRAN; install from archive
RUN R -e "remotes::install_version('reactablefmtr', version='2.0.0', repos='http://cran.rstudio.com/')"

# install gear separately (verify CRAN availability)
RUN install2.r --error --repos 'http://cran.rstudio.com/' \
   gear
   
# install specific version of package
RUN R -e "remotes::install_version('flexdashboard', '0.5.2')"

# install github packages
RUN installGithub.r \
    fawda123/WtRegDO \
    marinebon/extractr \
    tbep-tech/tbeptools \
    tbep-tech/slrcsap
    
# libmariadb-dev for RMariaDB, must be installed in this order
RUN apt-get update && apt-get install -y \
  libmariadb-dev \
  && rm -rf /var/lib/apt/lists/*

# install seagrass transect entry portal packages
RUN install2.r --error --repos 'http://cran.rstudio.com/' \
   DT pool RMariaDB shinymanager
   
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
# Fix permissions for mounted Shiny apps\n\
chown -R shiny:shiny /srv/shiny-server/\n\
\n\
# Persist env vars for cron jobs (cron does not inherit Docker env)\n\
printenv | grep -E "^(GITHUB_PAT|GITHUB_USERNAME|GIT_USER|GIT_EMAIL)=" | sed "s/^/export /" > /root/.cron_env\n\
chmod 600 /root/.cron_env\n\
\n\
# Start services\n\
service cron start\n\
/usr/lib/rstudio-server/bin/rserver --server-daemonize=1\n\
exec /usr/bin/shiny-server.sh\n\
' > /usr/bin/start-services.sh && \
chmod +x /usr/bin/start-services.sh

# Add cron job for data updates, daily at midnight
RUN printf '0 0 * * * cd /srv/shiny-server/climate-dash; /usr/local/bin/Rscript ./server/update_data.R >> /var/log/shiny-server/climate_data_update.log 2>&1\n0 1 * * 2 . /root/.cron_env; cd /srv/shiny-server/climate-dash; /usr/local/bin/Rscript ./server/git_push.R >> /var/log/shiny-server/climate_git_push.log 2>&1\n' | crontab -

CMD ["/usr/bin/start-services.sh"]

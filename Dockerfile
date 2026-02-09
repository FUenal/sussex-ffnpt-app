FROM rocker/shiny-verse:4.3.2

## install debian packages
RUN apt-get update -qq && \
    apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    r-cran-v8 \
    libv8-dev \
    net-tools \
    libprotobuf-dev \
    protobuf-compiler \
    libjq-dev \
    libudunits2-0 \
    libudunits2-dev \
    libgdal-dev \
    libssl-dev \
    build-essential \
    libglpk40 \
    littler \
    cron && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/

RUN install2.r --error \
    magrittr \
    dplyr \
    ggplot2 \
    leaflet \
    geojsonio \
    shiny \
    shinyWidgets \
    shinydashboard \
    shinythemes \
    kableExtra \
    highcharter \
    data.table \
    DT \
    shinyjs \
    shiny.semantic \
    sass \
    googlesheets4 \
    gargle \
    lubridate

# copy the app to the image
COPY app.R /srv/shiny-server/
COPY src /srv/shiny-server/src

# select port
EXPOSE 3838

# allow permission
RUN sudo chown -R shiny:shiny /srv/shiny-server

# Copy further configuration files into the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh

#make executable the sh so that the server can boot
RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"]

# run app
CMD ["/usr/bin/shiny-server.sh"]

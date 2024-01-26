#'//////////////////////////////////////////////////////////////////////////////
#' FILE: app.R
#' AUTHOR: Fatih Uenal
#' CREATED: 19-03-2021
#' MODIFIED: 19-03-2021
#' PURPOSE: Supply-side policies interactive mapping tool
#' PACKAGES: various, see below
#' COMMENTS: NA
#'//////////////////////////////////////////////////////////////////////////////

## includes code adapted from the following sources:
# https://github.com/eparker12/nCoV_tracker
# https://davidruvolo51.github.io/shinytutorials/tutorials/rmarkdown-shiny/
# https://github.com/rstudio/shiny-examples/blob/master/087-crandash/
# https://rviews.rstudio.com/2019/10/09/building-interactive-world-maps-in-shiny/
# https://github.com/rstudio/shiny-examples/tree/master/063-superzip-example

# ShinyProxy + Docker Turtorial here: https://towardsdatascience.com/an-open-source-solution-to-deploy-enterprise-level-r-shiny-applications-2e19d950ff35

## Data Pre-processing Script
# Pre-processing data for app
# PreprocessingScript.R
# Creates countries_overview_large, state_city_breakdown_map, oil_production, gas_production, coal_production, policy files

# update data with automated script
# source("divestment_data_daily.R") # option to update weekly new divestment policies
# source("crowdsourced_data_daily.R") # option to update weekly new manual entry policies
# source("newsAPI_data_weekly.R") # option to update weekly NewsAPI entries

# load required packages
library(magrittr)
library(dplyr)
# library(ggplot2)
library(leaflet)
library(geojsonio)
library(shiny)
library(shinyWidgets)
library(shiny.semantic)
# library(shinythemes)
library(kableExtra)
library(shinyjs)
library(highcharter)
library(data.table)
library(DT)
library(sass)

sass(
  sass::sass_file("styles/main.scss"),
  options = sass_options(output_style = "compressed"),
  cache = NULL,
  output = "www/css/sass.min.css"
)

# pkgs
suppressPackageStartupMessages(library(shiny))

# Load Image
load("image.RData")

# components
source("components/cards.R")
source("components/maps.R")

source("pages/introduction.R")
source("pages/policy_overview.R")
source("pages/country_profiles.R")
source("pages/about.R")
source("pages/how_to.R")
source("pages/download.R")

## Deploying app to shiny.io
#library(rsconnect)
#rsconnect::deployApp(account="fuenal")

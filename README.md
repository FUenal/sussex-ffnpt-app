## Fossil Fuel Policy Tracker & Interactive Mapping Tool

This github page contains the code and input data for the [Fossil Fuel Policy Tracker & Interactive Mapping Tool](https://fuenal.shinyapps.io/FFTNP_tracker-master/) developed by the Fossil Fuel Non-Proliferation Treats Initiative.

Input data are obtained from the [Sussex University github page](https://profiles.sussex.ac.uk/p104921-peter-newell).

The Shiny app, will be launched on 19th March 2021, aims to complement existing Climate Change and Fossil Fuel mapping dashboards (such as those developed by the [the Grantham Research Institute on Climate Change and the Environment](https://www.climate-laws.org/#map-section) and the [Climate Action Tracker](https://climateactiontracker.org)) with a particular focus on supply-side policies, including a Fossil Fuel City Impact Map to help organizations to identify best practices in the field and facilitate target city choices by provinding a propensity action score. 

## Shiny interface

Follow [this]( https://fuenal.shinyapps.io/Fossil_Fuel_Policy_Tracker/) link for the interactive Shiny app. A screenshot of the interface is provided below.

![Shiny app interface](src/www/app_image.png) 

## Analysis code

Key elements of the analysis code are as follows:
- *divestment_data_daily.R* – an R script that extracts and reformats information from the [Fossil Fuel Divestment Weppage](https://gofossilfree.org/divestment/commitments/). The output files are saved in the *input_data* folder.
- *app.R* - an R script used to render the Shiny app. This consists of several plotting functions as well as the ui (user interface) and server code required to render the Shiny app. The script has become more complex over time as a growing number of interactive features has been added.
- *input_data* - a folder containing dynamic input data relating to the evolving supply-side policy tracking(updated by *divestment_data_daily.R*) and static input data relating to previously identified and categorized policy database and country mapping coordinates.

## Updates

The [Shiny app](https://fuenal.shinyapps.io/FFTNP_tracker-master/) automatically updates itself based on the code in *divestment_data_daily.R*. 

## Other resources

Several resources proved invaluable when building this app, including:

- From [a Tutorial on using RMarkdown files in Shiny by David Ruvolo](https://davidruvolo51.github.io/shinytutorials/tutorials/rmarkdown-shiny/)

- The [nCov_tracker by Dr Edward Parker and Quentin Leclerc](https://github.com/eparker12/nCoV_tracker);

- A [tutorial by Florianne Verkroost](https://rviews.rstudio.com/2019/10/09/building-interactive-world-maps-in-shiny/) on building interactive maps;

- The [SuperZIP app](https://shiny.rstudio.com/gallery/superzip-example.html) and [associated code](https://github.com/rstudio/shiny-examples/tree/master/063-superzip-example);

- The [RStudio Leaflet tutorials](https://rstudio.github.io/leaflet/).

## Project structure

The application files and the pre-processing scripts are in the `/src` directory. With
the following file structure:
 * [app.R](app.R) This file starts the app by sourcing the `/src` directory.
 * [Dockerfile](Dockerfile) Docker image definition. On initial provision it runs the preprocessing phase, updates (./src/image.RData) and performs some minimal testing.
 * [docker-compose.yml](docker-compose.yml) Used to build docker image and start the app at local (http://localhost:3838/).
 * [src](./src) Main folder of the application.
   * [PreprocessingScript.R](./src/PreprocessingScript.R) This script does the pre-processing 
   and generates a Global environment image used to boot the app.
   * [ui.R](./src/ui.R) UI script of shiny app.
   * [server.R](./src/server.R) Server side logic of the application.
   * [global.R](./src/global.R) Used on initiallization to load the application dependencies.
   * [components](./src/components) Folder with R front-end components.
   * [content](./src/content) Documents used to render the Introduction and About pages. Edits will 
   be rendered on restart using [rmarkdown](https://cran.r-project.org/web/packages/rmarkdown/index.html).
   * [input_data](./src/input_data) Imported data files in `.xlsx` and `.csv` format.
   * [pages](./src/pages) Definition files of the pages displayed in tabs. To arrange
   HTML containers the `shiny.sematic` grid system.
   * [styles](./src/styles) All `.scss` files needed to generate minified `.css`. 
   They are processed to produce the minified `.css` during app start using the 
   R package [sass](https://cran.r-project.org/web/packages/sass/index.html).
     * [modules](./src/styles/modules) Scss files for modules.
     * [partials](./src/styles/partials) Scss files for partilas.
   * [www](./src/www) Front end assets.
     * [icons](./src/www/icons) Project Icons.
     * [css](./src/www/css) Auto generated `.css` goes here so do not edit. To change css style 
     edit `.scss` files in folder `/styles`.
     * [js](./src/www/js) Custom Javascript dependencies.
   * [tests](./src/tests) Tests used to ensure that pre-processing is ok, and 
   app dependencies are in place. Used also to built the docker image. 
   From `app/src` as working directory run `source("tests/testthat.R")`.
   * [image.RData](./src/image.RData) This object is used to load data. It encloses
   all the Global environment of the data pre-processing script, and loads once on boot up.

To build the app locally,

- Install Docker and docker-compose.

- Run from terminal,

```
sudo docker-compose up -d --build 
```
- Open your browser and visit (http://localhost:3838/)

- Stop the app

```
sudo docker-compose down
```

## Author
Dr Fatih Uenal, Fellow @ Faculty AI & University of Cambridge

## Contact
mars.fatih@gmail.com
# FFNPT_Tracker

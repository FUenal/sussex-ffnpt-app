## Supply-side policies interactive mapping tool: script to scrape and reformat "Divestment" data from scratch
## Dr. Fatih Uenal, Faculty AI <-  Data Science Fellow (mars.fatih@gmail.com), last updated March 2021

## Data extracted from "Go fossil free." data obtained from following website
# https://docs.google.com/spreadsheets/d/1ScfyuRP-CjoEZqq-MYho0CAWirCyWUhzsaBpEZ1uXZY/edit#gid=611799167" 
# For more information on this data see: https://gofossilfree.org/divestment/commitments/ (New Website: https://divestmentdatabase.org/)


# load libraries
if(!require(stringr)) install.packages("stringr", repos = "http://cran.us.r-project.org")
if(!require(stringi)) install.packages("stringi", repos = "http://cran.us.r-project.org")
if(!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")
if(!require(magrittr)) install.packages("magrittr", repos = "http://cran.us.r-project.org")
if(!require(rvest)) install.packages("rvest", repos = "http://cran.us.r-project.org")
if(!require(robotstxt)) install.packages("robotstxt", repos = "http://cran.us.r-project.org")
if(!require(googlesheets4)) install.packages("googlesheets4", repos = "http://cran.us.r-project.org")
if(!require(DataCombine)) install.packages("DataCombine", repos = "http://cran.us.r-project.org")

# Check for webpage scraping legality
#paths_allowed(paths = c("https://docs.google.com/spreadsheets/d/1zJjQjmYrDRvDMU0eAZ_ZYe28Dvp2RuEH-GzEwSbhm1w/edit#gid=611799167"))

# import googlesheet into R
sheet <- read_sheet("https://docs.google.com/spreadsheets/d/1zJjQjmYrDRvDMU0eAZ_ZYe28Dvp2RuEH-GzEwSbhm1w/edit#gid=611799167")

# Drop first five rows
sheet1 = sheet[-c(1:3), ]

# select relevant columns from sheet and store in new csv file
divestment_scraped = sheet1 %>% select(c("Type of Divestment", "Organization", "Org_Type","Country", "City", "Announcement")) #, , "Date of Record"
names(divestment_scraped) = c("Type", "Organisation", "Organisation_type", "Country", "City", "Source") # , "Start"

# Add Category column: Divestment
divestment_scraped$Category <- "Divestment"
divestment_scraped = divestment_scraped[c(7, 1:6)]

# Convert list to character ("Source" column)
divestment_scraped$Source <- as.character(divestment_scraped$Source)
divestment_scraped$Type <- as.character(divestment_scraped$Type)
divestment_scraped$Organisation <- as.character(divestment_scraped$Organisation)
divestment_scraped$Organisation_type <- as.character(divestment_scraped$Organisation_type)
divestment_scraped$Country <- as.character(divestment_scraped$Country)
divestment_scraped$City <- as.character(divestment_scraped$City)
#divestment_scraped$Start <- as.character(divestment_scraped$Start)

# # Convert list to date
# divestment_scraped$Start <-lubridate::dmy(divestment_scraped$Start, truncated = 2L)
# 
# # extract dates from moratoria_bans_limits data
# divestment_scraped$Start = as.Date(divestment_scraped$Start, format="%m-%d-%Y")
# class(divestment_scraped$Start)

# Replace  NULLs with NAs and NAs with with appropriate values
divestment_scraped[divestment_scraped == "NULL"] <- NA

divestment_scraped <- divestment_scraped %>% 
        replace(is.na(.), "--")

# divestment_scraped$Source[is.na(divestment_scraped$Source)] = 0

## Correcting country names in column 5
## using stringr for this:
divestment_scraped <- divestment_scraped %>% mutate_at(5, function(t) {
        str_replace(t, pattern = 'USA', replacement = "United States of America")
})

divestment_scraped <- divestment_scraped %>% mutate_at(5, function(t) {
        str_replace(t, pattern = 'US', replacement = "United States of America")
})

divestment_scraped <- divestment_scraped %>% mutate_at(5, function(t) {
        str_replace(t, pattern = 'UK', replacement = "United Kingdom")
})

divestment_scraped <- divestment_scraped %>% mutate_at(5, function(t) {
        str_replace(t, pattern = 'Ausralia', replacement = "Australia")
})

divestment_scraped <- divestment_scraped %>% mutate_at(5, function(t) {
        str_replace(t, pattern = 'New Zeland', replacement = "New Zealand")
})

divestment_scraped <- divestment_scraped %>% mutate_at(5, function(t) {
        str_replace(t, pattern = 'New Zealnd', replacement = "New Zealand")
})

divestment_scraped <- divestment_scraped %>% mutate_at(5, function(t) {
        str_replace(t, pattern = 'New Zealad', replacement = "New Zealand")
})

divestment_scraped <- divestment_scraped %>% mutate_at(5, function(t) {
        str_replace(t, pattern = 'Tanzania', replacement = "Tanzania, United Republic of")
})

divestment_scraped <- divestment_scraped %>% mutate_at(5, function(t) {
        str_replace(t, pattern = 'The Philippines', replacement = "Philippines")
})

divestment_scraped <- divestment_scraped %>% mutate_at(5, function(t) {
        str_replace(t, pattern = 'Singapure', replacement = "Singapore")
})

divestment_scraped <- divestment_scraped %>% mutate_at(5, function(t) {
        str_replace(t, pattern = 'República Dominicana', replacement = "Dominican Republic")
})

divestment_scraped <- divestment_scraped %>% mutate_at(5, function(t) {
        str_replace(t, pattern = 'Vatican', replacement = "Holy See (Vatican City State)")
})


# # write cs file
# write.csv(divestment_scraped, file = "src/input_data/divestment_scraped_2022.csv")
# 
# library("xlsx")
# # Write the first data set in a new workbook
# write.xlsx(divestment_scraped, file = "src/input_data/divestment_2022.xlsx",
#            sheetName = "divestment_2022", append = FALSE)
# 
# 
# data <- read.csv("src/input_data/divestment_scraped_2022.csv")
# # Dropping first columns
# #divestment_scraped <- divestment_scraped %>% select(-X)
# 
# # Add ISOs
# library(readxl)
# country_overview = read_excel("src/input_data/FF NPT Tracker DRAFT WIP.xlsx", sheet = 2)
# divestment_scraped['ISO3'] <- country_overview$ISO3[match(country_overview$Country, moratoria_bans_limits$Country)]
# 
# # Adjust Country names
# 
# # Testing scraped and wrangled table
# library(readr)
# divestment_scraped <- read_csv("divestment_scraped.csv")
# View(divestment_scraped)
# 
# library(DT)
# DT::datatable(divestment_scraped)
# 
# DT::datatable(divestment_scraped %>%
#                 group_by(Country) %>%
#                 select(c("Country", "City", "Type", "Organisation", "Organisation_type", "Source")) %>%
#                 rename("Organisation type" = "Organisation_type") %>%
#                 replace(is.na(.), "--"))
# 
# # Datapasta was of table scraping: https://www.business-science.io/code-tools/2021/04/20/datapasta-webscrape.html
# install.packages("datapasta")
# library(datapasta)
# library(tidyverse)

        
        
        
        
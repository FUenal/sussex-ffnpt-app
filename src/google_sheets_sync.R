#' ============================================================================
#' Google Sheets Sync Script
#' ============================================================================
#'
#' This script syncs data from Google Sheets to local CSV files.
#' It uses service account authentication for non-interactive server use.
#'
#' SETUP INSTRUCTIONS:
#' 1. Go to https://console.cloud.google.com/
#' 2. Create a new project (or use existing)
#' 3. Enable "Google Sheets API"
#' 4. Go to "Credentials" > "Create Credentials" > "Service Account"
#' 5. Download the JSON key file
#' 6. Rename it to "google-credentials.json" and place in src/ folder
#' 7. Share your Google Sheets with the service account email
#'    (found in the JSON file as "client_email")
#'
#' ============================================================================

library(googlesheets4)
library(dplyr)
library(lubridate)

# Load configuration
source("config.R")

# Path to service account credentials
CREDENTIALS_PATH <- "google-credentials.json"

# ============================================================================
# AUTHENTICATION
# ============================================================================

authenticate_google_sheets <- function() {
  if (!file.exists(CREDENTIALS_PATH)) {
    message("Google credentials file not found: ", CREDENTIALS_PATH)
    message("Google Sheets sync is disabled. Using local CSV files.")
    return(FALSE)
  }

  tryCatch({
    gs4_auth(path = CREDENTIALS_PATH)
    message("Google Sheets authentication successful")
    return(TRUE)
  }, error = function(e) {
    message("Google Sheets authentication failed: ", e$message)
    return(FALSE)
  })
}

# ============================================================================
# DATA SYNC FUNCTIONS
# ============================================================================

sync_divestment_data <- function() {
  message("Syncing divestment data from Google Sheets...")

  tryCatch({
    # Read from Google Sheet
    sheet <- read_sheet(
      get_config("sheet_divestment"),
      sheet = 1
    )

    # Skip header rows
    sheet <- sheet[-c(1:3), ]

    # Select and rename columns
    divestment <- sheet %>%
      select(
        Type = "Type of Divestment",
        Organisation = "Organization",
        Organisation_type = "Org_Type",
        Country = "Country",
        City = "City",
        Source = "Announcement"
      ) %>%
      mutate(
        Category = "Divestment",
        # Convert all to character
        across(everything(), as.character)
      )

    # Standardize country names
    divestment <- standardize_countries(divestment, "Country")

    # Replace NAs
    divestment[is.na(divestment)] <- "--"

    # Write to CSV
    write.csv(divestment, "input_data/divestment_synced.csv", row.names = FALSE)

    message("Divestment data synced: ", nrow(divestment), " rows")
    return(TRUE)

  }, error = function(e) {
    message("Failed to sync divestment data: ", e$message)
    return(FALSE)
  })
}

sync_crowdsourced_data <- function() {
  message("Syncing crowdsourced policy data from Google Sheets...")

  tryCatch({
    sheet_url <- get_config("sheet_crowdsourced")

    # Read MBL sheet
    sheet_mbl <- read_sheet(sheet_url, sheet = 1)
    sheet_mbl <- sheet_mbl[-c(1:3), ]

    mbl <- sheet_mbl %>%
      select(
        Country = "Country",
        `City, state, or province` = "City_state_or_province",
        Start = "Start",
        End = "End",
        Category = "Category",
        `Fuel Type` = "Fuel_type",
        `Fuel Subtype` = "Fuel_subtype",
        `Sources and more info` = "Sources_and_more_info"
      ) %>%
      mutate(across(where(is.list), as.character))

    # Read Subsidy Removal sheet
    sheet_sr <- read_sheet(sheet_url, sheet = 2)
    sheet_sr <- sheet_sr[-c(1:3), ]

    sr <- sheet_sr %>%
      select(
        Country = "Country",
        `City, state, or province` = "City_state_or_province",
        Start = "Start",
        End = "End",
        Category = "Category",
        `Fuel Type` = "Fuel_type",
        Description = "Description",
        `Sources and more info` = "Sources_and_more_info"
      ) %>%
      mutate(across(where(is.list), as.character))

    # Standardize countries
    mbl <- standardize_countries(mbl, "Country")
    sr <- standardize_countries(sr, "Country")

    # Replace NAs
    mbl[is.na(mbl)] <- "--"
    sr[is.na(sr)] <- "--"

    # Write to CSV
    write.csv(mbl, "input_data/moratoria_bans_limits_synced.csv", row.names = FALSE)
    write.csv(sr, "input_data/subsidy_removal_synced.csv", row.names = FALSE)

    message("Crowdsourced data synced: MBL=", nrow(mbl), ", SR=", nrow(sr), " rows")
    return(TRUE)

  }, error = function(e) {
    message("Failed to sync crowdsourced data: ", e$message)
    return(FALSE)
  })
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

standardize_countries <- function(df, col) {
  replacements <- c(
    "USA" = "United States of America",
    "US" = "United States of America",
    "UK" = "United Kingdom",
    "Ausralia" = "Australia",
    "New Zeland" = "New Zealand",
    "New Zealnd" = "New Zealand",
    "New Zealad" = "New Zealand",
    "Tanzania" = "Tanzania, United Republic of",
    "The Philippines" = "Philippines",
    "Singapure" = "Singapore",
    "República Dominicana" = "Dominican Republic",
    "Vatican" = "Holy See (Vatican City State)"
  )

  for (old in names(replacements)) {
    df[[col]] <- gsub(old, replacements[old], df[[col]], fixed = TRUE)
  }

  return(df)
}

# ============================================================================
# MAIN SYNC FUNCTION
# ============================================================================

#' Run full data sync from Google Sheets
#' @return TRUE if sync successful, FALSE otherwise
run_sync <- function() {
  if (!get_config("enable_sheets")) {
    message("Google Sheets sync is disabled in config.R")
    return(FALSE)
  }

  if (!authenticate_google_sheets()) {
    return(FALSE)
  }

  success <- TRUE

  # Sync each data source
  if (!sync_divestment_data()) success <- FALSE
  if (!sync_crowdsourced_data()) success <- FALSE

  if (success) {
    # Update last sync timestamp
    writeLines(
      format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      "input_data/.last_sync"
    )
    message("All data synced successfully at ", Sys.time())
  }

  return(success)
}

# ============================================================================
# AUTO-RUN IF CALLED DIRECTLY
# ============================================================================

if (!interactive()) {
  run_sync()
}

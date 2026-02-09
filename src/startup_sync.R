#' ============================================================================
#' Startup Sync Script
#' ============================================================================
#'
#' This script runs at container startup to sync data from Google Sheets.
#' It only syncs if:
#'   1. Google Sheets sync is enabled in config.R
#'   2. Valid credentials file exists
#'
#' ============================================================================

setwd("/srv/shiny-server/src")

message("=== FFNPT Tracker Startup ===")
message("Time: ", Sys.time())

# Check if sync is enabled
source("config.R")

if (get_config("enable_sheets")) {
  message("Google Sheets sync is ENABLED")

  # Run sync
  tryCatch({
    source("google_sheets_sync.R")
    run_sync()
  }, error = function(e) {
    message("Sync failed (will use existing data): ", e$message)
  })

} else {
  message("Google Sheets sync is DISABLED")
  message("Using existing local CSV files")
}

message("=== Startup complete ===")

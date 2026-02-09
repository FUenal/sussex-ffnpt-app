#' ============================================================================
#' Webhook Sync Trigger
#' ============================================================================
#'
#' Simple HTTP endpoint that triggers a data sync when called.
#' Can be triggered by:
#'   - Google Apps Script when sheet is edited
#'   - Manual curl request
#'   - Any HTTP client
#'
#' Run with: Rscript webhook_sync.R
#' Access at: http://localhost:8888/sync
#'
#' ============================================================================

library(plumber)

#* @get /sync
#* @post /sync
function(req, res) {
  setwd("/srv/shiny-server/src")

  tryCatch({
    source("google_sheets_sync.R")
    result <- run_sync()

    if (result) {
      list(
        status = "success",
        message = "Data synced successfully",
        timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      )
    } else {
      res$status <- 500
      list(
        status = "error",
        message = "Sync failed - check logs"
      )
    }
  }, error = function(e) {
    res$status <- 500
    list(
      status = "error",
      message = e$message
    )
  })
}

#* @get /health
function() {
  list(
    status = "ok",
    service = "FFNPT Webhook Sync",
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  )
}

#* @get /last-sync
function() {
  sync_file <- "/srv/shiny-server/src/input_data/.last_sync"

  if (file.exists(sync_file)) {
    list(
      last_sync = readLines(sync_file)[1],
      status = "ok"
    )
  } else {
    list(
      last_sync = "never",
      status = "no sync recorded"
    )
  }
}

# Run the API if executed directly
if (!interactive()) {
  pr <- plumb(commandArgs(trailingOnly = FALSE)[4])
  pr$run(host = "0.0.0.0", port = 8888)
}

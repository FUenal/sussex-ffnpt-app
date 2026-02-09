#' ============================================================================
#' FFNPT Tracker Configuration File
#' ============================================================================
#'
#' This file contains settings that can be easily updated by non-technical users.
#'
#' HOW TO UPDATE:
#' 1. Open this file in any text editor (TextEdit, Notepad, etc.)
#' 2. Change the values below (keep the quotes around dates/text)
#' 3. Save the file
#' 4. Restart the app for changes to take effect
#'
#' ============================================================================

# =============================================================================
# LAST UPDATED DATE
# =============================================================================
# This date appears on the About page
# Format: "DD/MM/YY" (day/month/year)
# Example: "16/01/24" means January 16, 2024

APP_LAST_UPDATED <- "16/01/24"

# =============================================================================
# DEFAULT COUNTRY
# =============================================================================
# The country shown when the app first loads
# Must match exactly a country name in the data (e.g., "United Kingdom", "Germany")

APP_DEFAULT_COUNTRY <- "United Kingdom"

# =============================================================================
# DATA SOURCE SETTINGS
# =============================================================================
# Set to TRUE to enable automatic data refresh from Google Sheets
# Set to FALSE to use only local CSV files

ENABLE_GOOGLE_SHEETS_SYNC <- TRUE

# Google Sheet ID (the part after /d/ in the URL)
GOOGLE_SHEET_ID <- "1oynJ1bW4QkKBLGFz8FtFeBzz0sMr-TRw"

# Sheet tab GIDs (found in the URL after gid=)
GOOGLE_SHEET_GIDS <- list(
  country_overview      = "2065717366",
  state_city_breakdown  = "86508682",
  moratoria_bans_limits = "43505787",
  subsidy_removal       = "1514766873",
  divestment            = "2055981357",
  country_iso           = "1342506367"
)

# Download timeout in seconds per sheet
GOOGLE_SHEET_TIMEOUT <- 30

# =============================================================================
# CONTACT INFORMATION
# =============================================================================
# Displayed in the About section

CONTACT_EMAIL <- "info@fossilfueltracker.org"
CONTACT_WEBSITE <- "https://fossilfueltreaty.org"

# =============================================================================
# DO NOT EDIT BELOW THIS LINE
# =============================================================================

# Function to get config values (used by other R files)
get_config <- function(key) {
  switch(key,
    "last_updated" = APP_LAST_UPDATED,
    "default_country" = APP_DEFAULT_COUNTRY,
    "enable_sheets" = ENABLE_GOOGLE_SHEETS_SYNC,
    "sheet_id" = GOOGLE_SHEET_ID,
    "contact_email" = CONTACT_EMAIL,
    "contact_website" = CONTACT_WEBSITE,
    NULL
  )
}

# Print confirmation when loaded
message("Config loaded: Last updated = ", APP_LAST_UPDATED)

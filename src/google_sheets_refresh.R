#' ============================================================================
#' Google Sheets Refresh Module
#' ============================================================================
#' Pulls fresh policy data from the Google Sheet on app startup.
#' Computes aggregation columns needed by the app (pie charts, KPIs, map).
#' Falls back gracefully to image.RData data on failure.
#'
#' Called from global.R after loading image.RData but before sourcing
#' components (which rebuild the basemap from the data objects).
#' ============================================================================

# ---------------------------------------------------------------------------
# Helper: Download a single Google Sheet tab as CSV
# ---------------------------------------------------------------------------
download_gsheet_csv <- function(sheet_id, gid, timeout_sec = 30) {
  url <- paste0(
    "https://docs.google.com/spreadsheets/d/", sheet_id,
    "/export?format=csv&gid=", gid
  )
  tryCatch({
    tmp <- tempfile(fileext = ".csv")
    old_timeout <- getOption("timeout")
    options(timeout = timeout_sec)
    on.exit(options(timeout = old_timeout), add = TRUE)
    utils::download.file(url, tmp, mode = "wb", quiet = TRUE)
    df <- utils::read.csv(tmp, stringsAsFactors = FALSE, check.names = FALSE)
    unlink(tmp)
    df
  }, error = function(e) {
    message("  Download failed for gid=", gid, ": ", conditionMessage(e))
    NULL
  })
}

# ---------------------------------------------------------------------------
# Helper: Validate policy data against reference country/ISO list
# ---------------------------------------------------------------------------
validate_policy_data <- function(data, sheet_name, valid_countries, valid_iso3) {
  if (is.null(data) || nrow(data) == 0) return(data)

  issues <- character(0)
  rows_to_drop <- logical(nrow(data))

  # Trim whitespace from key columns
  if ("Country" %in% names(data)) data$Country <- trimws(data$Country)
  if ("ISO3" %in% names(data)) data$ISO3 <- trimws(data$ISO3)
  if ("ISO2" %in% names(data)) data$ISO2 <- trimws(data$ISO2)

  # Entries that are valid but not in the ISO reference (supranational/special)
  special_entities <- c("International", "European Union")

  # Check ISO3 codes
  if ("ISO3" %in% names(data)) {
    bad_iso <- which(!data$ISO3 %in% valid_iso3 & !is.na(data$ISO3) & data$ISO3 != "" &
                     !data$ISO3 %in% c("EU", "--"))
    for (i in bad_iso) {
      suggestion <- ""
      matches <- agrep(data$ISO3[i], valid_iso3, value = TRUE, max.distance = 1)
      if (length(matches) > 0) suggestion <- paste0(" Did you mean '", matches[1], "'?")
      issues <- c(issues, paste0(
        "  WARNING [", sheet_name, " row ", i, "]: Unknown ISO3 '",
        data$ISO3[i], "' for country '", data$Country[i], "'.", suggestion
      ))
      rows_to_drop[i] <- TRUE
    }
  }

  # Check country names (warn-only — don't drop rows since aggregations join on ISO3)
  if ("Country" %in% names(data)) {
    bad_country <- which(
      !data$Country %in% valid_countries &
      !data$Country %in% special_entities &
      !is.na(data$Country) & data$Country != "" & data$Country != "--" &
      !rows_to_drop  # skip rows already flagged by ISO3
    )
    for (i in bad_country) {
      suggestion <- ""
      matches <- agrep(data$Country[i], valid_countries, value = TRUE, max.distance = 0.15)
      if (length(matches) > 0) suggestion <- paste0(" Did you mean '", matches[1], "'?")
      issues <- c(issues, paste0(
        "  NOTE [", sheet_name, " row ", i, "]: Country name '",
        data$Country[i], "' not in ISO reference.", suggestion
      ))
      # Row kept — ISO3 is valid so aggregations will still work
    }
  }

  # Validate category values
  valid_categories <- list(
    "Moratoria, Bans & Limits" = c("Moratorium", "Ban", "Partial Ban", "Limitation"),
    "Subsidy Removal" = c("Subsidy Removal", "Subsidy Reform"),
    "Divestment" = c("Divestment")
  )

  if ("Category" %in% names(data) && sheet_name %in% names(valid_categories)) {
    expected <- valid_categories[[sheet_name]]
    bad_cat <- which(!data$Category %in% expected & !is.na(data$Category) & data$Category != "")
    for (i in bad_cat) {
      issues <- c(issues, paste0(
        "  WARNING [", sheet_name, " row ", i, "]: Unexpected category '",
        data$Category[i], "'. Expected: ", paste(expected, collapse = ", ")
      ))
      rows_to_drop[i] <- TRUE
    }
  }

  # Validate Start dates (warn-only, don't drop — future dates are valid for planned policies)
  if ("Start" %in% names(data)) {
    start_vals <- suppressWarnings(as.numeric(data$Start))
    bad_start <- which(
      !is.na(data$Start) & data$Start != "" & data$Start != "--" &
      data$Start != "ongoing" &
      (is.na(start_vals) | start_vals < 1800 | start_vals > 2060)
    )
    for (i in bad_start) {
      if (!rows_to_drop[i]) {
        issues <- c(issues, paste0(
          "  NOTE [", sheet_name, " row ", i, "]: Unusual Start year '",
          data$Start[i], "'"
        ))
      }
    }
  }

  # Report results
  n_dropped <- sum(rows_to_drop)
  n_valid <- nrow(data) - n_dropped
  if (length(issues) > 0) {
    message(paste(issues, collapse = "\n"))
  }
  message("  Validation [", sheet_name, "]: ", n_valid, "/", nrow(data),
          " rows valid", if (n_dropped > 0) paste0(" (", n_dropped, " skipped)") else "")

  # Remove invalid rows
  if (n_dropped > 0) {
    data <- data[!rows_to_drop, , drop = FALSE]
  }

  data
}

# ---------------------------------------------------------------------------
# Helper: Check required columns exist
# ---------------------------------------------------------------------------
check_required_columns <- function(data, sheet_name, required_cols) {
  # Trim whitespace from column names (Google Sheets sometimes adds trailing spaces)
  names(data) <- trimws(names(data))
  missing <- setdiff(required_cols, names(data))
  if (length(missing) > 0) {
    message("  ERROR [", sheet_name, "]: Missing required columns: ",
            paste(missing, collapse = ", "))
    return(NULL)
  }
  data
}

# ---------------------------------------------------------------------------
# Main: Refresh policy data from Google Sheets
# ---------------------------------------------------------------------------
refresh_from_google_sheets <- function() {
  if (!ENABLE_GOOGLE_SHEETS_SYNC) {
    message("Google Sheets sync disabled. Using cached data.")
    return(invisible(NULL))
  }

  message("=== Refreshing policy data from Google Sheets ===")
  start_time <- Sys.time()

  sheet_id <- GOOGLE_SHEET_ID
  gids <- GOOGLE_SHEET_GIDS
  timeout <- GOOGLE_SHEET_TIMEOUT

  # --- Download all sheets ---
  message("Downloading sheets...")
  raw_iso     <- download_gsheet_csv(sheet_id, gids$country_iso, timeout)
  raw_mbl     <- download_gsheet_csv(sheet_id, gids$moratoria_bans_limits, timeout)
  raw_sr      <- download_gsheet_csv(sheet_id, gids$subsidy_removal, timeout)
  raw_div     <- download_gsheet_csv(sheet_id, gids$divestment, timeout)
  raw_country <- download_gsheet_csv(sheet_id, gids$country_overview, timeout)
  raw_scb     <- download_gsheet_csv(sheet_id, gids$state_city_breakdown, timeout)

  # Atomic check: if any sheet failed, abort entirely
  sheets <- list(raw_iso, raw_mbl, raw_sr, raw_div, raw_country, raw_scb)
  sheet_names <- c("Country ISO", "MBL", "Subsidy Removal", "Divestment",
                   "Country Overview", "State & City")
  failed <- sapply(sheets, is.null)
  if (any(failed)) {
    message("FAILED to download: ", paste(sheet_names[failed], collapse = ", "))
    message("Keeping cached data from image.RData.")
    return(invisible(NULL))
  }
  message("All 6 sheets downloaded successfully.")

  # --- Build reference lists for validation ---
  valid_countries <- trimws(raw_iso$Country)
  valid_iso3 <- trimws(raw_iso$ISO3)

  # --- Trim column name whitespace (Google Sheets quirk) ---
  for (i in seq_along(sheets)) names(sheets[[i]]) <- trimws(names(sheets[[i]]))
  names(raw_mbl) <- trimws(names(raw_mbl))
  names(raw_sr) <- trimws(names(raw_sr))
  names(raw_div) <- trimws(names(raw_div))
  names(raw_country) <- trimws(names(raw_country))
  names(raw_scb) <- trimws(names(raw_scb))

  # --- Check required columns ---
  raw_mbl <- check_required_columns(raw_mbl, "MBL",
    c("Category", "Fuel_type", "Country", "ISO3", "City_state_or_province",
      "mbl_country", "mbl_city_region", "Start", "Policy"))
  raw_sr <- check_required_columns(raw_sr, "Subsidy Removal",
    c("Category", "Fuel_type", "Country", "ISO3", "Start", "Policy"))
  raw_div <- check_required_columns(raw_div, "Divestment",
    c("Category", "Type", "Organisation", "Organisation_type", "Country",
      "ISO3", "Start", "Policy", "divestment_city_region", "divestment_non_government"))
  raw_scb <- check_required_columns(raw_scb, "State & City",
    c("State_city_region", "Country", "latitude", "longitude", "ISO3",
      "Moratoria_bans_limits", "Divestment", "FFNPT"))

  if (is.null(raw_mbl) || is.null(raw_sr) || is.null(raw_div) || is.null(raw_scb)) {
    message("Missing required columns. Keeping cached data from image.RData.")
    return(invisible(NULL))
  }

  # --- Validate data ---
  message("Validating data...")
  raw_mbl <- validate_policy_data(raw_mbl, "Moratoria, Bans & Limits", valid_countries, valid_iso3)
  raw_sr  <- validate_policy_data(raw_sr, "Subsidy Removal", valid_countries, valid_iso3)
  raw_div <- validate_policy_data(raw_div, "Divestment", valid_countries, valid_iso3)

  # --- Ensure numeric columns ---
  raw_mbl$mbl_country <- as.numeric(raw_mbl$mbl_country)
  raw_mbl$mbl_city_region <- as.numeric(raw_mbl$mbl_city_region)
  raw_mbl$Policy <- as.numeric(raw_mbl$Policy)
  raw_sr$Policy <- as.numeric(raw_sr$Policy)
  raw_div$Policy <- as.numeric(raw_div$Policy)
  raw_div$divestment_city_region <- as.numeric(raw_div$divestment_city_region)
  raw_div$divestment_non_government <- as.numeric(raw_div$divestment_non_government)
  raw_scb$Moratoria_bans_limits <- as.numeric(raw_scb$Moratoria_bans_limits)
  raw_scb$Divestment <- as.numeric(raw_scb$Divestment)
  raw_scb$FFNPT <- as.numeric(raw_scb$FFNPT)
  if ("Subsidy_removal" %in% names(raw_scb)) {
    raw_scb$Subsidy_removal <- as.numeric(raw_scb$Subsidy_removal)
  } else {
    raw_scb$Subsidy_removal <- 0
  }

  # Each row in MBL/SR represents one policy — default to 1 if Policy column is empty
  raw_mbl$Policy[is.na(raw_mbl$Policy)] <- 1
  raw_sr$Policy[is.na(raw_sr$Policy)] <- 1

  # Replace NAs with 0 for other numeric aggregation columns
  raw_mbl$mbl_country[is.na(raw_mbl$mbl_country)] <- 0
  raw_mbl$mbl_city_region[is.na(raw_mbl$mbl_city_region)] <- 0
  raw_div$Policy[is.na(raw_div$Policy)] <- 0
  raw_div$divestment_city_region[is.na(raw_div$divestment_city_region)] <- 0
  raw_div$divestment_non_government[is.na(raw_div$divestment_non_government)] <- 0
  raw_scb$Moratoria_bans_limits[is.na(raw_scb$Moratoria_bans_limits)] <- 0
  raw_scb$Divestment[is.na(raw_scb$Divestment)] <- 0
  raw_scb$FFNPT[is.na(raw_scb$FFNPT)] <- 0
  raw_scb$Subsidy_removal[is.na(raw_scb$Subsidy_removal)] <- 0

  # --- Compute MBL aggregations (PreprocessingScript.R lines 150-171) ---
  message("Computing aggregations...")
  raw_mbl <- raw_mbl %>%
    dplyr::group_by(ISO3) %>%
    dplyr::mutate(
      a = sum(mbl_country),
      b = sum(mbl_city_region),
      MBL_Class_Moratorium = sum(Category == "Moratorium"),
      MBL_Class_Ban = sum(Category == "Ban"),
      MBL_Class_Partial_Ban = sum(Category == "Partial Ban"),
      MBL_Class_Limitation = sum(Category == "Limitation"),
      MBL_Type_Oil = sum(Fuel_type == "Oil"),
      MBL_Type_Gas = sum(Fuel_type == "Gas"),
      MBL_Type_Coal = sum(Fuel_type == "Coal"),
      MBL_Type_Offshore = sum(Fuel_type == "Offshore"),
      MBL_Type_Oil_Gas = sum(Fuel_type == "Oil & Gas"),
      MBL_Type_Oil_Gas_Coal = sum(Fuel_type == "Oil, Gas & Coal"),
      MBL_Type_Coal_Gas = sum(Fuel_type == "Coal & Gas"),
      MBL_Type_All = sum(Fuel_type == "All"),
      MBL_Type_Ore = sum(Fuel_type == "Ore")
    ) %>%
    dplyr::ungroup()

  # --- Compute Divestment aggregations (PreprocessingScript.R lines 174-201) ---
  raw_div <- raw_div %>%
    dplyr::group_by(ISO3) %>%
    dplyr::mutate(
      a = sum(divestment_city_region),
      b = sum(divestment_non_government)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(Country) %>%
    dplyr::mutate(
      Div_Type_Full = sum(Type == "Full"),
      Div_Type_Partial = sum(Type == "Partial"),
      Div_Type_Fossil_Free = sum(Type == "Fossil Free"),
      Div_Type_Coal_Only = sum(Type == "Coal Only"),
      Div_Type_Coal_and_Tar_Sands_Only = sum(Type == "Coal and Tar Sands Only"),
      Div_Orga_Faith_based_Organization = sum(Organisation_type == "Faith-based Organization" |
                                               Organisation_type == "Faith-Based Organisation"),
      Div_Orga_NGO = sum(Organisation_type == "NGO"),
      Div_Orga_Pension_Fund = sum(Organisation_type == "Pension Fund"),
      Div_Orga_For_Profit_Corporation = sum(Organisation_type == "For Profit Corporation"),
      Div_Orga_Philanthropic_Foundation = sum(Organisation_type == "Philanthropic Foundation"),
      Div_Orga_Government = sum(Organisation_type == "Government"),
      Div_Orga_Educational_Institution = sum(Organisation_type == "Educational Institution"),
      Div_Orga_Healthcare_Institution = sum(Organisation_type == "Healthcare Institution"),
      Div_Orga_Cultural_Institution = sum(Organisation_type == "Cultural Institution"),
      Div_Orga_Other = sum(Organisation_type == "Other")
    ) %>%
    dplyr::ungroup()

  # --- Compute Subsidy Removal aggregations (PreprocessingScript.R lines 204-217) ---
  raw_sr <- raw_sr %>%
    dplyr::group_by(ISO3) %>%
    dplyr::mutate(
      a = sum(Policy),
      Sr_Type_All = sum(Fuel_type == "All"),
      Sr_Type_Coal = sum(Fuel_type == "Coal"),
      Sr_Type_Gas = sum(Fuel_type == "Gas"),
      Sr_Type_Oil = sum(Fuel_type == "Oil"),
      Sr_Type_Oil_Gas = sum(Fuel_type == "Oil & Gas"),
      Sr_Type_Oil_Coal = sum(Fuel_type == "Oil & Coal"),
      Sr_Type_Gas_Coal = sum(Fuel_type == "Gas & Coal")
    ) %>%
    dplyr::ungroup()

  # --- Date formatting (PreprocessingScript.R lines 678-699) ---
  raw_mbl$Date <- lubridate::ymd(raw_mbl$Start, truncated = 2L)
  raw_mbl$date <- as.Date(raw_mbl$Date, format = "%d/%m/%Y")
  raw_sr$Date <- lubridate::ymd(raw_sr$Start, truncated = 2L)
  raw_sr$date <- as.Date(raw_sr$Date, format = "%d/%m/%Y")
  raw_div$Date <- lubridate::ymd(raw_div$Start, truncated = 2L)
  raw_div$date <- as.Date(raw_div$Date, format = "%d/%m/%Y")

  # --- Auto-correct ISO2 → ISO3 codes using the reference table ---
  # Some entries may have 2-letter ISO2 codes instead of 3-letter ISO3
  iso2_to_iso3 <- setNames(trimws(raw_iso$ISO3), trimws(raw_iso$ISO2))
  for (df_name in c("raw_mbl", "raw_sr", "raw_div", "raw_scb")) {
    df <- get(df_name)
    if ("ISO3" %in% names(df)) {
      short_codes <- which(nchar(df$ISO3) == 2 & df$ISO3 != "--")
      if (length(short_codes) > 0) {
        for (i in short_codes) {
          corrected <- iso2_to_iso3[df$ISO3[i]]
          if (!is.na(corrected)) {
            message("  Auto-corrected ISO2 '", df$ISO3[i], "' -> ISO3 '",
                    corrected, "' in ", df_name, " row ", i)
            df$ISO3[i] <- corrected
          }
        }
        assign(df_name, df)
      }
    }
  }

  # --- State & City breakdown (PreprocessingScript.R lines 276-294) ---
  scb_map <- raw_scb %>%
    dplyr::select(dplyr::any_of(c(
      "State_city_region", "Country", "latitude", "longitude", "ISO3",
      "Moratoria_bans_limits", "Subsidy_removal", "Divestment", "FFNPT", "Source"
    )))
  scb_map$latitude <- as.numeric(scb_map$latitude)
  scb_map$longitude <- as.numeric(scb_map$longitude)
  # Replace NAs with 0 only in numeric columns (preserve character columns)
  scb_numeric <- sapply(scb_map, is.numeric)
  scb_map[scb_numeric] <- lapply(scb_map[scb_numeric], function(x) { x[is.na(x)] <- 0; x })

  scb_map <- scb_map %>%
    dplyr::group_by(State_city_region) %>%
    dplyr::mutate(
      Moratoria_bans_limits_total = sum(Moratoria_bans_limits),
      Divestment_total = sum(Divestment),
      Subsidy_removal_total = sum(Subsidy_removal),
      ffnpt_total = sum(FFNPT),
      City_region_state_total = sum(Moratoria_bans_limits + Divestment + Subsidy_removal + FFNPT)
    ) %>%
    dplyr::ungroup()

  # Treaty totals per ISO3
  scb_map <- scb_map %>%
    dplyr::group_by(ISO3) %>%
    dplyr::mutate(treaty = sum(FFNPT)) %>%
    dplyr::ungroup()

  # --- Update country_overview_large (PreprocessingScript.R lines 227-315) ---
  # Start from the existing country_overview_large (has static columns from image.RData)
  col <- country_overview_large

  # Update dynamic policy aggregation columns
  col$mbl_country <- raw_mbl$a[match(col$ISO3, raw_mbl$ISO3)]
  col$mbl_city_region <- raw_mbl$b[match(col$ISO3, raw_mbl$ISO3)]
  col$divestment_city_region <- raw_div$a[match(col$ISO3, raw_div$ISO3)]
  col$divestment_non_government <- raw_div$b[match(col$ISO3, raw_div$ISO3)]
  col$subsidy_removal <- raw_sr$a[match(col$ISO3, raw_sr$ISO3)]

  # MBL breakdowns
  col$MBL_Class_Moratorium <- raw_mbl$MBL_Class_Moratorium[match(col$ISO3, raw_mbl$ISO3)]
  col$MBL_Class_Ban <- raw_mbl$MBL_Class_Ban[match(col$ISO3, raw_mbl$ISO3)]
  col$MBL_Class_Partial_Ban <- raw_mbl$MBL_Class_Partial_Ban[match(col$ISO3, raw_mbl$ISO3)]
  col$MBL_Class_Limitation <- raw_mbl$MBL_Class_Limitation[match(col$ISO3, raw_mbl$ISO3)]
  col$MBL_Type_Oil <- raw_mbl$MBL_Type_Oil[match(col$ISO3, raw_mbl$ISO3)]
  col$MBL_Type_Gas <- raw_mbl$MBL_Type_Gas[match(col$ISO3, raw_mbl$ISO3)]
  col$MBL_Type_Coal <- raw_mbl$MBL_Type_Coal[match(col$ISO3, raw_mbl$ISO3)]
  col$MBL_Type_Offshore <- raw_mbl$MBL_Type_Offshore[match(col$ISO3, raw_mbl$ISO3)]
  col$MBL_Type_Oil_Gas <- raw_mbl$MBL_Type_Oil_Gas[match(col$ISO3, raw_mbl$ISO3)]
  col$MBL_Type_Oil_Gas_Coal <- raw_mbl$MBL_Type_Oil_Gas_Coal[match(col$ISO3, raw_mbl$ISO3)]
  col$MBL_Type_Coal_Gas <- raw_mbl$MBL_Type_Coal_Gas[match(col$ISO3, raw_mbl$ISO3)]
  col$MBL_Type_All <- raw_mbl$MBL_Type_All[match(col$ISO3, raw_mbl$ISO3)]
  col$MBL_Type_Ore <- raw_mbl$MBL_Type_Ore[match(col$ISO3, raw_mbl$ISO3)]

  # Divestment breakdowns
  col$Div_Type_Full <- raw_div$Div_Type_Full[match(col$Country, raw_div$Country)]
  col$Div_Type_Partial <- raw_div$Div_Type_Partial[match(col$Country, raw_div$Country)]
  col$Div_Type_Fossil_Free <- raw_div$Div_Type_Fossil_Free[match(col$Country, raw_div$Country)]
  col$Div_Type_Coal_Only <- raw_div$Div_Type_Coal_Only[match(col$Country, raw_div$Country)]
  col$Div_Type_Coal_and_Tar_Sands_Only <- raw_div$Div_Type_Coal_and_Tar_Sands_Only[match(col$Country, raw_div$Country)]
  col$Div_Orga_Faith_based_Organization <- raw_div$Div_Orga_Faith_based_Organization[match(col$Country, raw_div$Country)]
  col$Div_Orga_NGO <- raw_div$Div_Orga_NGO[match(col$Country, raw_div$Country)]
  col$Div_Orga_Pension_Fund <- raw_div$Div_Orga_Pension_Fund[match(col$Country, raw_div$Country)]
  col$Div_Orga_For_Profit_Corporation <- raw_div$Div_Orga_For_Profit_Corporation[match(col$Country, raw_div$Country)]
  col$Div_Orga_Philanthropic_Foundation <- raw_div$Div_Orga_Philanthropic_Foundation[match(col$Country, raw_div$Country)]
  col$Div_Orga_Government <- raw_div$Div_Orga_Government[match(col$Country, raw_div$Country)]
  col$Div_Orga_Educational_Institution <- raw_div$Div_Orga_Educational_Institution[match(col$Country, raw_div$Country)]
  col$Div_Orga_Healthcare_Institution <- raw_div$Div_Orga_Healthcare_Institution[match(col$Country, raw_div$Country)]
  col$Div_Orga_Cultural_Institution <- raw_div$Div_Orga_Cultural_Institution[match(col$Country, raw_div$Country)]
  col$Div_Orga_Other <- raw_div$Div_Orga_Other[match(col$Country, raw_div$Country)]

  # Subsidy removal breakdowns
  col$Sr_Type_All <- raw_sr$Sr_Type_All[match(col$ISO3, raw_sr$ISO3)]
  col$Sr_Type_Coal <- raw_sr$Sr_Type_Coal[match(col$ISO3, raw_sr$ISO3)]
  col$Sr_Type_Gas <- raw_sr$Sr_Type_Gas[match(col$ISO3, raw_sr$ISO3)]
  col$Sr_Type_Oil <- raw_sr$Sr_Type_Oil[match(col$ISO3, raw_sr$ISO3)]
  col$Sr_Type_Oil_Gas <- raw_sr$Sr_Type_Oil_Gas[match(col$ISO3, raw_sr$ISO3)]
  col$Sr_Type_Oil_Coal <- raw_sr$Sr_Type_Oil_Coal[match(col$ISO3, raw_sr$ISO3)]
  col$Sr_Type_Gas_Coal <- raw_sr$Sr_Type_Gas_Coal[match(col$ISO3, raw_sr$ISO3)]

  # Treaty total
  col$treaty_total <- scb_map$treaty[match(col$ISO3, scb_map$ISO3)]

  # Replace NAs with 0 only in numeric columns (preserve factor columns like co2_*_cat)
  numeric_cols <- sapply(col, is.numeric)
  col[numeric_cols] <- lapply(col[numeric_cols], function(x) { x[is.na(x)] <- 0; x })

  # Compute totals (PreprocessingScript.R lines 297-315)
  col$Moratoria_bans_limits_total <- col$mbl_country + col$mbl_city_region
  col$Divestment_total <- col$divestment_city_region + col$divestment_non_government
  col$Subsidy_removal_total <- col$subsidy_removal
  col$Policy_total <- col$Moratoria_bans_limits_total + col$Subsidy_removal_total +
                      col$Divestment_total + col$treaty_total
  col$Government_policies_total <- col$Moratoria_bans_limits_total +
                                   col$Subsidy_removal_total + col$divestment_city_region
  col$Non_Government_policies_total <- col$divestment_non_government

  # Filtered version for map overlay
  col_map <- col %>% dplyr::filter(Government_policies_total >= 1 | Non_Government_policies_total >= 1)

  # FFNPT filtered state/city breakdown for map
  scb_map_ffnpt <- scb_map %>% dplyr::filter(ffnpt_total > 0)

  # --- Update last-updated date to today ---
  APP_LAST_UPDATED <<- format(Sys.Date(), "%d/%m/%y")

  # --- Assign to global environment ---
  moratoria_bans_limits <<- raw_mbl
  subsidy_removal <<- raw_sr
  divestment_new <<- raw_div
  country_overview_large <<- col
  country_overview_large_map <<- col_map
  state_city_breakdown_map <<- scb_map
  state_city_breakdown_map_ffnpt <<- scb_map_ffnpt

  elapsed <- round(as.numeric(difftime(Sys.time(), start_time, units = "secs")), 1)
  message("=== Google Sheets refresh complete (", elapsed, "s) ===")
  message("  MBL: ", nrow(raw_mbl), " rows | SR: ", nrow(raw_sr),
          " rows | Divestment: ", nrow(raw_div), " rows")
  message("  Countries: ", nrow(col), " | FFNPT endorsements: ", nrow(scb_map_ffnpt))

  invisible(TRUE)
}

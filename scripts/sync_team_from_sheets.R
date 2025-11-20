#!/usr/bin/env Rscript
#' Sync Team Members Data from Google Sheets
#'
#' Reads the "Team Members" tab from POPCORN Google Workbook and updates
#' the local team-members.csv file.
#'
#' @details
#' This script enables the Research Coordinator to manage team member data
#' in Google Sheets. This script automatically syncs changes to the repository.
#'
#' Required columns in Google Sheet:
#'   - first_name, last_name
#'   - post_nominal_initials
#'   - affiliation_primary, affiliation_2, affiliation_3, affiliation_4
#'   - strategic_advisory_cmt (SAC role, or "NA"/"" if not a SAC member)
#'   - ORCID, web_bio
#'
#' @examples
#' # Preview what would be synced (dry run)
#' preview_team_sync()
#'
#' # Sync and update CSV file
#' sync_team_from_sheets(commit = FALSE)
#'
#' # Sync and auto-commit to git
#' sync_team_from_sheets(commit = TRUE, commit_msg = "Update team members from Google Sheets")

# Required packages ----
required_packages <- c(
  "googlesheets4",
  "googledrive",
  "readr",
  "dplyr"
)

# Check and install missing packages
missing_packages <- required_packages[!required_packages %in% installed.packages()[,"Package"]]
if (length(missing_packages) > 0) {
  message("Installing missing packages: ", paste(missing_packages, collapse = ", "))
  install.packages(missing_packages)
}

# Load packages
suppressPackageStartupMessages({
  library(googlesheets4)
  library(googledrive)
  library(readr)
  library(dplyr)
})

# Configuration ----

#' Google Sheet ID or URL
#' UPDATE THIS with your actual Google Workbook URL/ID
GOOGLE_SHEET_ID <- Sys.getenv(
  "POPCORN_TEAM_SHEET_ID",
  default = "YOUR_GOOGLE_SHEET_ID_HERE"  # Replace with actual ID
)

#' Tab name in Google Sheet
TAB_NAME <- "Team Members"

#' Output CSV file
OUTPUT_CSV <- "data/team-members.csv"

# Authentication ----

#' Authenticate with Google Sheets
#'
#' Tries service account first (for automation), falls back to user auth
authenticate_google <- function() {
  # Try service account (for automated scripts)
  service_account_file <- ".secrets/google-service-account.json"

  if (file.exists(service_account_file)) {
    message("Authenticating with service account...")
    gs4_auth(path = service_account_file)
  } else {
    # Fall back to interactive user authentication
    message("Service account not found. Using interactive authentication...")
    message("(To set up service account, see development/google-sheets-setup.md)")
    gs4_auth()
  }
}

# Main functions ----

#' Read team members data from Google Sheet
#'
#' @return Data frame with team member data
read_team_from_sheets <- function() {
  message("Reading Team Members from Google Sheets...")

  # Authenticate
  authenticate_google()

  # Read sheet
  tryCatch({
    data <- read_sheet(GOOGLE_SHEET_ID, sheet = TAB_NAME)
    message(sprintf("Read %d rows from '%s' tab", nrow(data), TAB_NAME))
    data
  }, error = function(e) {
    stop(sprintf("Error reading Google Sheet: %s\nCheck that GOOGLE_SHEET_ID is correct and you have access.", e$message))
  })
}

#' Validate team members data
#'
#' @param data Data frame with team member data
#' @return TRUE if valid, FALSE with warnings if not
validate_team_data <- function(data) {
  required_cols <- c("first_name", "last_name", "post_nominal_initials",
                     "affiliation_primary", "affiliation_2", "affiliation_3", "affiliation_4",
                     "strategic_advisory_cmt", "ORCID", "web_bio")

  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    warning(sprintf("Missing required columns: %s", paste(missing_cols, collapse = ", ")))
    return(FALSE)
  }

  # Check for empty first/last names
  missing_names <- data %>%
    filter(is.na(first_name) | trimws(first_name) == "" |
           is.na(last_name) | trimws(last_name) == "")

  if (nrow(missing_names) > 0) {
    warning(sprintf("Found %d rows with missing first or last names", nrow(missing_names)))
    return(FALSE)
  }

  TRUE
}

#' Preview what would be synced (dry run)
#'
#' @export
preview_team_sync <- function() {
  data <- read_team_from_sheets()

  message("\n=== Preview: Team Members Sync ===\n")

  if (!validate_team_data(data)) {
    stop("Validation failed. Please fix issues in Google Sheet before syncing.")
  }

  message(sprintf("Total team members: %d", nrow(data)))

  # Count SAC members (where strategic_advisory_cmt is not NA or empty)
  sac_count <- sum(!is.na(data$strategic_advisory_cmt) &
                   data$strategic_advisory_cmt != "" &
                   data$strategic_advisory_cmt != "NA")
  message(sprintf("  Strategic Advisory Committee: %d", sac_count))

  message("\nFirst few rows:")
  print(head(data %>% select(first_name, last_name, affiliation_primary, strategic_advisory_cmt), 5))

  if (file.exists(OUTPUT_CSV)) {
    current <- read_csv(OUTPUT_CSV, show_col_types = FALSE)

    new_count <- nrow(data)
    old_count <- nrow(current)

    if (new_count > old_count) {
      message(sprintf("\n%d new team member(s) will be added", new_count - old_count))
    } else if (new_count < old_count) {
      message(sprintf("\n%d team member(s) will be removed", old_count - new_count))
    } else {
      message("\nNo change in team member count")
    }
  }
}

#' Sync team members from Google Sheets
#'
#' @param commit Logical. If TRUE, git commit changes after sync
#' @param commit_msg Commit message (if commit = TRUE)
#' @export
sync_team_from_sheets <- function(commit = FALSE,
                                   commit_msg = "Update team members from Google Sheets") {

  data <- read_team_from_sheets()

  # Validate
  if (!validate_team_data(data)) {
    stop("Validation failed. Please fix issues in Google Sheet before syncing.")
  }

  # Create data directory if needed
  dir.create(dirname(OUTPUT_CSV), showWarnings = FALSE, recursive = TRUE)

  # Write CSV
  message(sprintf("\nWriting to %s...", OUTPUT_CSV))
  write_csv(data, OUTPUT_CSV)
  message(sprintf("✓ Successfully wrote %d team members to CSV", nrow(data)))

  # Summary
  message("\n=== Sync Complete ===")
  message(sprintf("Total team members: %d", nrow(data)))

  # Count SAC members (where strategic_advisory_cmt is not NA or empty)
  sac_count <- sum(!is.na(data$strategic_advisory_cmt) &
                   data$strategic_advisory_cmt != "" &
                   data$strategic_advisory_cmt != "NA")
  message(sprintf("  Strategic Advisory Committee: %d", sac_count))

  # Git commit if requested
  if (commit) {
    message("\nCommitting changes to git...")
    system(sprintf('git add %s', OUTPUT_CSV))
    system(sprintf('git commit -m "%s"', commit_msg))
    message("✓ Changes committed")
  }

  invisible(data)
}

# CLI interface ----
if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)

  if (length(args) == 0 || args[1] == "preview") {
    preview_team_sync()
  } else if (args[1] == "sync") {
    commit <- "--commit" %in% args
    sync_team_from_sheets(commit = commit)
  } else {
    cat("Usage:\n")
    cat("  Rscript sync_team_from_sheets.R preview    # Preview sync\n")
    cat("  Rscript sync_team_from_sheets.R sync       # Sync without commit\n")
    cat("  Rscript sync_team_from_sheets.R sync --commit  # Sync and commit\n")
  }
}

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
#'   - cihr_study (investigator/collaborator role, or "NA"/"" if not applicable)
#'   - study_team ("Yes" for study team members, or "NA"/"" if not applicable)
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
  "googledrive",
  "readxl",
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
  library(googledrive)
  library(readxl)
  library(readr)
  library(dplyr)
})

# Configuration ----

#' Google Sheet ID or URL
#' UPDATE THIS with your actual Google Workbook URL/ID
GOOGLE_SHEET_ID <- Sys.getenv(
  "POPCORN_TEAM_SHEET_ID",
  unset = "YOUR_GOOGLE_SHEET_ID_HERE"  # Replace with actual ID
)

#' Tab name in Excel file
TAB_NAME <- "contributors"

#' Output CSV file
OUTPUT_CSV <- "data/team-members.csv"

# Authentication ----

#' Authenticate with Google Drive
#'
#' Tries service account first (for automation), falls back to user auth
authenticate_google <- function() {
  # Try service account (for automated scripts)
  service_account_file <- ".secrets/popcorn-data-manager.json"

  if (file.exists(service_account_file)) {
    message("Authenticating with service account...")
    drive_auth(path = service_account_file)
  } else {
    # Fall back to interactive user authentication
    message("Service account not found. Using interactive authentication...")
    message("(To set up service account, see development/google-sheets-setup.md)")
    drive_auth()
  }
}

# Main functions ----

#' Read team members data from Google Drive Excel file
#'
#' @return Data frame with team member data
read_team_from_sheets <- function() {
  message("Reading Team Members from Google Drive...")

  # Authenticate
  authenticate_google()

  # Download the Excel file
  tryCatch({
    # Create temp file for download
    temp_file <- tempfile(fileext = ".xlsx")

    message(sprintf("Downloading Excel file (ID: %s)...", GOOGLE_SHEET_ID))
    options(googledrive_quiet = TRUE)
    drive_download(
      as_id(GOOGLE_SHEET_ID),
      path = temp_file,
      overwrite = TRUE
    )

    # Read the Excel file
    message(sprintf("Reading '%s' tab from Excel file...", TAB_NAME))
    data <- read_excel(temp_file, sheet = TAB_NAME)

    # Clean up temp file
    unlink(temp_file)

    message(sprintf("Read %d rows from '%s' tab", nrow(data), TAB_NAME))

    # Select and rename columns we need
    # Handle duplicate affiliation_3 columns from Excel
    required_cols <- c("first_name", "last_name", "post_nominal_initials",
                       "affiliation_primary", "affiliation_2", "affiliation_4",
                       "strategic_advisory_cmt", "cihr_study", "study_team", "web_bio")

    # Find affiliation_3 column (may have been renamed by readxl)
    aff3_col <- grep("^affiliation_3", names(data), value = TRUE)[1]
    if (!is.na(aff3_col)) {
      data$affiliation_3 <- data[[aff3_col]]
    }

    # Add ORCID column if missing
    if (!"ORCID" %in% names(data)) {
      data$ORCID <- ""
    }

    # Select only required columns
    all_required <- c(required_cols, "affiliation_3", "ORCID")
    data <- data[, all_required]

    data
  }, error = function(e) {
    stop(sprintf("Error reading Excel file from Google Drive: %s\nCheck that GOOGLE_SHEET_ID is correct and you have access.", e$message))
  })
}

#' Validate team members data
#'
#' @param data Data frame with team member data
#' @return TRUE if valid, FALSE with warnings if not
validate_team_data <- function(data) {
  required_cols <- c("first_name", "last_name", "post_nominal_initials",
                     "affiliation_primary", "affiliation_2", "affiliation_3", "affiliation_4",
                     "strategic_advisory_cmt", "cihr_study", "study_team", "ORCID", "web_bio")

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

  # Count investigators (where cihr_study is not NA or empty)
  inv_count <- sum(!is.na(data$cihr_study) &
                   data$cihr_study != "" &
                   data$cihr_study != "NA")
  message(sprintf("  Investigators and collaborators: %d", inv_count))

  # Count study team (where study_team = "Yes")
  team_count <- sum(!is.na(data$study_team) &
                    data$study_team == "Yes")
  message(sprintf("  Study team: %d", team_count))

  message("\nFirst few rows:")
  print(head(data %>% select(first_name, last_name, affiliation_primary, strategic_advisory_cmt, cihr_study, study_team), 5))

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

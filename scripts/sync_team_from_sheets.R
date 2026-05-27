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
#'   - study_team ("active"/"inactive" for study team members, or "NA"/"" if not applicable)
#'   - web_bio, pub_list (ORCID is extracted from pub_list)
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
  library(readr)
  library(dplyr)
})

# Configuration ----

#' Google Sheet ID or URL
#' Can be overridden with POPCORN_TEAM_SHEET_ID environment variable
GOOGLE_SHEET_ID <- Sys.getenv(
  "POPCORN_TEAM_SHEET_ID",
  unset = "1e_dKWpql6ZHB2ZRb9jL44fuxHi_8JcEpq8gfFXb0wTw"
)

#' Tab/sheet name in Google Sheets
TAB_NAME <- "contributors"

#' Output CSV file
OUTPUT_CSV <- "data/team-members.csv"

# Authentication ----

#' Authenticate with Google Sheets
#'
#' Tries service account first (for automation), falls back to user auth
authenticate_google <- function() {
  # Try GitHub Actions environment variable first
  if (Sys.getenv("GOOGLE_SHEETS_AUTH") != "") {
    message("Using GitHub Secrets authentication...")
    auth_json <- Sys.getenv("GOOGLE_SHEETS_AUTH")
    temp_key <- tempfile(fileext = ".json")
    writeLines(auth_json, temp_key)
    gs4_auth(path = temp_key)
    unlink(temp_key)
    return(invisible(NULL))
  }

  # Try service account file (for local automation)
  service_account_files <- c(
    ".secrets/google-service-account.json",
    ".secrets/popcorn-data-manager.json"
  )

  for (service_file in service_account_files) {
    if (file.exists(service_file)) {
      message(sprintf("Authenticating with service account (%s)...", service_file))
      gs4_auth(path = service_file)
      return(invisible(NULL))
    }
  }

  # Fall back to interactive user authentication
  message("Service account not found. Using interactive authentication...")
  message("(To set up service account, see development/google-sheets-setup.md)")
  gs4_auth()
}

# Main functions ----

#' Read team members data from Google Sheets
#'
#' @return Data frame with team member data
read_team_from_sheets <- function() {
  message("Reading Team Members from Google Sheets...")

  # Authenticate
  authenticate_google()

  # Read from Google Sheets
  tryCatch({
    message(sprintf("Reading '%s' sheet (ID: %s)...", TAB_NAME, GOOGLE_SHEET_ID))

    data <- read_sheet(
      GOOGLE_SHEET_ID,
      sheet = TAB_NAME
    )

    message(sprintf("Read %d rows from '%s' sheet", nrow(data), TAB_NAME))

    # Select and rename columns we need
    required_cols <- c("first_name", "last_name", "post_nominal_initials",
                       "affiliation_primary", "affiliation_2", "affiliation_4",
                       "strategic_advisory_cmt", "cihr_study", "study_team", "web_bio")

    # Find affiliation_3 column (may have been renamed)
    aff3_col <- grep("^affiliation_3", names(data), value = TRUE)[1]
    if (!is.na(aff3_col)) {
      data$affiliation_3 <- data[[aff3_col]]
    }

    # Derive ORCID from pub_list. The sheet has no dedicated ORCID column;
    # ORCID identifiers are stored as orcid.org URLs in pub_list (about 1/4 of
    # rows). Extract the bare 16-digit identifier where present.
    extract_orcid <- function(x) {
      x <- as.character(x)
      if (length(x) == 0 || is.na(x) || x == "") return("")
      m <- regmatches(x, regexpr("[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9Xx]", x))
      if (length(m) == 0) "" else toupper(m)
    }
    if ("pub_list" %in% names(data)) {
      data$ORCID <- vapply(data$pub_list, extract_orcid, character(1), USE.NAMES = FALSE)
    } else if (!"ORCID" %in% names(data)) {
      data$ORCID <- ""
    }

    # Select only required columns that exist
    all_required <- c(required_cols, "affiliation_3", "ORCID")
    available_cols <- intersect(all_required, names(data))
    data <- data[, available_cols]

    # Convert list columns to character (googlesheets4 sometimes returns lists)
    data <- data %>%
      mutate(across(where(is.list), ~ sapply(., function(x) {
        if (is.null(x) || length(x) == 0) NA_character_ else as.character(x)
      })))

    data
  }, error = function(e) {
    stop(sprintf("Error reading from Google Sheets: %s\nCheck that GOOGLE_SHEET_ID is correct and you have access.", e$message))
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

  # Count study team (where study_team = "active")
  team_count <- sum(!is.na(data$study_team) &
                    data$study_team == "active")
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

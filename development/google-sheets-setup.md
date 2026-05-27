# Google Sheets setup for team members

## Overview

The POPCORN-NCD project uses a Google Drive workbook to manage team member information. This allows the Research Coordinator (Sarah) to update team data without needing to edit CSV files directly or use GitHub.

The setup includes:
- A workbook in Google Drive with team member data
- An R script that syncs data from the workbook to CSV
- A GitHub Actions workflow that runs automatically to keep data in sync

> **Note on the file type.** The workbook is a **native Google Sheet**
> (`POPCORN_Group Lists_V1.0.0`). The sync script reads it directly with
> `googlesheets4::read_sheet()`. If the workbook is ever replaced by an
> uploaded Excel (`.xlsx`) file, `read_sheet()` will fail ("must not be an
> Office file") and the script would need to download it via
> `googledrive::drive_download()` and read it with `readxl` instead. Keep the
> workbook a native Sheet to use the simpler `googlesheets4` path.

## Architecture

```
Google Sheet (POPCORN_Group Lists_V1.0.0)
└── Tab: contributors → sync_team_from_sheets.R → data/team-members.csv → team.qmd
```

The workflow runs:
- **Daily at 6 AM UTC** (1 AM EST / 2 AM EDT)
- **On manual trigger** via GitHub Actions UI
- **When the sync script is updated**

## Setup instructions

### 1. Create Google Service Account

This allows GitHub Actions to read from Google Sheets without interactive authentication.

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing project
3. Enable the Google Sheets API:
   - Navigate to "APIs & Services" → "Library"
   - Search for "Google Sheets API"
   - Click "Enable"
4. Create a service account:
   - Navigate to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "Service Account"
   - Name: `popcorn-github-actions`
   - Grant role: "Viewer" (read-only access)
5. Create and download JSON key:
   - Click on the service account you just created
   - Go to "Keys" tab
   - Click "Add Key" → "Create new key" → "JSON"
   - Save the downloaded JSON file securely

### 2. Share the workbook with the service account

> **This is the most common breakage.** When the workbook is moved, renamed,
> or recreated, it must be re-shared with the service account or the sync
> fails with a `404 File not found`.

The current service account is:

```
popcorn-data-manager@popcorn-data-management.iam.gserviceaccount.com
```

1. Open the workbook in Google Drive
2. Click "Share"
3. Add the service account email above as a **Viewer**
   (sharing the parent folder works too, and survives future moves within it)
4. Uncheck "Notify people" (no need to send email to a service account)
5. Click "Share"

The service account email is also the `client_email` field inside
`.secrets/popcorn-data-manager.json` (and the `GOOGLE_SERVICE_ACCOUNT_JSON`
GitHub secret), if you need to confirm which account is in use.

### 3. Add secrets to GitHub repository

You need to add two secrets to the GitHub repository:

#### GOOGLE_SERVICE_ACCOUNT_JSON

1. Go to your GitHub repository
2. Navigate to "Settings" → "Secrets and variables" → "Actions"
3. Click "New repository secret"
4. Name: `GOOGLE_SERVICE_ACCOUNT_JSON`
5. Value: Paste the **entire contents** of the downloaded JSON file
6. Click "Add secret"

#### POPCORN_TEAM_SHEET_ID

1. Open your Google Sheet
2. Copy the Sheet ID from the URL:
   ```
   https://docs.google.com/spreadsheets/d/SHEET_ID_HERE/edit
   ```
3. In GitHub, create another secret:
   - Name: `POPCORN_TEAM_SHEET_ID`
   - Value: Paste the Sheet ID
4. Click "Add secret"

### 4. Test the workflow

#### Option A: Manual trigger via GitHub UI

1. Go to repository → "Actions" tab
2. Select "Sync Team Members from Google Sheets" workflow
3. Click "Run workflow" → "Run workflow"
4. Wait for workflow to complete
5. Check the "Files changed" tab to see if CSV was updated

#### Option B: Run locally

```bash
# Set environment variable
export POPCORN_TEAM_SHEET_ID="your-sheet-id-here"

# Preview what would be synced
Rscript scripts/sync_team_from_sheets.R preview

# Actually sync (without committing)
Rscript scripts/sync_team_from_sheets.R sync

# Sync and commit
Rscript scripts/sync_team_from_sheets.R sync --commit
```

## Workbook structure

The sync script reads the **`contributors`** tab. The workbook contains
other tabs (`dictionary`, `e-delphi`, `funding`, `terms_list`) that the
script ignores. The script pulls the following columns; any others on the
tab are left untouched.

| Column | Required | Description | Example |
|--------|----------|-------------|---------|
| `first_name` | Yes | Given name | `Doug` |
| `last_name` | Yes | Family name | `Manuel` |
| `post_nominal_initials` | No | Credentials | `MD, MSc, FRCPC` |
| `affiliation_primary` | Yes | Main institution | `Ottawa Hospital Research Institute` |
| `affiliation_2` | No | Secondary affiliation | `University of Ottawa` |
| `affiliation_3` | No | Third affiliation | |
| `affiliation_4` | No | Fourth affiliation | |
| `strategic_advisory_cmt` | No | SAC role; blank/`NA` if not a SAC member | `SAC Chair` |
| `cihr_study` | No | Grant role; blank/`NA` if not applicable | `Co-investigator` |
| `study_team` | No | Active-status flag for study-team members | `active` |
| `web_bio` | No | URL to the person's online biography | `https://…/profile` |
| `pub_list` | No | Link to publications; ORCID preferred (ORCID is extracted from here) | `https://orcid.org/0000-0002-0599-2061` |

> **ORCID is derived, not a column.** The sheet has no dedicated `ORCID`
> column. The sync script extracts the ORCID identifier from `pub_list` when
> it contains an `orcid.org` URL, and writes it to the CSV's `ORCID` column
> (blank when `pub_list` is a non-ORCID link or empty).

Membership sections on the team page are **derived from the role columns**,
not from a single `Section` column:

- **Strategic Advisory Committee** — rows where `strategic_advisory_cmt` has
  a value.
- **Investigators and collaborators** — rows where `cihr_study` has a value.
- **Study team** — rows where `study_team` has a value (the workbook stores
  this as `active`/`inactive` from the `terms_list` tab).

## Workflow for updating team members

### Sarah's workflow (Research Coordinator)

1. Open Google Sheet
2. Add/edit team member row(s)
3. Save (Google Sheets auto-saves)
4. Wait for next scheduled sync (daily at 6 AM UTC) **OR**
5. Manually trigger workflow via GitHub Actions UI

### Automated sync

The GitHub Actions workflow:
1. Runs daily at 6 AM UTC
2. Reads data from Google Sheets via service account
3. Validates data structure and required fields
4. Writes to `data/team-members.csv`
5. Commits changes if CSV has been modified
6. Push triggers website rebuild (via separate workflow)

## Validation rules

The sync script (`validate_team_data()`) requires:
1. Required columns exist (the columns listed above)
2. `first_name` and `last_name` are not empty

The `validate-csv.yml` workflow additionally checks the generated CSV for:
3. `affiliation_primary` not empty (warning)
4. No leading/trailing whitespace in key text fields (warning)
5. ORCID format matches `0000-0000-0000-0000`, if provided (warning)
6. No duplicate entries (same `first_name` + `last_name` + `affiliation_primary`) (warning)
7. `web_bio` looks like a URL, if provided (warning)

If a required column is missing or names are blank, the workflow stops.

## Troubleshooting

### Workflow fails with "Error reading Google Sheet"

**Possible causes:**
1. Service account email not added to Google Sheet sharing
2. Wrong Sheet ID in secrets
3. Google Sheets API not enabled in Google Cloud project

**Solution:**
- Verify service account email has Viewer access to sheet
- Double-check `POPCORN_TEAM_SHEET_ID` secret value
- Confirm Google Sheets API is enabled in Google Cloud Console

### Workflow runs but CSV doesn't update

**Possible causes:**
1. No actual changes in Google Sheet data
2. Validation errors preventing write

**Solution:**
- Check workflow logs for validation errors
- Run script locally with `preview` to see what would be synced

### Authentication fails locally

**Possible causes:**
1. Missing service account JSON file
2. Wrong file path for service account

**Solution:**
- Ensure `.secrets/popcorn-data-manager.json` exists (for service account auth)
- Or allow interactive auth (browser-based) when running locally

## Security notes

### Service account permissions

- Service account has **read-only** access to Google Sheets
- Cannot modify or delete data in Google Sheets
- Cannot access other Google Drive files
- Credentials stored as encrypted GitHub secrets

### Local development

For local testing without service account:
1. Remove `.secrets/popcorn-data-manager.json` file
2. Run script - it will prompt for interactive authentication via browser
3. Grant read-only access to your Google account
4. Token cached locally in `.secrets/`

**Important:** Add `.secrets/` to `.gitignore` to prevent committing credentials

## Related files

- [scripts/sync_team_from_sheets.R](../scripts/sync_team_from_sheets.R) - Sync script
- [.github/workflows/sync-google-sheets.yml](../.github/workflows/sync-google-sheets.yml) - GitHub Actions workflow
- [data/team-members.csv](../data/team-members.csv) - Output CSV file
- [.github/workflows/validate-csv.yml](../.github/workflows/validate-csv.yml) - CSV validation workflow

## See also

For the popcorn-data repository setup, see:
- [google-sheets-workflow.md](../../popcorn-data/docs/google-sheets-workflow.md) - File metadata workflow
- [scripts/metadata/import_from_sheets.R](../../popcorn-data/scripts/metadata/import_from_sheets.R) - Metadata sync script

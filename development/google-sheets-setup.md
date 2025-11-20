# Google Sheets setup for team members

## Overview

The POPCORN-NCD project uses a Google Sheets workbook to manage team member information. This allows the Research Coordinator (Sarah) to update team data without needing to edit CSV files directly or use GitHub.

The setup includes:
- A Google Sheet with team member data
- An R script that syncs data from Google Sheets to CSV
- A GitHub Actions workflow that runs automatically to keep data in sync

## Architecture

```
Google Workbook (POPCORN-NCD Master Data)
└── Tab: Team Members → CSV → team.qmd (popcorn-web)
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

### 2. Share Google Sheet with service account

1. Open the downloaded JSON file
2. Find the `client_email` field (looks like `popcorn-github-actions@project-id.iam.gserviceaccount.com`)
3. Open your Google Sheet
4. Click "Share" button
5. Add the service account email as a Viewer
6. Uncheck "Notify people" (no need to send email to service account)
7. Click "Share"

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

## Google Sheet structure

The "Team Members" tab must have these columns:

| Column | Required | Description | Example |
|--------|----------|-------------|---------|
| Section | Yes | Member category | `Leads`, `SAG`, `Working Group` |
| Name | Yes | Full name | `Douglas Manuel` |
| Credentials | Yes | Academic degrees | `MD MSc FRCPC` |
| Institution | Yes | Primary affiliation | `The Ottawa Hospital Research Institute` |
| Country | Yes | Country | `Canada` |
| Expertise | Yes | Areas of expertise | `Population health microsimulation modelling` |
| Role | Yes | Role description | `Principal Investigator...` |
| Position | No | Special position | `Ex Officio`, `Chair` |
| ORCID | No | ORCID identifier | `0000-0002-0599-2061` |
| Photo | No | Photo filename or URL | `dmanuel.jpg` |

**Valid Section values:**
- `Leads` - Principal Investigators and Co-PIs
- `SAG` - Strategic Advisory Group members
- `Working Group` - Working group members

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

The sync script validates:
1. Required columns exist
2. Section is one of: `Leads`, `SAG`, `Working Group`
3. Name, Institution, and Country are not empty
4. No duplicate entries (same Name + Institution)
5. ORCID format matches `0000-0000-0000-0000` (if provided)
6. Email format is valid (if provided)

If validation fails, the workflow stops and creates an error log.

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
- Ensure `.secrets/google-service-account.json` exists (for service account auth)
- Or allow interactive auth (browser-based) when running locally

## Security notes

### Service account permissions

- Service account has **read-only** access to Google Sheets
- Cannot modify or delete data in Google Sheets
- Cannot access other Google Drive files
- Credentials stored as encrypted GitHub secrets

### Local development

For local testing without service account:
1. Remove `.secrets/google-service-account.json` file
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

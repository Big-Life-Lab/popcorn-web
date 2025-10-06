# Instructions for Research Coordinator: Managing the Team Page

## Overview

The POPCORN-NCD team page uses a **hybrid approach**:
- **Leadership section:** Manual updates (allows custom bios and formatting)
- **Working Group & SAG:** Automatic from CSV file (easier bulk updates)

**You will need:**
- Access to the Google Form responses (Google Sheet)
- Access to the GitHub repository (web or desktop app)

---

## Method 1: Update Working Group or SAG (CSV - Recommended for Bulk)

### Step 1: Prepare Your Data in Google Sheets

1. Open your Google Sheet with team member responses
2. Make sure you have these columns (exact names matter):
   - `Section` (must be exactly "Working Group" or "SAG")
   - `Name`
   - `Credentials` (e.g., PhD, MD MSc)
   - `Institution`
   - `Country`
   - `Expertise`
   - `ORCID` (just the numbers, e.g., 0000-0002-0599-2061)
   - `Email` (optional, not currently displayed)
   - `Photo` (optional, file path like assets/team/name.jpg)

3. Filter or create a tab with just Working Group and SAG members

### Step 2: Export to CSV

**Option A: Download from Google Sheets**
1. File → Download → Comma Separated Values (.csv)
2. Save as `team-members.csv`

**Option B: Copy/Paste into Existing CSV**
1. Select the data rows (not headers)
2. Copy (Ctrl+C or Cmd+C)
3. Open `data/team-members.csv` in GitHub or text editor
4. Paste below the header row
5. Save

### Step 3: Upload CSV to GitHub

**Via GitHub Web:**
1. Go to https://github.com/Big-Life-Lab/popcorn-web/tree/main/data
2. Click on `team-members.csv`
3. Click pencil icon (✏️) to edit
4. Delete old content, paste new data (or just add new rows)
5. Scroll to bottom, add commit message: "Update team members"
6. Click "Commit changes"

**Via GitHub Desktop:**
1. Open GitHub Desktop
2. Replace `data/team-members.csv` with your new file
3. Review changes
4. Add commit message: "Update team members"
5. Commit and push

### Step 4: Verify

- Wait 2-3 minutes for GitHub Actions to rebuild site
- Visit https://popcorn-statement.org/team.html
- Check that new members appear correctly

---

## Method 2: Update Leadership (Manual - For Co-Investigators)

Leadership has custom bios and formatting, so these are added manually to team.qmd.

### Step 1: Get Member Information

From Google Form responses or direct communication, gather:
- Name and credentials
- Position/title
- Institution
- Brief bio (2-3 sentences)
- Email
- ORCID ID
- Photo (optional)

### Step 2: Edit team.qmd

1. Go to https://github.com/Big-Life-Lab/popcorn-web
2. Click on `team.qmd`
3. Click pencil icon (✏️)
4. Find the `## Leadership` section
5. Copy this template (it's also in the comments):

```markdown
::: {.g-col-12 .g-col-md-6}
### [Role Title]

**[Name], [Credentials]**
[Position]
[Institution]

[Brief bio describing expertise and role]

[{{< fa envelope >}} email@example.com](mailto:email@example.com) | [{{< fa brands orcid >}} ORCID](https://orcid.org/[ORCID-ID])
:::
```

6. Paste it before the closing `:::` of the grid section
7. Fill in the bracketed fields
8. If you have a photo, add this line above the name:
   ```markdown
   ![Name](assets/team/photo.jpg){width="150"}
   ```
9. Scroll to bottom, commit message: "Add [Name] to Leadership"
10. Click "Commit changes"

---

## Adding Photos

### Step 1: Prepare Photo
- Square format preferred
- Minimum 200x200px
- JPEG or PNG
- Rename to: `firstname-lastname.jpg` (e.g., `doug-manuel.jpg`)

### Step 2: Upload to GitHub

**Via GitHub Web:**
1. Go to https://github.com/Big-Life-Lab/popcorn-web/tree/main/assets/team
2. Click "Add file" → "Upload files"
3. Drag/drop or select your photo
4. Commit with message: "Add photo for [Name]"

### Step 3: Update CSV or team.qmd

**For Working Group/SAG (CSV):**
- In your CSV, add the photo path to the `Photo` column
- Example: `assets/team/jane-smith.jpg`
- Upload updated CSV

**For Leadership (manual):**
- Edit team.qmd
- Add photo line above their name (see template above)

---

## CSV Column Reference

Your Google Sheet or CSV should have these columns in this order:

| Column | Required? | Example | Notes |
|--------|-----------|---------|-------|
| Section | Yes | Working Group | Must be exactly "Working Group" or "SAG" |
| Name | Yes | Jane Smith | Full name |
| Credentials | No | PhD | Degrees/credentials |
| Institution | Yes | University of Example | Primary affiliation |
| Country | Yes | Canada | Country |
| Expertise | No | Microsimulation modeling; health economics | Separated by semicolons |
| ORCID | No | 0000-0002-1234-5678 | Just the number, no URL |
| Email | No | jane@example.com | Not currently displayed on site |
| Photo | No | assets/team/jane-smith.jpg | Path to photo file |

---

## Common Tasks

### Adding Multiple Members at Once
- Use the CSV method (Method 1)
- Add all new rows to your Google Sheet
- Download and upload the full CSV
- One commit updates everyone

### Updating Existing Member Info
- Edit the row in Google Sheet
- Download and upload updated CSV
- Or edit `data/team-members.csv` directly in GitHub

### Removing a Member
- Delete their row from the CSV
- Upload updated CSV
- Or set their Section to empty/different value

### Moving Member Between Sections
- In CSV, change their `Section` value from "Working Group" to "SAG" (or vice versa)
- Upload updated CSV

---

## Troubleshooting

**Problem: Members don't appear on site after CSV update**
- Check CSV column names match exactly (case-sensitive)
- Verify `Section` is exactly "Working Group" or "SAG"
- Wait 3-5 minutes for GitHub Actions to complete
- Check https://github.com/Big-Life-Lab/popcorn-web/actions for build errors

**Problem: Formatting looks wrong**
- Check CSV for extra commas or quotes
- Verify ORCID is just numbers (no https://)
- Make sure expertise doesn't have special characters

**Problem: Photo doesn't show**
- Verify photo was uploaded to `assets/team/`
- Check filename matches exactly (case-sensitive)
- Ensure path in CSV is correct: `assets/team/filename.jpg`

---

## Quick Reference

### CSV Method (Bulk Updates)
1. Update Google Sheet
2. Download as CSV
3. Upload to `data/team-members.csv` in GitHub
4. Commit
5. Wait for site rebuild

### Manual Method (Leadership)
1. Copy template from team.qmd comments
2. Fill in member details
3. Paste into Leadership section
4. Commit

---

## Getting Help

For technical issues:
- Contact: Doug Manuel (dmanuel@ohri.ca)
- Check build status: https://github.com/Big-Life-Lab/popcorn-web/actions

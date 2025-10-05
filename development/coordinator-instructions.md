# Instructions for Research Coordinator: Managing the Team Page

## Overview
This guide explains how to update the POPCORN-NCD team page when new members join or information changes.

**You will need:**
- Access to the Google Form responses (Google Sheet)
- Access to the GitHub repository (web or desktop app)
- Basic familiarity with copying/pasting text

**Time required:** 5-10 minutes per new team member

---

## Workflow: Adding a New Team Member

### Step 1: Receive Notification
When someone fills out the team member Google Form, you'll receive a notification (if configured) or check the response sheet periodically.

### Step 2: Review the Response
Open the Google Sheet with form responses. For each new row:
- Verify all required fields are complete
- Check ORCID format (should be 16 digits or full URL)
- Note which section they belong to (Leadership, Working Group, or SAG)
- If photo uploaded: Download from Google Drive, save to desktop

### Step 3: Open team.qmd for Editing

**Option A: GitHub Web Interface (Easiest)**
1. Go to https://github.com/Big-Life-Lab/popcorn-web
2. Click on `team.qmd` file
3. Click pencil icon (✏️) to edit
4. Make your changes (see Step 4)
5. Scroll to bottom, add commit message: "Add [Name] to [Section]"
6. Click "Commit changes"

**Option B: GitHub Desktop (If installed)**
1. Open GitHub Desktop
2. Make sure you're on the correct branch
3. Click "Open in Visual Studio Code" (or your text editor)
4. Find and open `team.qmd`
5. Make your changes (see Step 4)
6. Save file
7. Return to GitHub Desktop, add commit message, commit, and push

### Step 4: Add the New Member

Find the correct section in team.qmd:

#### **For Leadership (Co-Investigators):**

Find the `## Leadership` section. Copy this template:

```markdown
::: {.g-col-12 .g-col-md-6}
### [Their Role Title]

**[Name], [Credentials]**
[Position]
[Institution]

[Copy their bio from Google Form]

[{{< fa envelope >}} email@example.com](mailto:email@example.com) | [{{< fa brands orcid >}} ORCID](https://orcid.org/[ORCID-number])
:::
```

Paste it before the closing `:::` and fill in their information from the Google Sheet.

#### **For Working Group or Strategic Advisory Group:**

Find the appropriate section (`## Working Group` or `## Strategic Advisory Group`). Copy this template:

```markdown
::: {.team-member}
**[Name], [Credentials]**
*[Institution]*
[Country]

**Expertise:** [Copy expertise from form]

[{{< fa brands orcid >}} ORCID](https://orcid.org/[ORCID-number])
:::
```

**Where to paste:**
- Find the line `::: {.team-grid}` at the start of the section
- Scroll down to find the **last** `:::` before the `---` divider
- Paste your new member **just above** that closing `:::`

### Step 5: Clean Up ORCID Links

If they provided ORCID as a full URL (https://orcid.org/0000-0002-0599-2061):
- Extract just the number part: `0000-0002-0599-2061`
- Put it in the template: `https://orcid.org/0000-0002-0599-2061`

If they didn't provide ORCID:
- Delete the entire ORCID line: `[{{< fa brands orcid >}} ORCID](https://orcid.org/)`

### Step 6: Add Photos (If Provided)

**If they uploaded a photo:**

1. Download photo from Google Drive (linked to form)
2. Rename to: `firstname-lastname.jpg` (e.g., `jane-smith.jpg`)
3. Upload to `assets/team/` folder in GitHub
   - On GitHub web: Navigate to `assets/team/`, click "Add file" → "Upload files"
   - On desktop: Copy file to `assets/team/` folder
4. In team.qmd, add photo line **above** their name:

For Leadership:
```markdown
![Jane Smith](assets/team/jane-smith.jpg){width="150"}

**Jane Smith, PhD**
```

For Working Group/SAG:
```markdown
![Jane Smith](assets/team/jane-smith.jpg){.img-circle width="100"}

**Jane Smith, PhD**
```

### Step 7: Verify and Commit

**Before committing:**
- Double-check spelling of name
- Verify ORCID link format
- Make sure you're in the right section

**Commit message examples:**
- "Add Jane Smith to Strategic Advisory Group"
- "Add John Doe to Working Group"
- "Update Doug Manuel bio and photo"

**After committing:**
- GitHub Actions will automatically rebuild the site (takes 2-3 minutes)
- Check the live site to verify it looks correct: https://popcorn-statement.org/team.html

---

## Common Tasks

### Updating Existing Member Information

1. Find their entry in team.qmd (use Ctrl+F or Cmd+F to search name)
2. Edit the relevant fields
3. Commit with message: "Update [Name] information"

### Removing a Member

1. Find their entire entry (from `::: {.team-member}` to `:::`)
2. Delete the entire block
3. Commit with message: "Remove [Name] from team"

### Changing Member's Section (e.g., Working Group → SAG)

1. Copy their entire entry
2. Delete from old section
3. Paste into new section
4. Commit with message: "Move [Name] from Working Group to SAG"

---

## Troubleshooting

**Problem: The site doesn't update after I commit**
- Wait 3-5 minutes for GitHub Actions to complete
- Check https://github.com/Big-Life-Lab/popcorn-web/actions for build status
- If build failed (red X), contact Doug or technical lead

**Problem: Formatting looks wrong on the site**
- Check that you have matching `:::` opening and closing tags
- Verify you pasted in the correct section
- Make sure there are blank lines between members

**Problem: ORCID link doesn't work**
- Verify format: `https://orcid.org/0000-0002-0599-2061`
- Make sure it's 16 digits (4 groups of 4, separated by hyphens)

**Problem: Photo doesn't appear**
- Check file path: `assets/team/filename.jpg`
- Verify file was uploaded to correct folder
- Check file extension matches (jpg vs jpeg vs png)

---

## Getting Help

**For technical issues:**
- Contact: [Doug Manuel or technical lead email]

**For form/data issues:**
- Check the Google Sheet for incomplete responses
- Follow up with team member directly

---

## Quick Reference: Template Snippets

**Leadership:**
```markdown
::: {.g-col-12 .g-col-md-6}
### Title

**Name, Credentials**
Position
Institution

Bio paragraph.

[{{< fa envelope >}} email](mailto:email) | [{{< fa brands orcid >}} ORCID](https://orcid.org/ID)
:::
```

**Working Group/SAG:**
```markdown
::: {.team-member}
**Name, Credentials**
*Institution*
Country

**Expertise:** Area

[{{< fa brands orcid >}} ORCID](https://orcid.org/ID)
:::
```

**With Photo:**
```markdown
![Name](assets/team/name.jpg){.img-circle width="100"}

**Name, Credentials**
```

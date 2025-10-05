# Google Form Template for POPCORN-NCD Team Member Information

## Purpose
This form collects information from team members (Working Group, Strategic Advisory Group, Co-Investigators) for display on the POPCORN-NCD website team page.

---

## Suggested Google Form Questions

### Section 1: Basic Information

**1. Full Name** *
- Short answer
- Required

**2. Credentials/Degrees** *
- Short answer
- Required
- Example: PhD, MD MSc, DrPH
- Help text: "Please list your academic credentials (e.g., PhD, MD, MPH)"

**3. Primary Institution/Affiliation** *
- Short answer
- Required
- Example: University of Ottawa, The Ottawa Hospital

**4. Country** *
- Short answer
- Required
- Example: Canada, United Kingdom, Australia

---

### Section 2: Role & Expertise

**5. Role in POPCORN-NCD** *
- Multiple choice
- Required
- Options:
  - Co-Investigator
  - Working Group Member
  - Strategic Advisory Group Member
  - Other (with text field)

**6. Area(s) of Expertise** *
- Paragraph
- Required
- Help text: "Please describe your methodological or subject matter expertise (e.g., microsimulation modeling, health economics, chronic disease epidemiology, knowledge translation)"
- Example: "Microsimulation modeling, chronic disease epidemiology"

**7. Brief Bio (Optional)**
- Paragraph
- Optional
- Help text: "2-3 sentences about your background and research focus (used for Leadership section only)"
- Note: This is primarily for Principal Investigators and Co-Investigators

---

### Section 3: Contact & Links

**8. Email Address** *
- Email
- Required
- Note: Only displayed for Leadership section; optional for others

**9. ORCID ID**
- Short answer
- Optional
- Help text: "Your ORCID identifier (16-digit number or full URL)"
- Example: 0000-0002-0599-2061 or https://orcid.org/0000-0002-0599-2061
- Validation: None (we'll clean this up when adding to website)

**10. Professional Website or Profile**
- URL
- Optional
- Help text: "Link to your institutional profile, personal website, or LinkedIn"

---

### Section 4: Photo (Optional)

**11. Headshot/Photo**
- File upload
- Optional
- Help text: "Please upload a professional headshot (square format preferred, minimum 200x200px, JPEG or PNG)"
- Settings: Allow JPEG, PNG; Max file size 5MB

**OR**

**11. Photo URL**
- Short answer
- Optional
- Help text: "If you prefer, provide a URL to your professional headshot hosted elsewhere (e.g., institutional website)"

---

### Section 5: Conflict of Interest

**12. Do you have any conflicts of interest to declare?** *
- Multiple choice
- Required
- Options:
  - No conflicts to declare
  - Yes, I have conflicts to declare (see attached disclosure form)

**13. COI Disclosure Upload**
- File upload
- Optional (conditional on question 12)
- Help text: "Please upload your completed COI disclosure form"
- Settings: Allow PDF; Max file size 10MB

---

## Form Settings Recommendations

**Presentation:**
- Use sections to organize questions
- Add POPCORN-NCD logo to form header
- Include brief introduction explaining purpose

**Response Collection:**
- Collect email addresses (for follow-up)
- Allow response editing after submission
- Send confirmation email to respondent
- Link to response spreadsheet

**Post-Submission:**
- Confirmation message: "Thank you for submitting your information. Your details will be added to the POPCORN-NCD team page. If you need to make changes, please contact [coordinator email]."

---

## Google Sheets Output

Form responses will automatically populate a Google Sheet with columns matching the questions above. This sheet will be the source for updating team.qmd.

**Suggested Sheet Organization:**
- Tab 1: Form Responses (auto-generated)
- Tab 2: Processed for Website (cleaned/formatted data ready for copy)
- Tab 3: COI Tracking

---

## Next Steps After Form Creation

1. Share form link with team members via email
2. As responses come in, research coordinator updates team.qmd
3. Photos uploaded via form are stored in Google Drive → download and add to `assets/team/` folder
4. COI disclosures tracked separately in spreadsheet

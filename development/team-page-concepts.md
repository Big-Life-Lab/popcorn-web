# **Team section for POPCORN website**

## **Purpose**

The team page highlights the leadership, working group, and advisory board involved in developing the POPCORN EQUATOR reporting guideline. It should reflect the credibility and collaborative nature of the project.

## **Page structure**

```
----------------------------------------------------------
# Our team
Short introduction describing the purpose of the group and the guideline’s focus on transparency and rigour.

## Leadership
[Photo] Name | Role | Affiliation | ORCID
[Photo] Name | Role | Affiliation | ORCID

## Working group
[Photo] Name | Affiliation
[Photo] Name | Affiliation
...

## Advisory board
Logos or short list with affiliations.

## Acknowledgement
Funding and institutional support.
----------------------------------------------------------
```

## **Design considerations**

* **Tone:** Professional, understated, consistent with academic guideline projects.
* **Visual style:** White or neutral background; minimal colour accents matching site palette.
* **Layout:**
  * 2–3 columns on desktop; 1–2 columns on mobile.
  * Circular or rounded-square portraits (80–120 px).
  * Short bios limited to one or two lines.
* **Scholarly elements:**
  * Include ORCID icons/links.
  * Keep the section concise; link to a separate page for detailed bios.
* **Accessibility:** Alt text for all images; good colour contrast; responsive design.

## **Quarto implementation**

Create a **team.qmd** page and add it to the site navbar. Use Quarto’s native grid layouts.

### **Example** ****

### **team.qmd**

```
---
title: "Our team"
format:
  html:
    toc: false
    grid:
      gutter: 2rem
---

Our work on the **POPcorn Reporting Guideline** is led by an international collaborative group committed to transparency and rigour in simulation-modelling research.
```

```
## Leadership
::: {layout-ncol=3}
![Jane Smith](images/jane-smith.jpg){.img-circle width="120"}
**Jane Smith, PhD**  
Co-lead, University A  
[ORCID](https://orcid.org/0000-0002-1234-5678)

![John Doe](images/john-doe.jpg){.img-circle width="120"}
**John Doe, MD MSc**  
Co-lead, University B  
[ORCID](https://orcid.org/0000-0002-8765-4321)
:::

## Working group
::: {layout-ncol=3}
![A. Brown](images/a-brown.jpg){.img-circle width="100"}
**A. Brown**  
Epidemiology, University C

![B. Patel](images/b-patel.jpg){.img-circle width="100"}
**B. Patel**  
Health policy, Institute D
:::

## Advisory board
- Organisation 1 – representative name
- Organisation 2 – representative name

## Acknowledgement
Supported by [Funder 1], [Funder 2].
```

## **Implementation tips**

* Optimise images (e.g., 200 × 200 px, ~50 KB).
* Add navigation link in **_quarto.yml**:

```
navbar:
  right:
    - text: "Team"
      href: team.qmd
```

* Keep design consistent with the rest of the site for a professional look.

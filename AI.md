# AI Assistant Instructions for POPCORN-NCD Project

This file contains project-specific instructions for AI assistants working on the POPCORN-NCD repository.

## Project Overview

POPCORN-NCD (Population Health Modelling Consensus Reporting Network for noncommunicable diseases) is developing reporting guidelines for simulation modelling studies in population health research.

## Technology Stack

- **Static Site Generator**: Quarto
- **R Version**: R >= 4.2.0 (compatibility floor for StatsCan/ICES environments)
- **Package Management**: renv
- **Hosting**: GitHub Pages via Cloudflare
- **Build**: GitHub Actions

## Key Project Standards

### R Environment

- Always use renv for package management
- Target R 4.2.0 as the compatibility floor
- Run `renv::snapshot()` after adding packages
- Check `.Rprofile` for R version warnings

### File Structure

- Root-level Quarto files (not nested in `qmd/`)
- `development/` folder for planning documents (excluded from rendering)
- `data/` folder for CSV data sources
- `assets/` folder for images, icons, styles

### Team Page Management

- **Hybrid approach**:
  - Leadership section: Manual updates in `team.qmd`
  - SAG/Working Group: Auto-generated from `data/team-members.csv`
- CSV columns: Section, Name, Credentials, Institution, Country, Expertise, ORCID, Email, Photo
- See `development/coordinator-instructions.md` for workflow

### Icons and Assets

- **No Font Awesome** - use self-hosted SVG icons in `assets/icons/`
- GDPR compliance: all assets must be self-hosted (no third-party CDN requests)
- Icons available: envelope.svg, orcid.svg, github.svg
- Use `<img src="assets/icons/[name].svg" class="inline-icon" alt="...">` syntax

### Git Workflow

- Don't make commits without reviewing with user first
- Draft commit messages as plain text (no code blocks)
- Don't credit AI or Claude Code in commit messages (per user preference)
- Create feature branches for new work
- Use descriptive commit messages following project style

### Quarto Configuration

- Output directory: `docs/`
- Exclude `development/` and `renv/` from rendering
- Use `embed-resources: true` for self-contained pages

## Important Files

- `_quarto.yml` - Site configuration
- `team.qmd` - Team page with hybrid content
- `data/team-members.csv` - SAG and Working Group member data
- `development/POPCORN_StrategicAdvisoryCommitteeTOR_V0.9.3.docx` - SAC terms of reference
- `development/coordinator-instructions.md` - Guide for research coordinator
- `.Rprofile` - R version check and renv activation
- `renv.lock` - R package dependencies

## Current Status

- Team page created but hidden from navbar (review in progress)
- Using self-hosted SVG icons (no Font Awesome dependency)
- Development folder excluded from site rendering

## Guidelines

1. **Review major coding plans with user before implementing**
2. **Always prefer editing existing files** to creating new ones

## Quarto Development

**Preview locally:**

```bash
quarto preview
```

**Build locally:**

```bash
quarto render
```

**Publishing:**

- Automatic via GitHub Actions on push to main
- Output goes to `docs/` directory (DO NOT EDIT - auto-generated)
- Hosted on GitHub Pages via Cloudflare

**Before committing changes:**

1. Run `quarto preview` to check local rendering
2. Verify all links work
3. Check image paths are correct
4. Ensure R chunks execute without errors

## Citation Style

- Use Vancouver citation style (defined in `assets/vancouver.csl`)
- Bibliography stored in `references.bib`

## Open Science

This is an open science project:

- Follow ethical research practices
- Maintain transparency in methods and data
- Respect equity, diversity, and inclusion (EDI) principles
- Ensure accessibility considerations in web design

## Resources

- Main site: https://popcorn-statement.org
- GitHub repo: https://github.com/Big-Life-Lab/popcorn-web
- EQUATOR Network: https://www.equator-network.org
- Reference project: PHES-EF repository structure

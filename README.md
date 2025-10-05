# Population Health Modelling Consensus Reporting Network for Noncommunicable Diseases (POPCORN-NCD)

Developing an internationally agreed-upon reporting guideline for noncommunicable disease modeling studies.

Website: https://big-life-lab.github.io/popcorn-web/

## Requirements

- [Quarto](https://quarto.org/docs/get-started/) (latest version recommended)
- TinyTeX: `quarto install tinytex`
- R >= 4.2.0

## Setup

This project uses [renv](https://rstudio.github.io/renv/) for R package management.

After cloning the repository:

```r
# Restore R package environment
renv::restore()
```

After adding new R packages:

```r
# Update the lockfile
renv::snapshot()
```

**Important for renv:**
- Commit `renv.lock`, `.Rprofile`, and `renv/activate.R`
- Do NOT commit `renv/library/`, `renv/staging/`, or `renv/local/`

## Development

### Local Preview

```bash
quarto preview
```

Opens a live preview that updates automatically with changes.

### Build Locally

```bash
quarto render
```

Generates static files in the `docs/` directory.

### Publishing

The site automatically publishes to GitHub Pages when changes are pushed to the main branch via GitHub Actions.

## Contact

Doug Manuel, Senior Scientist, The Ottawa Hospital (dmanuel@ohri.ca)

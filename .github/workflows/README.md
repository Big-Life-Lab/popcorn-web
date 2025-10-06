# GitHub Actions Workflows

This directory contains automated workflows for the POPCORN-NCD project.

## Active Workflows

### Build & Deploy

- **`publish-docs.yml`** - Publishes site to GitHub Pages
  - Triggers: Push to `main`, manual dispatch
  - Renders Quarto site and deploys to `gh-pages` branch
  - Copies CNAME for custom domain

- **`check-pr.yml`** - Validates PRs before merge
  - Triggers: Pull requests
  - Builds docs to ensure no rendering errors

### Code Quality

- **`lint-r.yml`** - Lints R code for style violations
  - Triggers: PRs and pushes affecting R/Rmd/qmd files
  - Uses `lintr` with 120-char line length
  - Allows both snake_case and camelCase

- **`style-r.yml`** - Auto-formats R code (manual only)
  - Triggers: Manual dispatch only
  - Uses `styler` with tidyverse style guide
  - Commits formatted code automatically
  - **Usage**: Run from Actions tab when code needs formatting

### Content Quality

- **`link-check.yml`** - Checks for broken links
  - Triggers: PRs, pushes to main, weekly on Mondays
  - Scans all Markdown files
  - Ignores localhost and placeholder ORCID IDs
  - Configuration in `link-check-config.json`

- **`accessibility-check.yml`** - Tests WCAG 2.0 AA compliance
  - Triggers: PRs affecting qmd/html/scss files
  - Uses Pa11y to scan rendered HTML
  - Tests both index and team pages
  - Comments on PR if issues found

- **`validate-csv.yml`** - Validates team-members.csv structure
  - Triggers: PRs and pushes affecting CSV files
  - Checks required columns and data types
  - Validates Section values (SAG, Working Group)
  - Verifies ORCID format (0000-0000-0000-0000)
  - Detects duplicate entries

- **`validate-citations.yml`** - Validates BibTeX bibliography
  - Triggers: PRs and pushes affecting references.bib or qmd files
  - Checks required fields for each entry type
  - Validates DOI and year formats
  - Identifies unused bibliography entries
  - Detects citations missing from bibliography

- **`optimize-images.yml`** - Compresses images automatically
  - Triggers: PRs with images, manual dispatch
  - Optimizes PNG files with optipng
  - Compresses JPEG to 85% quality
  - Minifies SVG files (excludes icons folder)
  - Auto-commits optimized images
  - Reports size reduction in PR comment

### Security

- **`dependency-review.yml`** - Reviews dependency changes
  - Triggers: Pull requests
  - Checks for known vulnerabilities
  - Fails on moderate+ severity issues
  - Validates license compatibility

## Composite Actions

- **`build-docs-composite-action`** - Reusable build steps
  - Sets up Quarto, R, and renv
  - Restores R environment from renv.lock
  - Renders Quarto site

## Configuration Files

- `link-check-config.json` - Link checker settings
  - Timeout, retry logic, status codes
  - URL patterns to ignore

## Workflow Permissions

Most workflows use minimal permissions:
- `contents: read` - Read repository contents
- `contents: write` - Only for auto-commit workflows (style-r)
- `pull-requests: write` - Comment on PRs with results

## Best Practices

1. **Before merging PRs**: Ensure all checks pass
2. **Broken links**: Check weekly run results, fix or update ignore patterns
3. **Accessibility**: Address Pa11y warnings to maintain WCAG compliance
4. **Code style**: Run `style-r.yml` manually before major releases
5. **Dependencies**: Review dependency-review warnings for security issues

## Local Testing

Before pushing changes:

```bash
# Lint R code locally
R -e 'lintr::lint("file.R")'

# Style R code locally
R -e 'styler::style_file("file.R")'

# Validate CSV locally
R -e 'readr::read_csv("data/team-members.csv", show_col_types = FALSE, comment = "#")'

# Validate BibTeX locally (requires Python)
python3 -c "import bibtexparser; bibtexparser.load(open('references.bib'))"

# Optimize images locally
optipng -o2 image.png
jpegoptim --max=85 image.jpg
svgo image.svg

# Render site locally
quarto render

# Check accessibility locally (requires Pa11y)
npm install -g pa11y
pa11y docs/index.html
```

## Troubleshooting

### Build failures
- Check R version compatibility (>= 4.2.0)
- Verify `renv.lock` is up to date
- Ensure all R chunks execute without errors

### Link check failures
- External sites may be temporarily down
- Add persistent broken links to ignore patterns in config

### Accessibility failures
- Review Pa11y output for specific WCAG violations
- Common issues: missing alt text, color contrast, heading structure

## Adding New Workflows

When adding workflows:
1. Use minimal required permissions
2. Add descriptive comments
3. Update this README
4. Test thoroughly in a feature branch
5. Consider adding to `AI.md` if relevant for AI assistants

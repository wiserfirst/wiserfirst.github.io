# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

This is a personal blog built with Jekyll and the Minimal Mistakes theme,
deployed to Netlify via GitHub Actions. The blog focuses on technical content,
primarily about Elixir, functional programming, and developer tooling.

## Development Commands

### Local Development

```bash
# Install dependencies
bundle install
npm install --global markdownlint-cli

# Start development server with drafts and live reload
bundle exec jekyll serve --incremental --drafts --livereload

# Build for production
JEKYLL_ENV=production bundle exec jekyll build
```

### Quality Checks

```bash
# Run markdown linting
markdownlint _posts _drafts _pages README.md

# Use Guard for continuous linting during development
bundle exec guard
```

## Architecture

### Content Structure

- Blog posts are in `_posts/` with format `YYYY-MM-DD-title.md`
- Draft posts go in `_drafts/`
- Images for posts are stored in `assets/images/YYYY-MM-DD/`
- Posts use front matter with layout: `single`, classes: `wide`, and excerpt
  separator: `<!--more-->`

### Configuration

- Main config: `_config.yml` - site settings, theme configuration, plugin setup,
  jekyll-minifier settings
- Markdown linting: `.markdownlint.json` - allows specific HTML elements,
  customized rules

### Deployment Pipeline

- Push to `develop` branch triggers GitHub Actions workflow
- Workflow builds Jekyll site and runs markdownlint validation
- On success, deploys to Netlify using stored credentials
- Site is accessible at <https://www.wiserfirst.com>

## Key Dependencies

### Ruby Environment

- Ruby 3.4.1 (managed via asdf)
- Jekyll 4.x with Minimal Mistakes theme
- Key gems: jekyll-paginate, jekyll-sitemap, jekyll-seo-tag, jekyll-minifier

### Node Environment

- Node.js 22.x (managed via asdf)
- markdownlint-cli for content validation

## Writing Guidelines

### New Posts

- Create file in `_posts/` or `_drafts/` following naming convention
- Add appropriate tags for categorization
- Use excerpt separator `<!--more-->` for post previews
- Store images in `assets/images/YYYY-MM-DD/` folders

### Markdown Standards

- Follow markdownlint rules in `.markdownlint.json`
- Allowed inline HTML: a, br, div, figure, img, p, span, ruby, rt
- No trailing punctuation in headers except "?"

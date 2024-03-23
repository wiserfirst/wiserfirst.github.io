[![Build Status][Build Status image]][Build Status url]
[![Netlify Status][Netlify Status image]][Netlify Status url]

This is the codebase for my personal blog at [`wiserfirst.com`][], created with
[Jekyll][] and hosted on [Netlify][]

## Install

### Clone the Repository

```sh
git clone git@github.com:wiserfirst/wiserfirst.github.io.git
cd wiserfirst.github.io
```

### Install Ruby and Nodejs

Ruby is required to run Jekyll and Nodejs is needed to run a development
dependency markdownlint. They can be installed with [`asdf`][] as
follows:

```sh
asdf plugin add ruby
asdf plugin add nodejs
# need to run in this directory
asdf install
```


### Development Dependencies

This app uses the following dependencies during development:

- [markdownlint][] (via [markdownlint-cli][]): make sure Markdown syntax
  conforms to community standards

Install [Node][]-based dependencies in the following way, and remember to
re-shim whatever version manager is being used for Node (I use [`asdf`][]), or
add the `bin` folder of the Node installation to the `$PATH`, otherwise
executables like `markdownlint` may not be available:

```sh
npm install --global markdownlint-cli
asdf reshim nodejs
```

## Usage

### Start blog server

```sh
bundle exec jekyll serve --incremental --drafts --livereload
```

Then, navigate to <http://localhost:4000>

## Theme

This blog currently uses the [Minimal Mistakes][] theme.

## Deployment

This blog is current deployed to [Netlify][] with [Github Actions][] running the
builds.

Just push to the `develop` branch to trigger a new build and if the build is
successful, the site would be deployed to Netlify.

## License

| Category |                         License                           |
|----------|-----------------------------------------------------------|
| Content  | [![License: CC-BY-4.0][license-cc-badge]][license-cc-url] |
| Code     | [![License: MIT][license-mit-badge]][license-mit-url]     |

Content in all blog posts is licensed under the
[Creative Commons Attribution 4.0 license][license-cc-url] (CC-BY-4.0), and all
source code in this repo, and contained within any blog posts, is licensed
under the [MIT license][license-mit-url].

SPDX-License-Identifier: (MIT AND CC-BY-4.0)

[`asdf`]: https://github.com/asdf-vm/asdf
[Build Status image]: https://github.com/wiserfirst/wiserfirst.github.io/actions/workflows/ci.yml/badge.svg
[Build Status url]: https://github.com/wiserfirst/wiserfirst.github.io/actions/workflows/ci.yml
[Jekyll]: https://jekyllrb.com
[license-cc-badge]: https://licensebuttons.net/l/by/4.0/80x15.png
[license-cc-url]: https://creativecommons.org/licenses/by/4.0/legalcode
[license-mit-badge]: https://img.shields.io/badge/License-MIT-lightgrey.svg
[license-mit-url]: https://opensource.org/licenses/MIT
[markdownlint]: https://github.com/DavidAnson/markdownlint
[markdownlint-cli]: https://github.com/igorshubovych/markdownlint-cli
[Minimal Mistakes]: https://github.com/mmistakes/minimal-mistakes
[Netlify]: https://www.netlify.com
[Netlify Status image]: https://api.netlify.com/api/v1/badges/e997650f-fd0c-44c5-a6a5-1488dad7d879/deploy-status
[Netlify Status url]: https://app.netlify.com/sites/elastic-villani-588077/deploys
[Node]: https://github.com/nodejs/node
[Github Actions]: https://github.com/features/actions
[`wiserfirst.com`]: https://www.wiserfirst.com

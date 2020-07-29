[![Build Status][Build Status image]][Build Status url]

This is the codebase for my personal blog at [`wiserfirst.com`][],
which is created with [Jekyll][] and hosted on [Netlify][]

## Install

### Install Ruby

Ruby is required to run Jekyll and it can be installed with [`asdf`][] as
follows:

```sh
asdf plugin add ruby
asdf install ruby 2.7.1
asdf global ruby 2.7.1
```

### Clone the Repository

```sh
git clone git@github.com:wiserfirst/wiserfirst.github.io.git
cd wiserfirst.github.io
bundle install
```

### Development Dependencies

This app uses the following dependencies during development:

- [markdownlint][] (via [markdownlint-cli][]): make sure Markdown syntax
  conforms to community standards
- [HTMLProofer][]: make sure HTML rendered files are accurate and do not have
  broken links etc

Install [Node][]-based dependencies in the following way, and remember to
re-shim whatever version manager is being used for Node (I use [`asdf`][]), or
add the `bin` folder of the Node installation to the `$PATH`, otherwise
executables like `markdownlint` may not be available:

```sh
npm install --global markdownlint-cli
asdf reshim nodejs
```

HTMLProofer is a Ruby gem and so Bundler will bring it into the project.

## Usage

### Start blog server

```sh
bundle exec jekyll serve --incremental --drafts --livereload
```

Then, navigate to <http://localhost:4000>

### Monitor files

This project uses [Guard][] to monitor file changes.

Start Guard with the following command:

```sh
bundle exec guard
```

## Theme

This blog currently uses the [Minimal Mistakes][] theme.

## Deployment

This blog is current deployed to [Netlify][] with [Travis CI][] running the
builds.

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
[Build Status image]: https://travis-ci.com/wiserfirst/wiserfirst.github.io.svg?branch=develop
[Build Status url]: https://travis-ci.com/github/wiserfirst/wiserfirst.github.io
[Guard]: https://github.com/guard/guard
[HTMLProofer]: https://github.com/gjtorikian/html-proofer
[Jekyll]: https://jekyllrb.com
[license-cc-badge]: https://licensebuttons.net/l/by/4.0/80x15.png
[license-cc-url]: https://creativecommons.org/licenses/by/4.0/legalcode
[license-mit-badge]: https://img.shields.io/badge/License-MIT-lightgrey.svg
[license-mit-url]: https://opensource.org/licenses/MIT
[markdownlint]: https://github.com/DavidAnson/markdownlint
[markdownlint-cli]: https://github.com/igorshubovych/markdownlint-cli
[Minimal Mistakes]: https://github.com/mmistakes/minimal-mistakes
[Netlify]: https://www.netlify.com
[Node]: https://github.com/nodejs/node
[Travis CI]: https://travis-ci.org/
[`wiserfirst.com`]: https://www.wiserfirst.com

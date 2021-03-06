# Changelog

## Ongoing [☰](https://github.com/philnash/jekyll-zopfli/compare/v2.5.0...main)

...

## 2.5.0 (2021-02-13) [☰](https://github.com/philnash/jekyll-zopfli/compare/v2.4.1...v2.5.0)

### Changed

- Added JSON files to compressable extensions
- Moved from Travis CI to GitHub Actions

### Fixed

- Stop overwriting Jekyll config, which invalidates the Jekyll cache (see https://github.com/jekyll/jekyll/issues/8551)

## 2.4.1 (2020-01-30) [☰](https://github.com/philnash/jekyll-zopfli/compare/v2.4.0...v2.4.1)

### Changed

- Fixes the path handed to `Dir.glob` by using `File.join` instead of string concatenation

## 2.4.0 (2019-12-31) [☰](https://github.com/philnash/jekyll-zopfli/compare/v2.3.0...v2.4.0)

### Changed

- Doesn't regenerate files that haven't changed in incremental builds.

## 2.3.0 (2019-10-23) [☰](https://github.com/philnash/jekyll-zopfli/compare/v2.2.0...v2.3.0)

### Changed

- Fixed tests and actually replaces files when it is supposed to. Thanks @pat!

## 2.2.0 (2019-08-26) [☰](https://github.com/philnash/jekyll-zopfli/compare/v2.1.0...v2.2.0)

### Changed

- Opens up version support for Jekyll 4 (thanks [@thedanbob](https://github.com/thedanbob))

## 2.1.0 (2019-03-30) [☰](https://github.com/philnash/jekyll-zopfli/compare/v2.0.0...v2.1.0)

### Added

- Adds setting to replace original files with gzipped for serving from AWS S3

## 2.0.0 (2018-11-24) [☰](https://github.com/philnash/jekyll-zopfli/compare/v1.1.0...v2.0.0)

### Added

- Hooks into Jekyll::Assets if available
- Adds frozen string literal comment

### Changed

- Uses built in `Jekyll.env` instead of `ENV["JEKYLL_ENV"]`
- Changes `Jekyll::Zopfli::Compressor` to a module and implements a `compress_directory` method
- Moves Jekyll::Zopfli::ZIPPABLE_EXTENSIONS into plugin config that can overwritten in the site config

## 1.1.0 (2018-01-03) [☰](https://github.com/philnash/jekyll-zopfli/compare/v1.0.0...v1.1.0)

### Changed

- Only run the post write hook when the environment variable `JEKYLL_ENV` is `production`

## 1.0.0 (2018-01-02) [☰](https://github.com/philnash/jekyll-zopfli/commits/v1.0.0)

### Added

- Methods to Gzip compress text files throughout a Jekyll site using Zopfli
- Site post write hook to trigger compression

# Naughtygram

[![Build Status](https://travis-ci.org/Zensavona/naughtygram.svg?branch=master)](https://travis-ci.org/Zensavona/naughtygram) [![Inline docs](http://inch-ci.org/github/zensavona/naughtygram.svg)](http://inch-ci.org/github/zensavona/naughtygram) [![Coverage Status](https://coveralls.io/repos/Zensavona/naughtygram/badge.svg?branch=master&service=github)](https://coveralls.io/github/Zensavona/naughtygram?branch=master) [![hex.pm version](https://img.shields.io/hexpm/v/naughtygram.svg)](https://hex.pm/packages/naughtygram) [![hex.pm downloads](https://img.shields.io/hexpm/dt/naughtygram.svg)](https://hex.pm/packages/naughtygram) [![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

### Naughtygram is a very basic client for Instagram's private API.

### [Read the docs](https://hexdocs.pm/naughtygram)

Use at your own risk, this probably violates their TOS.

** TODO: add examples **


## Changelog

### 0.1.6
- fix a test which was failing due to the new errors not being handled properly

### 0.1.5
- fix a bug where `upload_media/4` was returning the internal media id, rather than the public (useful) one

### 0.1.4
- more descriptive errors when trying to upload an invalid media type

### 0.1.3

- remove uneeded items from HTTP reqs
- add the `Naughtygram.upload_media/4` function for (who would have guessed it...) uploading media.

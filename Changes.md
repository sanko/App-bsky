# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Added `oauth` command for a streamlined, interactive authentication flow with an automatic local listener.
- Implemented `chat` and `dm` commands for managing conversations and sending direct messages via PDS proxying.
- Enhanced session management to correctly persist and resume full metadata, including DPoP keys and scopes.
- Improved `show-session` command with detailed diagnostic output.
- Updated POD documentation with clear usage examples for all new features.

### Fixed
- Modernized initialization logic to align with the latest architectural changes in At.pm and Bluesky.pm.

## [0.04] - 2024-02-13

### Changed
- Update to fit current API of At.pm

## [0.03] - 2024-01-27

### Added
- Commands for app passwords, likes, reposts, invite codes, threads, etc.

## [0.02] - 2024-01-26

### Fixed
- Less broken session management

## [0.01] - 2024-01-26

### Added
- original version

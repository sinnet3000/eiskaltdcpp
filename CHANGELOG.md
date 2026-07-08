# Eiskaltdcpp Changelog

Everything that's changed since the `v2.4.2` release in March 2021, plus what's currently sitting on the `next` branch.

## Unreleased / next branch (as of July 7, 2026)

### On the `next` branch
* Upload speed is no longer limited to fixed presets; you can set it to whatever value you want.
* Added native macOS build scripts that vendor and rebuild the x86_64 app against the original toolchain, handle library install paths, and produce a signed DMG.

### Core changes

Includes 80+ commits from the official repo's master branch (up until commit `697db4b03e3d9ffa48b3d4c74fd043dee7663266`), plus our own local changes (https://github.com/eiskaltdcpp/eiskaltdcpp/commits/master/):

* Ported ADL search from PCRECPP to PCRE2.
* Switched the build dependency from `libidn` to `libidn2`.
* Updated the `miniupnpc` API to version 18.
* Fixed a UTF-8 validator bug that was breaking messages on ADC(S) hubs.
* Updated the hublist servers and removed the dead `tankafett.biz` tracker.
* Fixed build issues on Windows and when building against `musl` libc without GNU `libintl`.

### macOS
* Fixed compilation issues with recent Homebrew versions.
* Fixed the macOS app bundle version strings.
* Dropped support for macOS 10.13 (High Sierra).
* Fixed a `CLIENT_DATA_DIR` path resolution issue on macOS.

### Qt UI
* Fixed sorting by the "shared date" column in the share browser.
* Minor improvements to the magnet link dialog.
* Fixed size formatting and switched to a 32-bit integer for displaying sizes.
* Updated the Linux `.desktop` files and application metainfo.

### Build system (CMake) and CI
* Bumped the minimum CMake version to 3.2.0.
* Added `USE_XATTR` (defaults to OFF) and `INSTALL_METAINFO` config options.
* Now installs standard `pkgconfig` files for the `eiskaltdcpp` library.
* Moved Travis CI from `.org` to `.com` and dropped Ubuntu 16.04 support.
* Cleaned up a number of `cppcheck` warnings.

### Translations and documentation
* Added a Georgian translation.
* Pulled in continuous translation updates from Transifex.
* Added MacPorts links to the `README`.
* Updated `AUTHORS`, `TODO`, and the legacy text changelogs.

---

Thanks to everyone who's submitted patches, reported bugs, and helped with translations.

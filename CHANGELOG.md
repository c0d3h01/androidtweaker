# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.6.0] - 2026-10-07

### Added

- New companion app (`com.c0d3h01.androidtweaker`): 4 profile cards, root status, module log viewer. Replaces legacy `beastmode.profile`, auto-removed on upgrade.
- Brand assets (`branding/`): logo, README banner, adaptive launcher icon.
- `Makefile` dev shortcuts (`test`, `release`, `pack`, `check`, `doctor`).

### Changed

- **Breaking:** profile codes shifted to 1=battery, 2=balanced, 3=performance, 4=gaming (was 2-5 with 1 as no-op). A stale stored value falls back to balanced once, then corrects on next tap.
- Install flow optimized: dev-only sources pruned right after extraction (install loops never scan them); `service.sh` fast-paths boot when there is nothing to install and gates the legacy-package scan behind a sentinel file instead of every boot.

## [1.5.0] - 2026-06-14

### Changed

- Install banner now sources version from `module.prop` (single source of truth).
- Removed GitHub auto-launch on install; replaced with printed links.
- Boot wait in `service.sh` now polls up to 5 min then settles 15s (down from 30s fixed wait after up to 30s loop).
- Hardcoded `beastmode.profile` package name replaced with `companionPkg` field in `module.prop`, read by `service.sh` and `uninstall.sh`.

### Fixed

- `module.prop`: `description=null` literal replaced with empty string; `install.sh` populates it via `sed`.
- `uninstall.sh`: now uses `companionPkg` from `module.prop` instead of hardcoded package name.

## [1.4.9] - 2024-05-24

### Added

- Misc Tweaks.

### Changed

- Improved overall tweaks.
- Task Management.
- Improved priority functions.

### Fixed

- VM tweaks.
- Synchronisation.

### Removed

- Unnecessary tweaks.

## [1.4.7]

### Added

- New advanced management tweaks.
- Virtual memory tweaks.
- Zram tweaks.

### Changed

- Improved overall tweaks.
- Improved Services in execution.
- Improved VM tweaks.

### Fixed

- Compilation.
- BUSYBOX synchronisation.
- PID execution.

### Removed

- Unnecessary tweaks.

## [1.4.5]

### Added

- **New Tweaks:** Unlock new customization options for your device.
- **Cross-Device Sync:** Keep your preferences consistent across devices.

### Changed

- **Enhanced Functionality:** Enjoy smoother performance and improved responsiveness.
- **Simplified Installation:** Setup made easier for seamless usage.
- **Module Improvements:** Experience optimized performance with revamped modules.

## [1.4.1]

### Added

- Terminal menu.
- RAM cleaner on profile changing.

### Fixed

- General bugs.

### Removed

- APK due to incompatibility.

# Changelog

## [1.3.0] - 2026-11-06

### Upgraded
- **Real-Time Data Progress Telemetry**: Added granular tracking for uploaded bytes (`upload_bytes_done` / `upload_bytes_total`), file counts (`upload_files_done` / `upload_files_total`), and dynamic transfer speed in both `OverviewCard` and the top bar widget.
- **Immediate Error & Warning Visibility**: `ActivityCard` now inspects recent log events to immediately highlight sync issues with urgent indicator badges (`󰅙`) and explicit guidance, replacing ambiguous idle status.
- **Active Backup Protection Matrix**: Integrated a structured matrix in `OverviewCard` surfacing protection coverage across AI instructions/skills, desktop/Hyprland configs, workspace repositories, and GDrive mirror.
- **Guarded Wheel & Tab Navigation**: Added vertical scroll threshold guards to prevent accidental tab switching while scrolling content cards, plus bounded keyboard navigation (`Shift+Tab` wrap) and `switchTab(index)` bar widget API.
- **Application Vector Assets**: Added official SVG application and symbolic icons (`assets/cloud-sync.svg`, `assets/cloud-sync-symbolic.svg`, `assets/logo.svg`).

### Fixed / Previous Errors Resolved
- Fixed ambiguous sync status where checking/scanning files appeared frozen or blank; now displays an indeterminate "Checking files…" state before uploads start.
- Fixed silent failure masking where the dashboard displayed "All Directories In Sync" despite underlying errors or reconnect requirements.
- Fixed privacy verification violation by replacing hardcoded user path literals with portable `Quickshell.env("HOME")` resolution.
- Fixed layout dead space in `OverviewCard` when sync was idle.

## [1.2.0] - 2026-11-02

- Refine GSync with compact accessible tabs, short directional crossfades and balanced theme-colored glass.
- Guard hidden/reduced-motion visual updates and bound tab indices; retain all existing sections and backend operations.
- Qualify palette references for current Qt compatibility and add native real-card compilation plus isolated keyboard/wheel/reduced-motion checks.

## [1.1.0] - 2026-10-11

- Preset-aware dashboard, review-first restore with custom mappings and rollback copies, mandatory credential exclusions, opt-in new backup folders and truthful failure status.
- Clean current release files and retire workstation captures. Existing public history is preserved. Future commits use a GitHub noreply address; CI checks current release payloads.
- See docs/RELEASE-PRIVACY.md for scope and limitations. Sample artwork illustrates the design, rather than proving a live runtime result.

All notable changes to `omarchy-cloud-sync` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-09-08

### Added
- Initial clean public release for Omarchy 4.0.2 / Arch Linux.
- Quickshell dashboard with sync telemetry, activity monitors, and folder explorer.
- Python backup engine integrating with rclone.
- Non-intrusive systemd user timers and safe configuration schema.
- Comprehensive safe user installer script (`install.sh`) supporting `--dry-run`.
- Full security exclusions, sanitized configurations, and complete documentation.

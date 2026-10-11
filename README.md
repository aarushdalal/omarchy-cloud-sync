# Omarchy Cloud Sync (`omarchy-cloud-sync`)

> **Unofficial / Community Plugin**: An independent open-source cloud synchronization dashboard and bar widget for Omarchy.

An Omarchy plugin providing a Quickshell bar widget and full dashboard for monitoring and triggering rclone-based cloud backups — visible directly in the Omarchy top bar and expandable into a full sync manager panel.

This project was developed through an AI-assisted workflow. The concept, customization, configuration, testing, integration, and final iteration were directed and carried out by me.

---

## My Contribution

I did not write Omarchy, Quickshell, Hyprland, or rclone from scratch. What I contributed:

- **Plugin Architecture**: Designed and structured this as a conformant Omarchy plugin with `manifest.json`, `BarWidget.qml`, and `SyncDashboard.qml` following the Omarchy plugin system conventions.
- **Bar Widget**: Designed and implemented the `BarWidget.qml` Quickshell QML component showing live sync status, transfer progress, and last-sync timestamp in the Omarchy top bar.
- **Sync Dashboard UI**: Designed and built `SyncDashboard.qml` — the expandable full-panel sync manager with cards for sync status, bandwidth, remote quota, and manual trigger controls.
- **Backend Engine**: Authored the `omarchy-cloud-sync` Python backup engine (multi-directory, structured JSON spec, rclone invocation, error handling, status reporting).
- **Configuration Format**: Designed the `cloud-sync.json` specification format for declaring which directories and files to sync.
- **Systemd Integration**: Wrote the systemd user timer and service files in `systemd/` for automated periodic backups.
- **Installer**: Authored `./install.sh` for safe user-scope deployment.
- **Documentation**: Wrote all usage, configuration, and troubleshooting docs.
- **Testing**: Tested on Omarchy 4.0.2 / Quickshell 0.3.1 / rclone 1.75.0 with Google Drive (`GDrive:`) remote.

---

## Based On / Credits

- **[Omarchy](https://github.com/basecamp/omarchy)** — The open-source Arch Linux desktop environment and plugin system by Basecamp. This plugin uses the Omarchy plugin manifest format and bar widget API.
- **[Quickshell](https://quickshell.outfoxxed.me)** — The Qt6 QML Wayland layer-shell desktop shell that renders the bar widget and dashboard panel.
- **[Hyprland](https://hyprland.org)** — The Wayland tiling compositor.
- **[rclone](https://rclone.org)** — The open-source cloud sync engine that performs the actual backup transfers. This plugin wraps rclone — rclone itself is not modified.

**Related Repos**:
- [omarchy-system-pulse](https://github.com/aarushdalal/omarchy-system-pulse) — System telemetry, audio, and hardware dashboard
- [omarchy-config-time-machine](https://github.com/aarushdalal/omarchy-config-time-machine) — Configuration snapshot and restore system
- [omarchy-focus-hub](https://github.com/aarushdalal/omarchy-focus-hub) — Pomodoro timer and focus session manager

---

## Plugin Manifest

This repository includes a valid `manifest.json` for the Omarchy plugin system:

```json
{
  "schemaVersion": 1,
  "id": "daemon0.cloud-sync",
  "name": "Cloud Sync",
  "version": "1.0.0",
  "author": "Daemon0",
  "description": "Cloud backup and synchronization dashboard with optional rclone integration",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "BarWidget.qml" },
  "barWidget": {
    "displayName": "Cloud Sync",
    "category": "System",
    "allowMultiple": false,
    "defaultSection": "right"
  }
}
```

---

## Features

- **Top-Bar Widget**: Live sync status, transfer indicator, and last-backup timestamp visible in the Omarchy bar at all times.
- **Full Dashboard Panel**: Expandable sync manager with cards for active transfers, remote quota, recent sync log, and manual trigger button.
- **Structured JSON Backup Spec**: Declare exactly which directories and file patterns to back up via `~/.config/omarchy/cloud-sync.json`.
- **Systemd User Timer**: Automatic periodic backups without root privileges via `omarchy-cloud-sync.timer`.
- **FUSE Mount Integration**: Companion `rclone-mount.service` provides a browsable `~/CloudDrive` FUSE mountpoint.
- **Dry-Run Support**: Preview what would be synced before committing any transfers.

---

## Requirements

- **Operating System**: Arch Linux (rolling release, x86_64)
- **Desktop Shell**: Omarchy (`dev (13f18b2c) / 4.0.2`) with Quickshell (`0.3.1`)
- **Compositor**: Hyprland (`0.56.2`)
- **Core Dependencies**: `rclone` (≥ 1.70), `python3`, `jq`, `bash`
- **Optional**: `fuse3` (for FUSE cloud mount at `~/CloudDrive`)

---

## Compatibility

| Component | Tested Version | Compatibility Status |
|---|---|---|
| Omarchy | `dev (13f18b2c) / 4.0.2` | Fully compatible |
| Quickshell | `0.3.1` | Fully compatible |
| Hyprland | `0.56.2` | Fully compatible |
| rclone | `1.75.0` | Fully compatible |

---

## Installation

### Method 1: Using Omarchy Plugin Manager (Recommended)

```bash
omarchy plugin add https://github.com/aarushdalal/omarchy-cloud-sync.git --enable
```

### Method 2: Using the Safe User Installer

```bash
git clone https://github.com/aarushdalal/omarchy-cloud-sync.git
cd omarchy-cloud-sync

# Validate dependencies
./install.sh check

# Preview changes without writing files
./install.sh install --dry-run

# Perform installation
./install.sh install
```

---

## System Setup Before Installation

1. **Configure rclone remote** (if not already done):
   ```bash
   rclone config
   # Follow prompts to create a named remote, e.g. "GDrive:"
   ```
2. **Verify `~/.local/bin` is on `$PATH`** (standard in Omarchy).
3. **Never run the installer with `sudo`** — everything operates in `$HOME`.

---

## Configuration

Edit `~/.config/omarchy/cloud-sync.json` to declare what to back up:

```json
{
  "remote": "GDrive:Omarchy/",
  "directories": [
    { "local": "~/.config/hypr", "remote": "config/hypr" },
    { "local": "~/.config/omarchy", "remote": "config/omarchy" }
  ]
}
```

See `examples/` in this repository for a complete annotated example.

---

## Commands

```bash
omarchy-cloud-sync sync        # Execute full structured cloud backup
omarchy-cloud-sync status      # Inspect sync telemetry and remote quota
omarchy-cloud-sync dry-run     # Preview what would be synced

# Systemd management:
systemctl --user start omarchy-cloud-sync.timer    # Enable automatic syncing
systemctl --user status rclone-mount.service        # Check FUSE mount health
```

---

## Update

```bash
omarchy plugin update daemon0.cloud-sync
```

---

## Uninstall

```bash
./install.sh uninstall
# Or:
omarchy plugin remove daemon0.cloud-sync --yes
```

---

## Security and Privacy

- No credentials are stored or read by this plugin beyond what rclone is already configured with in `~/.config/rclone/rclone.conf`.
- `rclone.conf` is explicitly excluded from Config Time Machine snapshots.
- No audio, screen, or browsing data is ever sent to cloud storage unless explicitly declared in `cloud-sync.json`.

---

## Troubleshooting

- **Widget shows "not configured"**: Ensure `~/.config/omarchy/cloud-sync.json` exists and contains a valid `remote` key.
- **rclone auth errors**: Run `rclone config reconnect <remote>:` to refresh OAuth tokens.
- **FUSE mount not visible**: Run `systemctl --user status rclone-mount.service` and check journald for errors.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Credits / Third-Party Notices

- Built for the [Omarchy](https://github.com/basecamp/omarchy) desktop environment.
- Powered by [Quickshell](https://quickshell.outfoxxed.me/), [Hyprland](https://hyprland.org/), and [rclone](https://rclone.org/).
- Not an official Omarchy product.

## Refinement and privacy update

Backup coverage · clear status · reviewable restore. Current showcases use sample data; see [release privacy](docs/RELEASE-PRIVACY.md). Existing Git history is preserved.

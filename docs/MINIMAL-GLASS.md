# Minimal glass UI

Version 1.2.0 keeps the existing dashboard sections and services. Presentation uses a 48-unit tab rail, a maximum 24-unit directional reveal scaled by the current motion intensity, a small depth change and a 94% theme-colored background. Reduced motion snaps to the settled page; hidden pages cannot accept input. Native keyboard focus, outside-click dismissal and popup ownership remain in the existing host.

The read-only status IPC reports `minimal-glass-20261102`. No backend daemon, restore, sync or focus enforcement policy changes are included. Existing local card redesigns, artwork and session defaults outside this patch are deliberately excluded.

On a desktop with Quickshell, Qt Quick Test and an installed Omarchy shell, run `python3 tools/check_dashboard_ui.py . SyncDashboard.qml 4 /tmp/dashboard-ui-evidence`. The first test compiles real cards in a hidden native host with no service connected; interaction tests use the actual tab/page code with inert cards/providers and a substituted non-native host. This does not measure compositor frame rate or authorize a backend action.

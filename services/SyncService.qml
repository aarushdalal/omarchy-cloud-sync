import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property bool active: false
  property string status: "idle"
  property string message: "Idle"
  property string currentFile: ""
  property string speed: "0 B/s"
  property real progressPct: 0.0
  property string etaFormatted: "0s"
  property string bytesTransferredFormatted: "0 B"
  property string bytesTotalFormatted: "0 B"

  property var activeTransfers: []
  property var recentLogs: []
  property var folders: []
  property var excludePatterns: []
  property var remotes: ["GDrive"]
  property string selectedRemote: "GDrive"
  property string remoteRoot: "Omarchy"
  property string remoteFullPath: "GDrive:Omarchy/"
  property bool mounted: false
  property string mountPath: (Quickshell.env("HOME") || "") + "/CloudDrive"
  property int autoSyncIntervalHours: 0
  property int transfers: 4
  property string bwlimit: "0"

  property bool rcloneInstalled: true
  property bool rcloneConfigured: true
  property string rcloneStatus: "ready"
  property string rcloneMessage: ""

  // Storage Quota
  property var storage: ({
    "remote": "GDrive",
    "total": 0,
    "used": 0,
    "free": 0,
    "total_formatted": "Unknown",
    "used_formatted": "0 B",
    "free_formatted": "0 B",
    "trashed_formatted": "0 B",
    "used_pct": 0.0,
    "auth_error": false
  })

  readonly property bool authError: Boolean(rcloneInstalled && rcloneConfigured && storage && (storage.auth_error === true || (storage.error && (storage.error.indexOf("invalid_grant") !== -1 || storage.error.indexOf("expired") !== -1 || storage.error.indexOf("reconnect") !== -1))))

  property bool dashboardOpen: false

  readonly property string stateFilePath: (Quickshell.env("XDG_RUNTIME_DIR") || ("/run/user/" + Quickshell.env("UID"))) + "/omarchy-cloud-sync/state.json"
  readonly property string configFilePath: Quickshell.env("HOME") + "/.config/omarchy/cloud-sync.json"

  // 1. Direct inotify FileView watching state.json (Instant 0ms live telemetry)
  FileView {
    id: stateFileView
    path: root.stateFilePath
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.applyStateJson(text())
  }

  // 2. Direct inotify FileView watching cloud-sync.json
  FileView {
    id: configFileView
    path: root.configFilePath
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.applyConfigJson(text())
  }

  function applyStateJson(rawText) {
    if (!rawText || rawText.trim() === "") return
    try {
      var data = JSON.parse(rawText.trim())
      root.active = (data.active === true)
      root.status = data.status || "idle"
      root.message = data.message || "Idle"
      root.currentFile = data.current_file || ""
      root.speed = data.speed || "0 B/s"
      root.progressPct = (typeof data.progress_pct === "number") ? data.progress_pct : 0.0
      root.etaFormatted = data.eta_formatted || "0s"
      root.bytesTransferredFormatted = data.bytes_transferred_formatted || "0 B"
      root.bytesTotalFormatted = data.bytes_total_formatted || "0 B"
      root.activeTransfers = data.active_transfers || []
      root.recentLogs = data.recent_logs || []

      if (typeof data.rclone_installed === "boolean") {
        root.rcloneInstalled = data.rclone_installed
      }
      if (typeof data.rclone_configured === "boolean") {
        root.rcloneConfigured = data.rclone_configured
      }
      if (data.rclone_status) {
        root.rcloneStatus = data.rclone_status
      }
      if (data.rclone_message) {
        root.rcloneMessage = data.rclone_message
      }

      if (data.storage) {
        root.storage = data.storage
      }
    } catch(e) {
      // ignore concurrent write parse error
    }
  }

  function applyConfigJson(rawText) {
    if (!rawText || rawText.trim() === "") return
    try {
      var cfg = JSON.parse(rawText.trim())
      root.folders = cfg.folders || []
      root.excludePatterns = cfg.exclude_patterns || []
      root.selectedRemote = cfg.remote || "GDrive"
      root.remoteRoot = cfg.remote_root || "Omarchy"
      root.remoteFullPath = root.selectedRemote + ":" + root.remoteRoot + "/"
      root.mountPath = cfg.mount_path || (Quickshell.env("HOME") + "/CloudDrive")
      root.autoSyncIntervalHours = cfg.auto_sync_interval_hours || 0
      root.transfers = cfg.transfers || 4
      root.bwlimit = cfg.bwlimit || "0"
    } catch(e) {}
  }

  onDashboardOpenChanged: {
    refresh()
  }

  Timer {
    id: pollTimer
    interval: (root.active || root.dashboardOpen) ? 500 : 3000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      stateFileView.reload()
      configFileView.reload()
      if (root.dashboardOpen && !statusProc.running) {
        statusProc.running = true
      }
    }
  }

  function refresh() {
    stateFileView.reload()
    configFileView.reload()
    if (!statusProc.running) {
      statusProc.running = true
    }
  }

  Process {
    id: statusProc
    command: [Quickshell.env("HOME") + "/.config/omarchy/plugins/daemon0.cloud-sync/services/sync-helper.sh", "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        if (!text || text.trim() === "") return
        try {
          var data = JSON.parse(text.trim())
          root.applyStateJson(text)
          if (data.storage) root.storage = data.storage
          if (data.remotes) root.remotes = data.remotes
          if (typeof data.rclone_installed === "boolean") root.rcloneInstalled = data.rclone_installed
          if (typeof data.rclone_configured === "boolean") root.rcloneConfigured = data.rclone_configured
          if (data.rclone_status) root.rcloneStatus = data.rclone_status
          if (data.rclone_message) root.rcloneMessage = data.rclone_message
          root.mounted = (data.mounted === true)
        } catch (e) {}
      }
    }
  }

  // Action Triggers
  function startSync() {
    execAction(["sync-start"])
  }

  function stopSync() {
    execAction(["sync-stop"])
  }

  function restoreFromCloud() {
    execAction(["restore"])
  }

  function toggleMount() {
    execAction(["toggle-mount"])
  }

  function reconnect() {
    execAction(["reconnect"])
  }

  function refreshQuota() {
    execAction(["refresh-storage"])
  }

  function pickFolder() {
    execAction(["pick-folder"])
  }

  function pickFolderMenu() {
    execAction(["pick-menu"])
  }

  function addFolder(pathStr, name) {
    var args = ["add-folder", pathStr]
    if (name) args.push(name)
    execAction(args)
  }

  function removeFolder(folderId) {
    execAction(["remove-folder", folderId])
  }

  function toggleFolder(folderId) {
    execAction(["toggle-folder", folderId])
  }

  function setRemote(remoteName) {
    execAction(["set-remote", remoteName])
  }

  function setRemoteRoot(rootName) {
    execAction(["set-remote-root", rootName])
  }

  function setSchedule(hours) {
    execAction(["set-schedule", hours.toString()])
  }

  function setTransfers(count) {
    execAction(["set-transfers", count.toString()])
  }

  function clearLogs() {
    execAction(["clear-logs"])
  }

  function installRclone() {
    execAction(["install-rclone"])
  }

  function configRclone() {
    execAction(["config-rclone"])
  }

  function execAction(args) {
    var fullCmd = [Quickshell.env("HOME") + "/.config/omarchy/plugins/daemon0.cloud-sync/services/sync-helper.sh"].concat(args)
    actionProc.running = false
    actionProc.command = fullCmd
    actionProc.running = true
  }

  Process {
    id: actionProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.refresh()
      }
    }
  }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "services"

BarWidget {
  id: root
  moduleName: "daemon0.cloud-sync"

  SyncService {
    id: syncService
    dashboardOpen: root.opened
  }

  IpcHandler {
    target: "daemon0.cloud-sync"
    function open(): void { root.open() }
    function close(): void { root.close() }
    function toggle(): void { root.toggle() }
  }

  // Popup open/close shape contract for shell/bar
  readonly property bool opened: dashboard.open
  function open() { dashboard.open = true }
  function close() { dashboard.open = false }
  function toggle() { dashboard.open = !dashboard.open }

  implicitWidth: islandSurface.implicitWidth
  implicitHeight: root.barSize

  // The Taskbar Island Pill (Borderless, matching omni-center / study-focus styling)
  BorderSurface {
    id: islandSurface
    anchors.centerIn: parent
    implicitWidth: rowLayout.implicitWidth + Style.space(16)
    height: Math.max(14, root.barSize - Style.space(2))
    radius: Style.cornerRadius
    color: islandMouse.containsMouse
      ? Style.hoverFillFor(root.bar ? root.bar.barForeground : Color.bar.text, Color.accent)
      : (root.opened || syncService.active
          ? Style.selectedFillFor(root.bar ? root.bar.barForeground : Color.bar.text, Color.accent)
          : Style.normalFillFor(root.bar ? root.bar.barForeground : Color.bar.text, Color.accent))
    borderSpec: Border.none()
    border.width: 0
    scale: islandMouse.pressed ? Motion.pressScale : (islandMouse.containsMouse ? (1.0 + 0.04 * Motion.springOvershoot) : 1.0)

    Behavior on scale { NumberAnimation { duration: Motion.micro; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
    Behavior on color { ColorAnimation { duration: Motion.micro; easing.type: Motion.easeStandard } }

    Row {
      id: rowLayout
      anchors.centerIn: parent
      spacing: Style.space(6)

      // Cloud Icon or Rotating Sync Indicator
      Item {
        width: Style.bar.iconCanvas
        height: Style.bar.iconCanvas
        anchors.verticalCenter: parent.verticalCenter

        Item {
          id: iconRotator
          anchors.centerIn: parent
          width: cloudIcon.implicitWidth
          height: cloudIcon.implicitHeight
          rotation: 0

          Text {
            id: cloudIcon
            anchors.centerIn: parent
            text: !syncService.rcloneInstalled
              ? "󰅚"
              : (!syncService.rcloneConfigured
                  ? "󰒲"
                  : (syncService.active
                      ? "󰓦"
                      : (syncService.authError ? "󰅙" : "󰅟")))
            color: (!syncService.rcloneInstalled || !syncService.rcloneConfigured || syncService.authError)
              ? Color.urgent
              : (syncService.active ? Color.accent : (root.bar ? root.bar.barForeground : Color.bar.text))
            font.family: root.bar ? root.bar.fontFamily : ((Style.font && Style.font.family) ? Style.font.family : "")
            font.pixelSize: 10
            anchors.verticalCenter: parent.verticalCenter
          }

          RotationAnimation {
            id: rotAnim
            target: iconRotator
            property: "rotation"
            running: syncService.active && syncService.rcloneInstalled && syncService.rcloneConfigured
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: 1200
            onRunningChanged: {
              if (!running) {
                iconRotator.rotation = 0
              }
            }
          }
        }

        Connections {
          target: syncService
          function onActiveChanged() {
            if (!syncService.active) {
              iconRotator.rotation = 0
            }
          }
        }

        // Small pulse dot when syncing
        Rectangle {
          anchors.right: parent.right
          anchors.top: parent.top
          width: 5
          height: 5
          radius: 2.5
          color: Color.accent
          visible: syncService.active && syncService.rcloneInstalled && syncService.rcloneConfigured

          SequentialAnimation on opacity {
            running: syncService.active && syncService.rcloneInstalled && syncService.rcloneConfigured
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 0.2; duration: 500 }
            NumberAnimation { from: 0.2; to: 1.0; duration: 500 }
          }
        }
      }

      // Live Label: Progress % or Speed when syncing, or CLOUD / Storage Free when idle
      Text {
        text: !syncService.rcloneInstalled
          ? "rclone Not Installed"
          : (!syncService.rcloneConfigured
              ? "rclone Not Setup"
              : (syncService.active
                  ? (syncService.progressPct > 0 ? (syncService.progressPct + "%") : (syncService.speed || "SYNCING"))
                  : (syncService.authError
                      ? "GDrive ⚠ Reconnect"
                      : ("GDrive " + (syncService.storage && syncService.storage.free_formatted ? syncService.storage.free_formatted : "")))))
        color: (!syncService.rcloneInstalled || !syncService.rcloneConfigured || syncService.authError)
          ? Color.urgent
          : (syncService.active ? Color.accent : (root.bar ? root.bar.barForeground : Color.bar.text))
        font.family: root.bar ? root.bar.fontFamily : ((Style.font && Style.font.family) ? Style.font.family : "")
        font.pixelSize: 10
        font.bold: !syncService.rcloneInstalled || !syncService.rcloneConfigured || syncService.active || syncService.authError
        anchors.verticalCenter: parent.verticalCenter

        Behavior on color { ColorAnimation { duration: 150 } }
      }
    }

    MouseArea {
      id: islandMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onClicked: function(mouse) {
        if (mouse.button === Qt.RightButton) {
          if (syncService.active) {
            syncService.stopSync()
          } else {
            syncService.startSync()
          }
        } else {
          root.toggle()
        }
      }

      onWheel: function(wheel) {
        if (!root.opened) {
          root.open()
        }
        dashboard.handleWheel(wheel)
      }
    }
  }

  SyncDashboard {
    id: dashboard
    anchorItem: islandSurface
    owner: root
    bar: root.bar
    syncService: syncService
    anchorHovered: islandMouse.containsMouse
  }
}

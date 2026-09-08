import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Commons
import qs.Ui

Item {
  id: root

  property var syncService: null

  clip: true

  ColumnLayout {
    anchors.fill: parent
    spacing: Style.space(8)

    // Top Card: Master Pipeline Telemetry Overview
    Rectangle {
      Layout.fillWidth: true
      height: Style.space(74)
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)
      clip: true

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.space(10)
        spacing: Style.space(5)

        // Header: Target info & Live Bandwidth
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.space(8)

          Row {
            spacing: Style.space(6)
            Layout.alignment: Qt.AlignVCenter

            Text {
              text: (root.syncService && root.syncService.active) ? "󰓦" : "󰄬"
              color: (root.syncService && root.syncService.active) ? Color.accent : "#44cc77"
              font.family: Style.font.family
              font.pixelSize: 10
              anchors.verticalCenter: parent.verticalCenter

              RotationAnimation on rotation {
                running: root.syncService && root.syncService.active
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: 1200
              }
            }

            Text {
              text: (root.syncService && root.syncService.active)
                ? (root.syncService.message || "Syncing...")
                : "All Directories In Sync"
              color: (root.syncService && root.syncService.active) ? Color.accent : Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          Item { Layout.fillWidth: true; Layout.preferredWidth: 0 }

          // Network Speed & ETA Pill
          Rectangle {
            visible: root.syncService && root.syncService.active
            height: Style.space(20)
            width: speedPillRow.implicitWidth + Style.space(10)
            radius: Style.cornerRadius - 4
            color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.22)
            Layout.alignment: Qt.AlignVCenter

            Row {
              id: speedPillRow
              anchors.centerIn: parent
              spacing: 3

              Text {
                text: "󰓦 " + (root.syncService ? root.syncService.speed : "0 B/s")
                color: Color.accent
                font.family: Style.font.family
                font.pixelSize: Style.font.caption - 1
                font.bold: true
              }

              Text {
                text: "• ETA: " + (root.syncService ? root.syncService.etaFormatted : "0s")
                color: Color.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.caption - 1
              }
            }
          }
        }

        // Master Progress Bar
        Rectangle {
          Layout.fillWidth: true
          height: Style.space(6)
          radius: 3
          color: Qt.darker(Style.normalFillFor(Color.foreground, Color.accent), 1.6)

          Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.min(parent.width, Math.max(0, parent.width * ((root.syncService && root.syncService.active) ? ((root.syncService.progressPct || 0) / 100.0) : 1.0)))
            radius: 3
            color: (root.syncService && root.syncService.active) ? Color.accent : "#44cc77"

            Behavior on width { NumberAnimation { duration: 250 } }
          }
        }

        // Subtext details: Bytes transferred and current file
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.space(6)

          Text {
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            text: (root.syncService && root.syncService.active)
              ? ("Uploading: " + (root.syncService.currentFile || "Checking files..."))
              : "GDrive:Omarchy/ backup structure organized and ready"
            color: Qt.darker(Color.foreground, 1.6)
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
            elide: Text.ElideMiddle
          }

          Text {
            visible: root.syncService && root.syncService.active
            text: (root.syncService ? root.syncService.bytesTransferredFormatted : "0 B") + " / " + (root.syncService ? root.syncService.bytesTotalFormatted : "0 B") + " (" + (root.syncService ? root.syncService.progressPct : 0) + "%)"
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
            font.bold: true
          }
        }
      }
    }

    // Active Parallel File Transfers (Only shown when active transfers exist)
    Rectangle {
      Layout.fillWidth: true
      visible: root.syncService && root.syncService.activeTransfers && root.syncService.activeTransfers.length > 0
      height: (root.syncService && root.syncService.activeTransfers)
        ? Math.min(Style.space(120), Style.space(36) + root.syncService.activeTransfers.length * Style.space(42))
        : 0
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)
      clip: true

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.space(10)
        spacing: Style.space(6)

        RowLayout {
          Layout.fillWidth: true
          Text {
            text: "Parallel Upload Streams (" + (root.syncService && root.syncService.activeTransfers ? root.syncService.activeTransfers.length : 0) + ")"
            color: Color.foreground
            font.family: (Style.font && Style.font.family) ? Style.font.family : ""
            font.pixelSize: 11
            font.bold: true
          }
        }

        ListView {
          id: activeList
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: Style.space(4)
          model: (root.syncService && root.syncService.activeTransfers) ? root.syncService.activeTransfers : []
          clip: true

          delegate: ColumnLayout {
            width: activeList.width
            spacing: 2

            RowLayout {
              Layout.fillWidth: true
              Text {
                Layout.fillWidth: true
                Layout.preferredWidth: 0
                text: modelData.name || "File"
                color: Color.foreground
                font.family: (Style.font && Style.font.family) ? Style.font.family : ""
                font.pixelSize: 10
                elide: Text.ElideMiddle
              }
              Text {
                text: (modelData.speed || "") + " (" + (modelData.percentage || 0) + "%)"
                color: Color.accent
                font.family: (Style.font && Style.font.family) ? Style.font.family : ""
                font.pixelSize: 10
                font.bold: true
              }
            }

            Rectangle {
              Layout.fillWidth: true
              height: 4
              radius: 2
              color: Qt.darker(Style.normalFillFor(Color.foreground, Color.accent), 1.6)

              Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Math.min(parent.width, Math.max(0, parent.width * ((modelData.percentage || 0) / 100.0)))
                radius: 2
                color: Color.accent
              }
            }
          }
        }
      }
    }

    // Sync History & Event Logs Stream
    Rectangle {
      Layout.fillWidth: true
      Layout.fillHeight: true
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)
      clip: true

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.space(10)
        spacing: Style.space(6)

        RowLayout {
          Layout.fillWidth: true

          Row {
            spacing: Style.space(6)
            Layout.alignment: Qt.AlignVCenter
            Text {
              text: "󰈙"
              color: Color.accent
              font.family: Style.font.family
              font.pixelSize: 11
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: "Sync Activity & Event History"
              color: Color.foreground
              font.family: Style.font.family
              font.pixelSize: 11
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          Item { Layout.fillWidth: true }

          // Clear logs button
          Rectangle {
            width: clearText.implicitWidth + Style.space(14)
            height: Style.space(24)
            radius: Style.cornerRadius - 3
            color: clearMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : Style.selectedFillFor(Color.foreground, Color.accent)
            Layout.alignment: Qt.AlignVCenter

            Text {
              id: clearText
              anchors.centerIn: parent
              text: "Clear History"
              color: Qt.darker(Color.foreground, 1.4)
              font.family: Style.font.family
              font.pixelSize: 9
            }

            MouseArea {
              id: clearMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: if (root.syncService) root.syncService.clearLogs()
            }
          }
        }

        ListView {
          id: logsList
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: Style.space(4)
          model: root.syncService ? root.syncService.recentLogs : []
          clip: true
          boundsBehavior: Flickable.StopAtBounds

          ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AsNeeded
          }

          delegate: Rectangle {
            width: logsList.width - Style.space(6)
            height: Style.space(32)
            radius: Style.cornerRadius - 3
            color: Style.selectedFillFor(Color.foreground, Color.accent)
            clip: true

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: Style.space(8)
              anchors.rightMargin: Style.space(8)
              spacing: Style.space(8)

              // Status indicator icon
              Text {
                text: modelData.level === "error" ? "󰅙" : (modelData.level === "warning" ? "󰀦" : (modelData.level === "success" ? "󰄬" : "󰋼"))
                color: modelData.level === "error" ? Color.urgent : (modelData.level === "warning" ? "#ffaa00" : (modelData.level === "success" ? "#44cc77" : Color.accent))
                font.family: Style.font.family
                font.pixelSize: 10
                Layout.alignment: Qt.AlignVCenter
              }


              // Timestamp Badge
              Rectangle {
                height: Style.space(18)
                width: timeText.implicitWidth + Style.space(8)
                radius: 3
                color: Qt.darker(Style.selectedFillFor(Color.foreground, Color.accent), 1.3)
                Layout.alignment: Qt.AlignVCenter

                Text {
                  id: timeText
                  anchors.centerIn: parent
                  text: modelData.time_str || ""
                  color: Qt.darker(Color.foreground, 1.5)
                  font.family: (Style.font && Style.font.family) ? Style.font.family : ""
                  font.pixelSize: 8
                  font.bold: true
                }
              }

              // Event Message Text (Guaranteed width constraint)
              Text {
                Layout.fillWidth: true
                Layout.preferredWidth: 0
                Layout.alignment: Qt.AlignVCenter
                text: modelData.message || ""
                color: modelData.level === "error" ? "#ee5555" : (modelData.level === "success" ? "#44cc77" : Color.foreground)
                font.family: (Style.font && Style.font.family) ? Style.font.family : ""
                font.pixelSize: 10
                elide: Text.ElideRight
              }
            }
          }
        }
      }
    }
  }
}

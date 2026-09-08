import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui

Item {
  id: root

  property var syncService: null

  clip: true

  ColumnLayout {
    anchors.fill: parent
    spacing: Style.space(6)

    // Remote & Root Directory Section
    Rectangle {
      Layout.fillWidth: true
      height: Style.space(58)
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.space(8)
        spacing: Style.space(4)

        RowLayout {
          Layout.fillWidth: true

          Text {
            text: "󰒓 Active Remote & Root Folder"
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }

          Item { Layout.fillWidth: true }

          // Root folder badge
          Rectangle {
            height: Style.space(18)
            width: rootDirText.implicitWidth + Style.space(10)
            radius: Style.cornerRadius - 4
            color: Qt.darker(Style.selectedFillFor(Color.foreground, Color.accent), 1.2)

            Text {
              id: rootDirText
              anchors.centerIn: parent
              text: "Root: " + (root.syncService ? root.syncService.remoteRoot : "Omarchy")
              color: Color.accent
              font.family: Style.font.family
              font.pixelSize: 8
              font.bold: true
            }
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.space(6)

          Repeater {
            model: (root.syncService && root.syncService.remotes) ? root.syncService.remotes : ["GDrive"]

            Rectangle {
              height: Style.space(24)
              width: remText.implicitWidth + Style.space(14)
              radius: Style.cornerRadius - 3
              readonly property bool isSelected: root.syncService && (root.syncService.selectedRemote === modelData)
              color: isSelected
                ? Color.accent
                : (rMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : Style.selectedFillFor(Color.foreground, Color.accent))

              Text {
                id: remText
                anchors.centerIn: parent
                text: "󰅟 " + modelData
                color: isSelected ? Color.menu.background : Color.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: isSelected
              }

              MouseArea {
                id: rMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.syncService) root.syncService.setRemote(modelData)
              }
            }
          }

          Item { Layout.fillWidth: true }
        }
      }
    }

    // Auto-Sync Scheduling
    Rectangle {
      Layout.fillWidth: true
      height: Style.space(58)
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.space(8)
        spacing: Style.space(4)

        Text {
          text: "⏰ Auto-Sync Schedule"
          color: Color.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          font.bold: true
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.space(5)

          Repeater {
            model: [
              { label: "Manual", hours: 0 },
              { label: "Every 1 hr", hours: 1 },
              { label: "Every 3 hrs", hours: 3 },
              { label: "Every 6 hrs", hours: 6 }
            ]

            Rectangle {
              height: Style.space(24)
              width: schedText.implicitWidth + Style.space(12)
              radius: Style.cornerRadius - 3
              readonly property bool isSelected: root.syncService && (root.syncService.autoSyncIntervalHours === modelData.hours)
              color: isSelected
                ? Color.accent
                : (sMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : Style.selectedFillFor(Color.foreground, Color.accent))

              Text {
                id: schedText
                anchors.centerIn: parent
                text: modelData.label
                color: isSelected ? Color.menu.background : Color.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: isSelected
              }

              MouseArea {
                id: sMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.syncService) root.syncService.setSchedule(modelData.hours)
              }
            }
          }

          Item { Layout.fillWidth: true }
        }
      }
    }

    // Parallel Upload Concurrency Streams (Turbo Acceleration)
    Rectangle {
      Layout.fillWidth: true
      height: Style.space(58)
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.space(8)
        spacing: Style.space(4)

        RowLayout {
          Layout.fillWidth: true
          Text {
            text: "󰓦 Concurrency Streams"
            color: Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
          Item { Layout.fillWidth: true }
          Text {
            text: (root.syncService ? root.syncService.transfers : 16) + " Streams"
            color: Color.accent
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
            font.bold: true
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.space(5)

          Repeater {
            model: [
              { label: "4", count: 4 },
              { label: "8", count: 8 },
              { label: "16 (Fast)", count: 16 },
              { label: "32 (Turbo)", count: 32 }
            ]

            Rectangle {
              height: Style.space(24)
              width: transText.implicitWidth + Style.space(14)
              radius: Style.cornerRadius - 3
              readonly property bool isSelected: root.syncService && (root.syncService.transfers === modelData.count)
              color: isSelected
                ? Color.accent
                : (tMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : Style.selectedFillFor(Color.foreground, Color.accent))

              Text {
                id: transText
                anchors.centerIn: parent
                text: modelData.label
                color: isSelected ? Color.menu.background : Color.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: isSelected
              }

              MouseArea {
                id: tMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.syncService) root.syncService.setTransfers(modelData.count)
              }
            }
          }

          Item { Layout.fillWidth: true }
        }
      }
    }

    // Exclude Rules & Sync Parameters
    Rectangle {
      Layout.fillWidth: true
      Layout.fillHeight: true
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)
      clip: true

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.space(8)
        spacing: Style.space(4)

        Text {
          text: "󰞌 Excluded Filter Patterns"
          color: Color.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          font.bold: true
        }

        Flow {
          Layout.fillWidth: true
          spacing: Style.space(5)

          Repeater {
            model: (root.syncService && root.syncService.excludePatterns) ? root.syncService.excludePatterns : [".git/**", "node_modules/**", "target/**", "*.cache/**"]

            Rectangle {
              height: Style.space(20)
              width: excText.implicitWidth + Style.space(12)
              radius: Style.cornerRadius - 4
              color: Style.selectedFillFor(Color.foreground, Color.accent)

              Text {
                id: excText
                anchors.centerIn: parent
                text: modelData
                color: Qt.darker(Color.foreground, 1.4)
                font.family: Style.font.family
                font.pixelSize: 8
              }
            }
          }
        }

        Item { Layout.fillHeight: true }

        // System information strip (Zero overflow)
        RowLayout {
          Layout.fillWidth: true

          Text {
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            text: "Transfers: " + (root.syncService ? root.syncService.transfers : 16) + " • Pacer: 10ms Turbo • Engine: Rclone v1.70.2"
            color: Qt.darker(Color.foreground, 1.8)
            font.family: Style.font.family
            font.pixelSize: 8
            elide: Text.ElideRight
          }
        }
      }
    }
  }
}

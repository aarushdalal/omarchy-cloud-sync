import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Ui

Item {
  id: root

  property var syncService: null
  property var dashboard: null

  clip: true

  ColumnLayout {
    anchors.fill: parent
    spacing: Style.space(8)

    // Action Header Bar (Browse & Add)
    Rectangle {
      Layout.fillWidth: true
      height: Style.space(38)
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)
      clip: true

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Style.space(12)
        anchors.rightMargin: Style.space(12)
        spacing: Style.space(8)

        // Title & Count
        ColumnLayout {
          Layout.fillWidth: true
          Layout.preferredWidth: 0
          spacing: 1

          Row {
            spacing: Style.space(6)
            Text {
              text: "󰉋"
              color: Color.accent
              font.family: Style.font.family
              font.pixelSize: 11
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: "Synced Directories"
              color: Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          Text {
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            text: (root.syncService && root.syncService.folders)
              ? (root.syncService.folders.length + " configured sync paths")
              : "0 paths configured"
            color: Qt.darker(Color.foreground, 1.8)
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
            elide: Text.ElideRight
          }
        }

        // System Dialog Button
        Rectangle {
          height: Style.space(24)
          width: sysDlgText.implicitWidth + Style.space(10)
          radius: Style.cornerRadius - 3
          color: sysDlgMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : Style.selectedFillFor(Color.foreground, Color.accent)

          Row {
            id: sysDlgText
            anchors.centerIn: parent
            spacing: 3
            Text {
              text: "󰍹"
              color: Color.accent
              font.family: Style.font.family
              font.pixelSize: 10
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: "Picker"
              color: Color.accent
              font.family: Style.font.family
              font.pixelSize: 9
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          MouseArea {
            id: sysDlgMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (root.syncService) root.syncService.pickFolder()
            }
          }
        }

        // Primary Browse & Add Button
        Rectangle {
          height: Style.space(24)
          width: browseBtnText.implicitWidth + Style.space(12)
          radius: Style.cornerRadius - 3
          color: browseBtnMouse.containsMouse ? Style.selectedFillFor(Color.foreground, Color.accent) : Color.accent
          scale: browseBtnMouse.pressed ? 0.96 : 1.0

          Behavior on scale { NumberAnimation { duration: 100 } }
          Behavior on color { ColorAnimation { duration: 150 } }

          Row {
            id: browseBtnText
            anchors.centerIn: parent
            spacing: 3

            Text {
              text: "󰐕"
              color: Color.menu.background
              font.family: Style.font.family
              font.pixelSize: 10
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              text: "Add Folder"
              color: Color.menu.background
              font.family: Style.font.family
              font.pixelSize: 9
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          MouseArea {
            id: browseBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (root.dashboard) {
                root.dashboard.openFolderBrowser(Quickshell.env("HOME"))
              } else if (root.syncService) {
                root.syncService.pickFolder()
              }
            }
          }
        }
      }
    }

    // Quick Add Presets Bar
    RowLayout {
      Layout.fillWidth: true
      spacing: Style.space(6)

      Text {
        text: "Quick Add:"
        color: Qt.darker(Color.foreground, 1.8)
        font.family: (Style.font && Style.font.family) ? Style.font.family : ""
        font.pixelSize: 10
      }

      Repeater {
        model: [
          { name: "Documents", path: Quickshell.env("HOME") + "/Documents" },
          { name: "Pictures", path: Quickshell.env("HOME") + "/Pictures" },
          { name: "Downloads", path: Quickshell.env("HOME") + "/Downloads" },
          { name: "Notes", path: Quickshell.env("HOME") + "/Notes" }
        ]

        Rectangle {
          height: Style.space(22)
          width: presetText.implicitWidth + Style.space(14)
          radius: Style.cornerRadius - 3
          color: presetMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : Style.normalFillFor(Color.foreground, Color.accent)

          Row {
            id: presetText
            anchors.centerIn: parent
            spacing: 3
            Text { text: "+"; color: Color.accent; font.pixelSize: 9; font.bold: true }
            Text {
              text: modelData.name
              color: Color.foreground
              font.family: (Style.font && Style.font.family) ? Style.font.family : ""
              font.pixelSize: 9
            }
          }

          MouseArea {
            id: presetMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (root.syncService) {
                root.syncService.addFolder(modelData.path)
              }
            }
          }
        }
      }

      Item { Layout.fillWidth: true }
    }

    // Synced Folders Scrollable List
    Rectangle {
      Layout.fillWidth: true
      Layout.fillHeight: true
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)
      clip: true

      ListView {
        id: foldersList
        anchors.fill: parent
        anchors.margins: Style.space(6)
        spacing: Style.space(5)
        model: root.syncService ? root.syncService.folders : []
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
          active: true
          policy: ScrollBar.AsNeeded
        }

        delegate: Rectangle {
          width: foldersList.width - Style.space(6)
          height: Style.space(42)
          radius: Style.cornerRadius - 2
          color: itemMouse.containsMouse
            ? Style.hoverFillFor(Color.foreground, Color.accent)
            : Style.selectedFillFor(Color.foreground, Color.accent)
          clip: true

          Behavior on color { ColorAnimation { duration: 150 } }

          MouseArea {
            id: itemMouse
            anchors.fill: parent
            hoverEnabled: true
          }

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Style.space(8)
            anchors.rightMargin: Style.space(8)
            spacing: Style.space(8)

            // Category Icon
            Text {
              text: modelData.category === "antigravity" ? "󰚩" : (modelData.category === "system" ? "󰒓" : (modelData.category === "dotfiles" ? "󰈙" : (modelData.category === "media" ? "󰋩" : (modelData.category === "workspace" ? "󰆧" : "󰉋"))))
              color: Color.accent
              font.family: Style.font.family
              font.pixelSize: 10
              Layout.alignment: Qt.AlignVCenter
            }

            // Path & Details (Strictly Width-Constrained)
            ColumnLayout {
              Layout.fillWidth: true
              Layout.preferredWidth: 0
              Layout.alignment: Qt.AlignVCenter
              spacing: 1

              RowLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 0
                spacing: Style.space(4)

                Text {
                  Layout.fillWidth: true
                  Layout.preferredWidth: 0
                  text: modelData.name || modelData.path
                  color: modelData.enabled ? Color.foreground : Qt.darker(Color.foreground, 1.8)
                  font.family: Style.font.family
                  font.pixelSize: 10
                  font.bold: true
                  elide: Text.ElideRight
                }

                // Category pill
                Rectangle {
                  height: Style.space(14)
                  width: catText.implicitWidth + Style.space(8)
                  radius: Style.cornerRadius - 4
                  color: Qt.darker(Style.selectedFillFor(Color.foreground, Color.accent), 1.2)

                  Text {
                    id: catText
                    anchors.centerIn: parent
                    text: modelData.remote_subpath || "backup"
                    color: Color.accent
                    font.family: Style.font.family
                    font.pixelSize: 8
                    font.bold: true
                  }
                }
              }

              Text {
                Layout.fillWidth: true
                Layout.preferredWidth: 0
                text: (modelData.path === "system" ? "System manifests" : modelData.path) + " 󰁔 Omarchy/" + (modelData.remote_subpath || "backup")
                color: Qt.darker(Color.foreground, 1.8)
                font.family: Style.font.family
                font.pixelSize: 9
                elide: Text.ElideMiddle
              }
            }

            // Enable / Disable Toggle Switch
            Rectangle {
              width: Style.space(32)
              height: Style.space(18)
              radius: 9
              color: modelData.enabled ? Color.accent : Qt.darker(Color.foreground, 2.5)
              Layout.alignment: Qt.AlignVCenter

              Behavior on color { ColorAnimation { duration: 200 } }

              Rectangle {
                y: 2
                x: modelData.enabled ? parent.width - 20 : 2
                width: 18
                height: 18
                radius: 9
                color: "#ffffff"

                Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  if (root.syncService) root.syncService.toggleFolder(modelData.id || modelData.path)
                }
              }
            }

            // Delete Button (only for custom folders)
            Rectangle {
              visible: modelData.id && modelData.id.indexOf("custom_") === 0
              width: Style.space(26)
              height: Style.space(26)
              radius: Style.cornerRadius - 2
              color: delMouse.containsMouse ? Color.urgent : "transparent"
              Layout.alignment: Qt.AlignVCenter

              Text {
                anchors.centerIn: parent
                text: "󰆴"
                color: delMouse.containsMouse ? "#ffffff" : Color.urgent
                font.family: Style.font.family
                font.pixelSize: 12
              }

              MouseArea {
                id: delMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  if (root.syncService) root.syncService.removeFolder(modelData.id || modelData.path)
                }
              }
            }

          }
        }
      }
    }
  }
}

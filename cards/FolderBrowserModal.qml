import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Rectangle {
  id: root

  property var syncService: null
  property bool isOpen: false
  property string currentPath: Quickshell.env("HOME")
  property string parentPath: ""
  property var breadcrumbs: []
  property var rawDirectories: []
  property string searchFilter: ""
  property bool isLoading: false

  signal folderSelected(string path)

  visible: opacity > 0.001
  opacity: isOpen ? 1.0 : 0.0
  color: Qt.rgba(0, 0, 0, 0.78)
  anchors.fill: parent
  z: 300

  Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

  // Prevent clicks from penetrating through backdrop
  MouseArea {
    anchors.fill: parent
    onClicked: root.close()
  }

  function open(startPath) {
    searchFilter = ""
    try {
      if (typeof filterInput !== "undefined" && filterInput) {
        filterInput.text = ""
      }
    } catch(e) {}
    var p = startPath || Quickshell.env("HOME")
    navigateTo(p)
    isOpen = true
  }

  function close() {
    isOpen = false
  }

  function navigateTo(pathStr) {
    if (!pathStr || pathStr.trim() === "") pathStr = Quickshell.env("HOME")
    currentPath = pathStr
    isLoading = true
    browseProc.running = false
    browseProc.command = [
      Quickshell.env("HOME") + "/.config/omarchy/plugins/daemon0.cloud-sync/services/sync-helper.sh",
      "list-dirs",
      pathStr
    ]
    browseProc.running = true
  }

  Process {
    id: browseProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.isLoading = false
        if (!text || text.trim() === "") return
        try {
          var data = JSON.parse(text.trim())
          root.currentPath = data.current_path || root.currentPath
          root.parentPath = data.parent_path || ""
          root.breadcrumbs = data.breadcrumbs || []
          root.rawDirectories = data.directories || []
        } catch (e) {
          // ignore parse error
        }
      }
    }
  }

  readonly property var filteredDirectories: {
    if (!rawDirectories) return []
    if (!searchFilter || searchFilter.trim() === "") return rawDirectories
    var q = searchFilter.toLowerCase().trim()
    return rawDirectories.filter(function(item) {
      return item.name && item.name.toLowerCase().indexOf(q) !== -1
    })
  }

  // Modal Container Box
  Rectangle {
    id: modalBox
    anchors.centerIn: parent
    width: parent.width - Style.space(20)
    height: parent.height - Style.space(20)
    radius: Style.cornerRadius + 2
    color: Style.selectedFillFor(Color.foreground, Color.accent)
    border.width: 1
    border.color: Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.2)
    clip: true

    scale: root.isOpen ? 1.0 : 0.94
    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    MouseArea {
      anchors.fill: parent
      onClicked: {}
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.space(12)
      spacing: Style.space(6)

      // Header Row
      RowLayout {
        Layout.fillWidth: true

        Row {
          spacing: Style.space(6)
          Text {
            text: "󰉋"
            color: Color.accent
            font.family: (Style.font && Style.font.family) ? Style.font.family : ""
            font.pixelSize: 15
            anchors.verticalCenter: parent.verticalCenter
          }
          Text {
            text: "Select Folder to Sync"
            color: Color.foreground
            font.family: (Style.font && Style.font.family) ? Style.font.family : ""
            font.pixelSize: 12
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        Item { Layout.fillWidth: true }

        // System Dialog Trigger Button
        Rectangle {
          height: Style.space(26)
          width: sysDlgText.implicitWidth + Style.space(14)
          radius: Style.cornerRadius - 2
          color: sysDlgMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : Style.normalFillFor(Color.foreground, Color.accent)

          Row {
            id: sysDlgText
            anchors.centerIn: parent
            spacing: 4
            Text {
              text: "󰍹"
              color: Color.accent
              font.family: (Style.font && Style.font.family) ? Style.font.family : ""
              font.pixelSize: 11
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: "System Dialog"
              color: Color.accent
              font.family: (Style.font && Style.font.family) ? Style.font.family : ""
              font.pixelSize: 10
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
              root.close()
            }
          }
        }

        // Close Button
        Rectangle {
          width: Style.space(26)
          height: Style.space(26)
          radius: Style.cornerRadius - 2
          color: closeMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : "transparent"

          Text {
            anchors.centerIn: parent
            text: "󰅖"
            color: Color.foreground
            font.family: (Style.font && Style.font.family) ? Style.font.family : ""
            font.pixelSize: 11
            font.bold: true
          }

          MouseArea {
            id: closeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.close()
          }
        }
      }

      // Quick Jump Bar
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.space(4)

        Repeater {
          model: [
            { icon: "󰋜", label: "Home", path: Quickshell.env("HOME") },
            { icon: "󰈙", label: "Work", path: Quickshell.env("HOME") + "/Work" },
            { icon: "󰉋", label: "Docs", path: Quickshell.env("HOME") + "/Documents" },
            { icon: "󰋩", label: "Pics", path: Quickshell.env("HOME") + "/Pictures" },
            { icon: "󰇚", label: "Downloads", path: Quickshell.env("HOME") + "/Downloads" },
            { icon: "󰒓", label: "Config", path: Quickshell.env("HOME") + "/.config" },
            { icon: "󱚝", label: "Gemini", path: Quickshell.env("HOME") + "/.gemini" }
          ]

          Rectangle {
            height: Style.space(22)
            width: qText.implicitWidth + Style.space(12)
            radius: Style.cornerRadius - 3
            readonly property bool isCurrent: root.currentPath === modelData.path
            color: isCurrent
              ? Color.accent
              : (qMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : Style.normalFillFor(Color.foreground, Color.accent))

            Row {
              id: qText
              anchors.centerIn: parent
              spacing: 4

              Text {
                text: modelData.icon
                color: isCurrent ? (Style.isLight ? "#ffffff" : "#000000") : Color.accent
                font.family: (Style.font && Style.font.family) ? Style.font.family : ""
                font.pixelSize: 10
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                text: modelData.label
                color: isCurrent ? (Style.isLight ? "#ffffff" : "#000000") : Color.foreground
                font.family: (Style.font && Style.font.family) ? Style.font.family : ""
                font.pixelSize: 9
                font.bold: isCurrent
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            MouseArea {
              id: qMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.navigateTo(modelData.path)
            }
          }
        }

        Item { Layout.fillWidth: true }
      }

      // Breadcrumb Navigation & Up Button
      Rectangle {
        Layout.fillWidth: true
        height: Style.space(34)
        radius: Style.cornerRadius - 2
        color: Style.normalFillFor(Color.foreground, Color.accent)

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: Style.space(6)
          anchors.rightMargin: Style.space(6)
          spacing: Style.space(4)

          // Up Directory Button
          Rectangle {
            width: Style.space(26)
            height: Style.space(26)
            radius: Style.cornerRadius - 3
            enabled: root.parentPath !== "" && root.parentPath !== root.currentPath
            color: upMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : Style.selectedFillFor(Color.foreground, Color.accent)
            opacity: enabled ? 1.0 : 0.4

            Text {
              anchors.centerIn: parent
              text: "⬆️"
              font.pixelSize: 10
            }

            MouseArea {
              id: upMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
              onClicked: if (parent.enabled) root.navigateTo(root.parentPath)
            }
          }

          // Breadcrumb Trail Scroll
          Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: bcRow.implicitWidth
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            Row {
              id: bcRow
              anchors.verticalCenter: parent.verticalCenter
              spacing: 3

              Repeater {
                model: root.breadcrumbs

                Row {
                  spacing: 3

                  Rectangle {
                    height: Style.space(22)
                    width: bText.implicitWidth + Style.space(10)
                    radius: Style.cornerRadius - 4
                    readonly property bool isLast: index === root.breadcrumbs.length - 1
                    color: isLast
                      ? Style.hoverFillFor(Color.foreground, Color.accent)
                      : (bMouse.containsMouse ? Style.selectedFillFor(Color.foreground, Color.accent) : "transparent")

                    Text {
                      id: bText
                      anchors.centerIn: parent
                      text: modelData.name || ""
                      color: isLast ? Color.accent : Color.foreground
                      font.family: (Style.font && Style.font.family) ? Style.font.family : ""
                      font.pixelSize: 10
                      font.bold: isLast
                    }

                    MouseArea {
                      id: bMouse
                      anchors.fill: parent
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor
                      onClicked: root.navigateTo(modelData.path)
                    }
                  }

                  Text {
                    visible: index < root.breadcrumbs.length - 1
                    text: "/"
                    color: Qt.darker(Color.foreground, 2.2)
                    font.pixelSize: 10
                    anchors.verticalCenter: parent.verticalCenter
                  }
                }
              }
            }
          }
        }
      }

      // Live Search Filter Input
      Rectangle {
        Layout.fillWidth: true
        height: Style.space(28)
        radius: Style.cornerRadius - 2
        color: Style.normalFillFor(Color.foreground, Color.accent)

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: Style.space(8)
          anchors.rightMargin: Style.space(8)
          spacing: Style.space(6)

          Text {
            text: "󰍉"
            color: Color.accent
            font.family: (Style.font && Style.font.family) ? Style.font.family : ""
            font.pixelSize: 12
          }

          TextInput {
            id: filterInput
            Layout.fillWidth: true
            verticalAlignment: TextInput.AlignVCenter
            color: Color.foreground
            font.family: (Style.font && Style.font.family) ? Style.font.family : ""
            font.pixelSize: 10
            selectByMouse: true
            clip: true

            Text {
              anchors.fill: parent
              verticalAlignment: Text.AlignVCenter
              text: "Filter subfolders..."
              color: Qt.darker(Color.foreground, 2.0)
              font.family: (Style.font && Style.font.family) ? Style.font.family : ""
              font.pixelSize: 10
              visible: !filterInput.text && !filterInput.activeFocus
            }

            onTextChanged: {
              root.searchFilter = filterInput.text
            }
          }
        }
      }

      // Subdirectories ListView
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: Style.cornerRadius - 2
        color: Style.normalFillFor(Color.foreground, Color.accent)
        clip: true

        ListView {
          id: dirList
          anchors.fill: parent
          anchors.margins: Style.space(4)
          spacing: 2
          model: root.filteredDirectories

          ScrollBar.vertical: ScrollBar {
            active: true
            policy: ScrollBar.AsNeeded
          }

          delegate: Rectangle {
            width: dirList.width - Style.space(8)
            height: Style.space(34)
            radius: Style.cornerRadius - 3
            color: dMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : "transparent"

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: Style.space(8)
              anchors.rightMargin: Style.space(8)
              spacing: Style.space(6)

              Text {
                text: "󰉋"
                color: Color.accent
                font.family: (Style.font && Style.font.family) ? Style.font.family : ""
                font.pixelSize: 13
              }

              Text {
                Layout.fillWidth: true
                text: modelData.name || ""
                color: Color.foreground
                font.family: (Style.font && Style.font.family) ? Style.font.family : ""
                font.pixelSize: 11
                elide: Text.ElideRight
              }

              Text {
                text: "›"
                color: Qt.darker(Color.foreground, 2.0)
                font.family: (Style.font && Style.font.family) ? Style.font.family : ""
                font.pixelSize: 14
              }
            }

            MouseArea {
              id: dMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.navigateTo(modelData.path)
                filterInput.text = ""
                root.searchFilter = ""
              }
            }
          }

          // Empty state indicator
          Text {
            anchors.centerIn: parent
            visible: !root.isLoading && root.filteredDirectories.length === 0
            text: (root.searchFilter !== "") ? "No matching folders found" : "No subfolders in this directory"
            color: Qt.darker(Color.foreground, 2.0)
            font.family: (Style.font && Style.font.family) ? Style.font.family : ""
            font.pixelSize: 10
          }
        }
      }

      // Bottom Footer Bar (Selected Path & Confirm Action)
      Rectangle {
        Layout.fillWidth: true
        height: Style.space(44)
        radius: Style.cornerRadius - 2
        color: Style.normalFillFor(Color.foreground, Color.accent)

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: Style.space(10)
          anchors.rightMargin: Style.space(10)
          spacing: Style.space(8)

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
              text: "Selected Path:"
              color: Qt.darker(Color.foreground, 1.8)
              font.family: (Style.font && Style.font.family) ? Style.font.family : ""
              font.pixelSize: 8
            }

            Text {
              Layout.fillWidth: true
              text: root.currentPath
              color: Color.accent
              font.family: (Style.font && Style.font.family) ? Style.font.family : ""
              font.pixelSize: 10
              font.bold: true
              elide: Text.ElideMiddle
            }
          }

          // Cancel Button
          Rectangle {
            width: Style.space(64)
            height: Style.space(30)
            radius: Style.cornerRadius - 3
            color: cancelMouse.containsMouse ? Style.hoverFillFor(Color.foreground, Color.accent) : Style.selectedFillFor(Color.foreground, Color.accent)

            Text {
              anchors.centerIn: parent
              text: "Cancel"
              color: Color.foreground
              font.family: (Style.font && Style.font.family) ? Style.font.family : ""
              font.pixelSize: 10
            }

            MouseArea {
              id: cancelMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.close()
            }
          }

          // Select Folder Button
          Rectangle {
            width: Style.space(136)
            height: Style.space(30)
            radius: Style.cornerRadius - 3
            color: selMouse.containsMouse ? Style.selectedFillFor(Color.foreground, Color.accent) : Color.accent
            scale: selMouse.pressed ? 0.96 : 1.0

            Behavior on scale { NumberAnimation { duration: 100 } }
            Behavior on color { ColorAnimation { duration: 150 } }

            Row {
              anchors.centerIn: parent
              spacing: 4

              Text {
                text: "󰄬"
                color: Style.isLight ? "#ffffff" : "#000000"
                font.family: (Style.font && Style.font.family) ? Style.font.family : ""
                font.pixelSize: 11
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                text: "Select This Folder"
                color: Style.isLight ? "#ffffff" : "#000000"
                font.family: (Style.font && Style.font.family) ? Style.font.family : ""
                font.pixelSize: 10
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            MouseArea {
              id: selMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (root.syncService && root.currentPath) {
                  root.syncService.addFolder(root.currentPath)
                  root.close()
                }
              }
            }
          }
        }
      }
    }
  }
}

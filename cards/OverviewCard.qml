import QtQuick
import QtQuick.Layouts
import qs.Commons as OmarchyPalette
import qs.Commons
import qs.Ui

Item {
  id: root

  property var syncService: null

  ColumnLayout {
    anchors.fill: parent
    spacing: Style.space(10)

    // 1. Top Header Strip: Remote Info & Mount Pill (Matching Omni/Focus style)
    Rectangle {
      Layout.fillWidth: true
      height: Style.space(34)
      radius: Style.cornerRadius
      color: Style.normalFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

      RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Style.space(12)
        anchors.rightMargin: Style.space(12)

        Row {
          spacing: Style.space(6)
          Layout.alignment: Qt.AlignVCenter

          Text {
            text: "󰅟"
            color: OmarchyPalette.Color.accent
            font.family: Style.font.family
            font.pixelSize: 10
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: root.syncService ? root.syncService.remoteFullPath : "GDrive:Omarchy/"
            color: OmarchyPalette.Color.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: "•"
            color: Qt.darker(OmarchyPalette.Color.foreground, 2.0)
            font.family: Style.font.family
            font.pixelSize: 10
            anchors.verticalCenter: parent.verticalCenter
          }

          Text {
            text: (root.syncService && !root.syncService.rcloneInstalled)
              ? "NOT INSTALLED"
              : ((root.syncService && !root.syncService.rcloneConfigured)
                ? "NOT CONFIGURED"
                : ((root.syncService && root.syncService.authError)
                  ? "AUTH EXPIRED"
                  : ((root.syncService && root.syncService.mounted) ? "MOUNTED" : "UNMOUNTED")))
            color: (root.syncService && (!root.syncService.rcloneInstalled || root.syncService.authError))
              ? OmarchyPalette.Color.urgent
              : ((root.syncService && !root.syncService.rcloneConfigured)
                ? OmarchyPalette.Color.accent
                : ((root.syncService && root.syncService.mounted) ? "#44cc77" : Qt.darker(OmarchyPalette.Color.foreground, 1.8)))
            font.family: Style.font.family
            font.pixelSize: Style.font.caption - 1
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        Item { Layout.fillWidth: true }

        // Live Sync State Badge
        Rectangle {
          radius: Style.cornerRadius - 3
          height: Style.space(22)
          width: statusRow.implicitWidth + Style.space(12)
          color: (root.syncService && root.syncService.active)
            ? Qt.rgba(OmarchyPalette.Color.accent.r, OmarchyPalette.Color.accent.g, OmarchyPalette.Color.accent.b, 0.25)
            : Style.selectedFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

          Row {
            id: statusRow
            anchors.centerIn: parent
            spacing: Style.space(4)

            Rectangle {
              width: 6
              height: 6
              radius: 3
              color: (root.syncService && root.syncService.active)
                ? OmarchyPalette.Color.accent
                : ((root.syncService && (!root.syncService.rcloneInstalled || root.syncService.status === "error"))
                  ? OmarchyPalette.Color.urgent
                  : ((root.syncService && !root.syncService.rcloneConfigured) ? OmarchyPalette.Color.accent : "#44cc77"))
              anchors.verticalCenter: parent.verticalCenter

              SequentialAnimation on opacity {
                running: root.visible && root.enabled && !Motion.reducedMotion && root.syncService && root.syncService.active
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.2; duration: 500 }
                NumberAnimation { from: 0.2; to: 1.0; duration: 500 }
              }
            }

            Text {
              text: (root.syncService && !root.syncService.rcloneInstalled)
                ? "NOT INSTALLED"
                : ((root.syncService && !root.syncService.rcloneConfigured)
                  ? "NOT SETUP"
                  : ((root.syncService && root.syncService.active)
                    ? ("SYNCING " + (root.syncService.speed !== "0 B/s" ? ("• " + root.syncService.speed) : ""))
                    : ((root.syncService && root.syncService.status === "error") ? "ERROR" : "IDLE")))
              color: (root.syncService && !root.syncService.rcloneInstalled)
                ? OmarchyPalette.Color.urgent
                : ((root.syncService && !root.syncService.rcloneConfigured)
                  ? OmarchyPalette.Color.accent
                  : ((root.syncService && root.syncService.active) ? OmarchyPalette.Color.accent : OmarchyPalette.Color.foreground))
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }
        }
      }
    }

    // 2. Center Hero Card: Cloud Storage & Quota (Styled like Focus/Omni Storage section)
    Rectangle {
      Layout.fillWidth: true
      Layout.fillHeight: true
      radius: Style.cornerRadius
      color: Style.normalFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.space(12)
        spacing: Style.space(8)

        // Hero Header Row
        RowLayout {
          Layout.fillWidth: true

          Row {
            spacing: Style.space(6)
            Layout.alignment: Qt.AlignVCenter

            Text {
              text: "󰋊"
              color: OmarchyPalette.Color.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.body
              anchors.verticalCenter: parent.verticalCenter
            }

            ColumnLayout {
              spacing: 1
              Text {
                text: "Google Drive Storage"
                color: OmarchyPalette.Color.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                font.bold: true
              }
              Text {
                text: "Target: GDrive:Omarchy/ • Unified Archiving"
                color: Qt.darker(OmarchyPalette.Color.foreground, 1.6)
                font.family: Style.font.family
                font.pixelSize: Style.font.caption - 1
              }
            }
          }

          Item { Layout.fillWidth: true }

          // Refresh Quota Button
          Rectangle {
            width: Style.space(24)
            height: Style.space(24)
            radius: Style.cornerRadius - 3
            color: refreshMouse.containsMouse ? Style.hoverFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent) : Style.selectedFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

            Text {
              anchors.centerIn: parent
              text: "󰑐"
              color: refreshMouse.containsMouse ? OmarchyPalette.Color.accent : OmarchyPalette.Color.foreground
              font.family: Style.font.family
              font.pixelSize: 10
            }

            MouseArea {
              id: refreshMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: if (root.syncService) root.syncService.refreshQuota()
            }
          }
        }

        // Rclone Not Installed Banner
        Rectangle {
          Layout.fillWidth: true
          visible: root.syncService && !root.syncService.rcloneInstalled
          height: Style.space(32)
          radius: Style.cornerRadius - 2
          color: Qt.rgba(OmarchyPalette.Color.urgent.r, OmarchyPalette.Color.urgent.g, OmarchyPalette.Color.urgent.b, 0.15)
          border.color: OmarchyPalette.Color.urgent
          border.width: 1

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Style.space(8)
            anchors.rightMargin: Style.space(8)
            spacing: Style.space(6)

            Text {
              text: "󰅚"
              color: OmarchyPalette.Color.urgent
              font.family: Style.font.family
              font.pixelSize: 11
            }

            Text {
              Layout.fillWidth: true
              text: "rclone is not installed. Please install it to use Cloud Sync."
              color: OmarchyPalette.Color.urgent
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
              font.bold: true
              elide: Text.ElideRight
            }

            Rectangle {
              height: Style.space(22)
              width: installBtnText.implicitWidth + Style.space(14)
              radius: Style.cornerRadius - 4
              color: OmarchyPalette.Color.urgent

              Text {
                id: installBtnText
                anchors.centerIn: parent
                text: "Install rclone"
                color: "#ffffff"
                font.family: Style.font.family
                font.pixelSize: Style.font.caption - 1
                font.bold: true
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.syncService) root.syncService.installRclone()
              }
            }
          }
        }

        // Rclone Not Configured Banner
        Rectangle {
          Layout.fillWidth: true
          visible: root.syncService && root.syncService.rcloneInstalled && !root.syncService.rcloneConfigured
          height: Style.space(32)
          radius: Style.cornerRadius - 2
          color: Qt.rgba(OmarchyPalette.Color.accent.r, OmarchyPalette.Color.accent.g, OmarchyPalette.Color.accent.b, 0.15)
          border.color: OmarchyPalette.Color.accent
          border.width: 1

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Style.space(8)
            anchors.rightMargin: Style.space(8)
            spacing: Style.space(6)

            Text {
              text: "󰒲"
              color: OmarchyPalette.Color.accent
              font.family: Style.font.family
              font.pixelSize: 11
            }

            Text {
              Layout.fillWidth: true
              text: "No rclone remotes found. Configure a remote (e.g. GDrive) to sync."
              color: OmarchyPalette.Color.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
              font.bold: true
              elide: Text.ElideRight
            }

            Rectangle {
              height: Style.space(22)
              width: setupBtnText.implicitWidth + Style.space(14)
              radius: Style.cornerRadius - 4
              color: OmarchyPalette.Color.accent

              Text {
                id: setupBtnText
                anchors.centerIn: parent
                text: "Setup rclone"
                color: OmarchyPalette.Color.menu.background
                font.family: Style.font.family
                font.pixelSize: Style.font.caption - 1
                font.bold: true
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.syncService) root.syncService.configRclone()
              }
            }
          }
        }

        // Auth Expired Banner
        Rectangle {
          Layout.fillWidth: true
          visible: root.syncService && root.syncService.rcloneInstalled && root.syncService.rcloneConfigured && root.syncService.authError
          height: Style.space(32)
          radius: Style.cornerRadius - 2
          color: Qt.rgba(OmarchyPalette.Color.urgent.r, OmarchyPalette.Color.urgent.g, OmarchyPalette.Color.urgent.b, 0.15)
          border.color: OmarchyPalette.Color.urgent
          border.width: 1

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Style.space(8)
            anchors.rightMargin: Style.space(8)
            spacing: Style.space(6)

            Text {
              text: "󰅟"
              color: OmarchyPalette.Color.urgent
              font.family: Style.font.family
              font.pixelSize: 11
            }

            Text {
              Layout.fillWidth: true
              text: "Google Drive OAuth token expired. Reconnect to restore access."
              color: OmarchyPalette.Color.urgent
              font.family: Style.font.family
              font.pixelSize: Style.font.caption - 1
              font.bold: true
              elide: Text.ElideRight
            }

            Rectangle {
              height: Style.space(22)
              width: reauthText.implicitWidth + Style.space(14)
              radius: Style.cornerRadius - 4
              color: OmarchyPalette.Color.urgent

              Text {
                id: reauthText
                anchors.centerIn: parent
                text: "Reconnect"
                color: "#ffffff"
                font.family: Style.font.family
                font.pixelSize: Style.font.caption - 1
                font.bold: true
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.syncService) root.syncService.reconnect()
              }
            }
          }
        }

        // Hero Quota Metric Section (Compact & Proportional)
        ColumnLayout {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignHCenter
          spacing: Style.space(5)

          Text {
            Layout.alignment: Qt.AlignHCenter
            text: (root.syncService && !root.syncService.rcloneInstalled)
              ? "rclone Not Installed"
              : ((root.syncService && !root.syncService.rcloneConfigured)
                ? "No Remotes Configured"
                : ((root.syncService && root.syncService.storage && root.syncService.storage.used_formatted)
                  ? (root.syncService.storage.used_formatted + " / " + root.syncService.storage.total_formatted)
                  : "-- / --"))
            color: (root.syncService && !root.syncService.rcloneInstalled)
              ? OmarchyPalette.Color.urgent
              : ((root.syncService && !root.syncService.rcloneConfigured)
                ? OmarchyPalette.Color.accent
                : ((root.syncService && root.syncService.active) ? OmarchyPalette.Color.accent : OmarchyPalette.Color.foreground))
            font.family: Style.font.family
            font.pixelSize: (root.syncService && (!root.syncService.rcloneInstalled || !root.syncService.rcloneConfigured)) ? Style.font.body : (Style.font.title + 2)
            font.bold: true
          }

          // Sleek Progress Bar
          Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            height: Style.space(6)
            radius: 3
            color: Qt.rgba(OmarchyPalette.Color.foreground.r, OmarchyPalette.Color.foreground.g, OmarchyPalette.Color.foreground.b, 0.1)

            Rectangle {
              anchors.left: parent.left
              anchors.top: parent.top
              anchors.bottom: parent.bottom
              width: Math.min(parent.width, Math.max(0, parent.width * ((root.syncService && root.syncService.storage && root.syncService.storage.used_pct) ? (root.syncService.storage.used_pct / 100.0) : 0.0)))
              radius: 3
              color: (root.syncService && root.syncService.storage && root.syncService.storage.used_pct > 85.0) ? OmarchyPalette.Color.urgent : OmarchyPalette.Color.accent

              Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
            }
          }

          // Telemetry Details Pills Row
          RowLayout {
            Layout.fillWidth: true
            spacing: Style.space(6)

            // Free Space Pill
            Rectangle {
              Layout.fillWidth: true
              height: Style.space(22)
              radius: Style.cornerRadius - 3
              color: Style.selectedFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

              Row {
                anchors.centerIn: parent
                spacing: Style.space(3)
                Text { text: "󰄬"; color: "#44cc77"; font.family: Style.font.family; font.pixelSize: 9 }
                Text {
                  text: "Free: " + ((root.syncService && root.syncService.storage && root.syncService.storage.free_formatted) ? root.syncService.storage.free_formatted : "--")
                  color: OmarchyPalette.Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption - 1
                  font.bold: true
                }
              }
            }

            // Used % Pill
            Rectangle {
              Layout.fillWidth: true
              height: Style.space(22)
              radius: Style.cornerRadius - 3
              color: Style.selectedFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

              Row {
                anchors.centerIn: parent
                spacing: Style.space(3)
                Text { text: "󰘚"; color: OmarchyPalette.Color.accent; font.family: Style.font.family; font.pixelSize: 9 }
                Text {
                  text: "Used: " + ((root.syncService && root.syncService.storage && root.syncService.storage.used_pct !== undefined) ? (root.syncService.storage.used_pct + "%") : "0%")
                  color: OmarchyPalette.Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption - 1
                  font.bold: true
                }
              }
            }

            // Folders Pill
            Rectangle {
              Layout.fillWidth: true
              height: Style.space(22)
              radius: Style.cornerRadius - 3
              color: Style.selectedFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)

              Row {
                anchors.centerIn: parent
                spacing: Style.space(3)
                Text { text: "󰉋"; color: OmarchyPalette.Color.accent; font.family: Style.font.family; font.pixelSize: 9 }
                Text {
                  text: (root.syncService && root.syncService.folders ? root.syncService.folders.length : 0) + " Folders"
                  color: OmarchyPalette.Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption - 1
                  font.bold: true
                }
              }
            }
          }
        }

        // Sync Architecture & Protection Telemetry (Eliminates dead space)
        Rectangle {
          Layout.fillWidth: true
          Layout.fillHeight: true
          radius: Style.cornerRadius - 2
          color: Style.selectedFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)
          border.color: Qt.rgba(OmarchyPalette.Color.accent.r, OmarchyPalette.Color.accent.g, OmarchyPalette.Color.accent.b, 0.20)
          border.width: 1

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.space(10)
            spacing: Style.space(6)

            RowLayout {
              Layout.fillWidth: true
              Row {
                spacing: Style.space(6)
                Text {
                  text: "󰅟"
                  color: OmarchyPalette.Color.accent
                  font.family: Style.font.family
                  font.pixelSize: 10
                  anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                  text: "Active Backup Protection Matrix"
                  color: OmarchyPalette.Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  anchors.verticalCenter: parent.verticalCenter
                }
              }
              Item { Layout.fillWidth: true }
              Text {
                text: "Encrypted & Bounded"
                color: OmarchyPalette.Color.accent
                font.family: Style.font.family
                font.pixelSize: Style.font.caption - 1
                font.bold: true
              }
            }

            GridLayout {
              Layout.fillWidth: true
              columns: 2
              rowSpacing: Style.space(4)
              columnSpacing: Style.space(6)

              Rectangle {
                Layout.fillWidth: true
                height: Style.space(22)
                radius: 3
                color: Style.normalFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)
                Row {
                  anchors.centerIn: parent
                  spacing: 4
                  Text { text: "󰚩"; color: OmarchyPalette.Color.accent; font.pixelSize: 9 }
                  Text { text: "AI Skills & Instructions"; color: OmarchyPalette.Color.foreground; font.family: Style.font.family; font.pixelSize: 9; font.bold: true }
                }
              }

              Rectangle {
                Layout.fillWidth: true
                height: Style.space(22)
                radius: 3
                color: Style.normalFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)
                Row {
                  anchors.centerIn: parent
                  spacing: 4
                  Text { text: "󰒓"; color: OmarchyPalette.Color.accent; font.pixelSize: 9 }
                  Text { text: "Desktop & Hyprland Config"; color: OmarchyPalette.Color.foreground; font.family: Style.font.family; font.pixelSize: 9; font.bold: true }
                }
              }

              Rectangle {
                Layout.fillWidth: true
                height: Style.space(22)
                radius: 3
                color: Style.normalFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)
                Row {
                  anchors.centerIn: parent
                  spacing: 4
                  Text { text: "󰆧"; color: OmarchyPalette.Color.accent; font.pixelSize: 9 }
                  Text { text: "Work & Custom Repos"; color: OmarchyPalette.Color.foreground; font.family: Style.font.family; font.pixelSize: 9; font.bold: true }
                }
              }

              Rectangle {
                Layout.fillWidth: true
                height: Style.space(22)
                radius: 3
                color: Style.normalFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)
                Row {
                  anchors.centerIn: parent
                  spacing: 4
                  Text { text: "󰈙"; color: OmarchyPalette.Color.accent; font.pixelSize: 9 }
                  Text { text: "GDrive CloudDrive Mirror"; color: OmarchyPalette.Color.foreground; font.family: Style.font.family; font.pixelSize: 9; font.bold: true }
                }
              }
            }
          }
        }

        // Live Sync Progress Box (when active)
        Rectangle {
          Layout.fillWidth: true
          height: Style.space(38)
          radius: Style.cornerRadius - 3
          color: Qt.rgba(OmarchyPalette.Color.accent.r, OmarchyPalette.Color.accent.g, OmarchyPalette.Color.accent.b, 0.12)
          visible: root.syncService && root.syncService.active

          RowLayout {
            anchors.fill: parent
            anchors.margins: Style.space(8)
            spacing: Style.space(6)

            Text {
              text: "󰓦"
              color: OmarchyPalette.Color.accent
              font.family: Style.font.family
              font.pixelSize: 10
              Layout.alignment: Qt.AlignVCenter
              RotationAnimation on rotation {
                running: root.visible && root.enabled && !Motion.reducedMotion && root.syncService && root.syncService.active
                loops: Animation.Infinite
                from: 0; to: 360; duration: 1200
              }
            }

            ColumnLayout {
              Layout.fillWidth: true
              Layout.preferredWidth: 0
              spacing: 1
              Text {
                text: root.syncService ? root.syncService.message : "Syncing..."
                color: OmarchyPalette.Color.accent
                font.family: Style.font.family
                font.pixelSize: 9
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.preferredWidth: 0
              }
              Text {
                text: root.syncService && root.syncService.dataProgressLabel !== ""
                  ? ("Data to upload: " + root.syncService.dataProgressLabel + " • Speed: " + (root.syncService.speed || "0 B/s") + (root.syncService.uploadFilesTotal > 0 ? (" • " + root.syncService.uploadFilesDone + "/" + root.syncService.uploadFilesTotal + " files") : ""))
                  : (root.syncService && root.syncService.currentFile ? root.syncService.currentFile : "Synchronizing changes...")
                color: OmarchyPalette.Color.foreground
                font.family: Style.font.family
                font.pixelSize: 8
                elide: Text.ElideMiddle
                Layout.fillWidth: true
                Layout.preferredWidth: 0
              }
            }

            Text {
              text: (root.syncService ? root.syncService.progressPct : 0) + "%"
              color: OmarchyPalette.Color.accent
              font.family: Style.font.family
              font.pixelSize: 11
              font.bold: true
            }
          }
        }

        // 3. Primary Action Buttons (Matching Focus/Omni control buttons)
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.space(6)

          // Primary Sync / Stop Button
          Rectangle {
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            height: Style.space(30)
            radius: Style.cornerRadius - 3
            color: syncBtnMouse.containsMouse
              ? ((root.syncService && root.syncService.active) ? OmarchyPalette.Color.urgent : Style.selectedFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent))
              : ((root.syncService && root.syncService.active) ? Qt.rgba(OmarchyPalette.Color.urgent.r, OmarchyPalette.Color.urgent.g, OmarchyPalette.Color.urgent.b, 0.85) : OmarchyPalette.Color.accent)
            scale: syncBtnMouse.pressed ? 0.98 : 1.0

            Behavior on scale { NumberAnimation { duration: 100 } }
            Behavior on color { ColorAnimation { duration: 150 } }

            RowLayout {
              anchors.centerIn: parent
              spacing: Style.space(4)

              Text {
                text: (root.syncService && root.syncService.active) ? "󰏤" : "󰓦"
                color: (root.syncService && root.syncService.active) ? "#ffffff" : OmarchyPalette.Color.menu.background
                font.family: Style.font.family
                font.pixelSize: 10
                Layout.alignment: Qt.AlignVCenter
              }

              Text {
                text: (root.syncService && root.syncService.active) ? "Stop" : "Sync All"
                color: (root.syncService && root.syncService.active) ? "#ffffff" : OmarchyPalette.Color.menu.background
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
                elide: Text.ElideRight
                Layout.alignment: Qt.AlignVCenter
              }
            }

            MouseArea {
              id: syncBtnMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (root.syncService) {
                  if (!root.syncService.rcloneInstalled) {
                    root.syncService.installRclone()
                  } else if (!root.syncService.rcloneConfigured) {
                    root.syncService.configRclone()
                  } else if (root.syncService.active) {
                    root.syncService.stopSync()
                  } else {
                    root.syncService.startSync()
                  }
                }
              }
            }
          }

          // Restore Button
          Rectangle {
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            height: Style.space(30)
            radius: Style.cornerRadius - 3
            border.color: Qt.rgba(OmarchyPalette.Color.accent.r, OmarchyPalette.Color.accent.g, OmarchyPalette.Color.accent.b, 0.40)
            border.width: 1
            color: restoreBtnMouse.containsMouse
              ? Style.hoverFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)
              : Style.selectedFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)
            scale: restoreBtnMouse.pressed ? 0.98 : 1.0

            Behavior on scale { NumberAnimation { duration: 100 } }
            Behavior on color { ColorAnimation { duration: 150 } }

            RowLayout {
              anchors.centerIn: parent
              spacing: Style.space(4)

              Text {
                text: "󰁯"
                color: OmarchyPalette.Color.accent
                font.family: Style.font.family
                font.pixelSize: 10
                Layout.alignment: Qt.AlignVCenter
              }

              Text {
                text: "Restore"
                color: OmarchyPalette.Color.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
                elide: Text.ElideRight
                Layout.alignment: Qt.AlignVCenter
              }
            }

            MouseArea {
              id: restoreBtnMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (root.syncService) root.syncService.restoreFromCloud()
              }
            }
          }

          // Mount / Unmount Toggle Button
          Rectangle {
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            height: Style.space(30)
            radius: Style.cornerRadius - 3
            border.color: Qt.rgba(OmarchyPalette.Color.accent.r, OmarchyPalette.Color.accent.g, OmarchyPalette.Color.accent.b, 0.40)
            border.width: 1
            color: mountBtnMouse.containsMouse
              ? Style.hoverFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)
              : Style.selectedFillFor(OmarchyPalette.Color.foreground, OmarchyPalette.Color.accent)
            scale: mountBtnMouse.pressed ? 0.98 : 1.0

            Behavior on scale { NumberAnimation { duration: 100 } }
            Behavior on color { ColorAnimation { duration: 150 } }

            RowLayout {
              anchors.centerIn: parent
              spacing: Style.space(4)

              Text {
                text: "󰉋"
                color: (root.syncService && root.syncService.mounted) ? "#44cc77" : OmarchyPalette.Color.foreground
                font.family: Style.font.family
                font.pixelSize: 10
                Layout.alignment: Qt.AlignVCenter
              }

              Text {
                text: (root.syncService && root.syncService.mounted) ? "Unmount" : "Mount Drive"
                color: OmarchyPalette.Color.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
                elide: Text.ElideRight
                Layout.alignment: Qt.AlignVCenter
              }
            }

            MouseArea {
              id: mountBtnMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (root.syncService) root.syncService.toggleMount()
              }
            }
          }
        }
      }
    }
  }
}

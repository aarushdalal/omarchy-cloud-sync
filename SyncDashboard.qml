import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui
import "cards"
import "services"

KeyboardPanel {
  id: root

  property var syncService: null
  property int activeTabIndex: 0 // 0: Overview, 1: Folders, 2: Activity, 3: Settings
  property bool anchorHovered: false

  contentWidth: Style.space(560)
  contentHeight: Style.space(430)
  borderSpec: Border.none()
  focusTarget: mainCanvas

  function show() { root.open = true }
  function hide() { root.close() }
  function toggle() { root.open ? root.close() : (root.open = true) }

  // High-Precision Trackpad & Mouse Wheel Navigator across 4 tabs
  property real wheelAccumulator: 0
  property real lastWheelEventTime: 0
  property real lastTriggerTime: 0
  readonly property real wheelThreshold: 20

  function handleWheel(wheelOrDelta) {
    var now = Date.now()
    var dy = 0
    var dx = 0

    if (typeof wheelOrDelta === "number") {
      dy = wheelOrDelta
    } else if (wheelOrDelta && typeof wheelOrDelta === "object") {
      if (wheelOrDelta.angleDelta) {
        dy = wheelOrDelta.angleDelta.y || 0
        dx = wheelOrDelta.angleDelta.x || 0
      }
      if (dy === 0 && dx === 0 && wheelOrDelta.pixelDelta) {
        dy = (wheelOrDelta.pixelDelta.y || 0) * 4
        dx = (wheelOrDelta.pixelDelta.x || 0) * 4
      }
    }

    if (dy === 0 && dx === 0) return

    if (now - lastWheelEventTime > 220) {
      wheelAccumulator = 0
    }
    lastWheelEventTime = now

    if (now - lastTriggerTime < 240) {
      return
    }

    var dominant = Math.abs(dx) > Math.abs(dy) ? dx : dy
    wheelAccumulator += dominant

    if (wheelAccumulator >= wheelThreshold) {
      wheelAccumulator = 0
      lastTriggerTime = now
      root.activeTabIndex = (root.activeTabIndex - 1 + 4) % 4
    } else if (wheelAccumulator <= -wheelThreshold) {
      wheelAccumulator = 0
      lastTriggerTime = now
      root.activeTabIndex = (root.activeTabIndex + 1) % 4
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.NoButton
    onWheel: function(wheel) {
      root.handleWheel(wheel)
    }
  }

  // Main UI Canvas
  Item {
    id: mainCanvas
    anchors.fill: parent
    focus: true

    Keys.onPressed: function(event) {
      if (event.key === Qt.Key_Escape) {
        root.close()
        event.accepted = true
      } else if (event.key === Qt.Key_Tab) {
        root.activeTabIndex = (root.activeTabIndex + 1) % 4
        event.accepted = true
      } else if (event.key === Qt.Key_1) {
        root.activeTabIndex = 0
        event.accepted = true
      } else if (event.key === Qt.Key_2) {
        root.activeTabIndex = 1
        event.accepted = true
      } else if (event.key === Qt.Key_3) {
        root.activeTabIndex = 2
        event.accepted = true
      } else if (event.key === Qt.Key_4) {
        root.activeTabIndex = 3
        event.accepted = true
      }
    }

    // Top Segmented Tab Switcher with Gliding Pill Indicator
    Rectangle {
      id: tabSwitcher
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      height: Style.space(40)
      radius: Style.cornerRadius
      color: Style.normalFillFor(Color.foreground, Color.accent)

      readonly property var tabs: [
        { icon: "󰅟", label: "Overview", index: 0 },
        { icon: "󰉋", label: "Folders", index: 1 },
        { icon: "󰓦", label: "Activity", index: 2 },
        { icon: "󰒓", label: "Settings", index: 3 }
      ]

      readonly property real singleTabWidth: (tabSwitcher.width - Style.space(6) - (tabSwitcher.tabs.length - 1) * Style.space(4)) / tabSwitcher.tabs.length

      // Smooth Sliding Active Pill Indicator
      Rectangle {
        id: activePill
        y: Style.space(3)
        height: tabSwitcher.height - Style.space(6)
        width: tabSwitcher.singleTabWidth
        x: Style.space(3) + root.activeTabIndex * (tabSwitcher.singleTabWidth + Style.space(4))
        radius: Style.cornerRadius - 2
        color: Style.selectedFillFor(Color.foreground, Color.accent)

        Behavior on x {
          NumberAnimation { duration: 280; easing.type: Easing.OutBack; easing.overshoot: 1.15 }
        }
      }

      Row {
        id: tabsRow
        anchors.fill: parent
        anchors.margins: Style.space(3)
        spacing: Style.space(4)

        Repeater {
          model: tabSwitcher.tabs

          Item {
            id: tabItem
            width: tabSwitcher.singleTabWidth
            height: tabsRow.height
            readonly property bool isSelected: root.activeTabIndex === modelData.index

            Rectangle {
              anchors.fill: parent
              radius: Style.cornerRadius - 2
              color: tabMouse.containsMouse && !tabItem.isSelected
                ? Style.hoverFillFor(Color.foreground, Color.accent)
                : "transparent"

              Behavior on color { ColorAnimation { duration: 150 } }

              Row {
                anchors.centerIn: parent
                spacing: Style.space(6)

                Text {
                  id: iconText
                  text: modelData.icon
                  color: tabItem.isSelected ? Color.accent : Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: 11
                  anchors.verticalCenter: parent.verticalCenter
                  scale: tabItem.isSelected ? 1.08 : (tabMouse.containsMouse ? 1.04 : 1.0)

                  Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                  Behavior on color { ColorAnimation { duration: 150 } }
                }

                Text {
                  id: labelText
                  text: modelData.label
                  color: tabItem.isSelected ? Color.accent : Color.foreground
                  font.family: Style.font.family
                  font.pixelSize: 11
                  font.bold: tabItem.isSelected
                  anchors.verticalCenter: parent.verticalCenter

                  Behavior on color { ColorAnimation { duration: 150 } }
                }
              }

              MouseArea {
                id: tabMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.activeTabIndex = modelData.index
                onWheel: function(wheel) {
                  root.handleWheel(wheel)
                }
              }
            }
          }
        }
      }
    }

    // Horizontal Sliding Carousel Stack with Smooth Transitions
    Item {
      id: carouselStack
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: tabSwitcher.bottom
      anchors.bottom: parent.bottom
      anchors.topMargin: Style.space(10)
      clip: true

      // Card 0: Overview
      Item {
        width: carouselStack.width
        height: carouselStack.height
        x: (0 - root.activeTabIndex) * carouselStack.width
        scale: root.activeTabIndex === 0 ? 1.0 : 0.95
        opacity: Math.max(0.0, 1.0 - Math.abs(0 - root.activeTabIndex) * 0.8)
        visible: Math.abs(0 - root.activeTabIndex) <= 1

        Behavior on x { NumberAnimation { duration: Motion.entryDuration; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on scale { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on opacity { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }

        OverviewCard {
          anchors.fill: parent
          syncService: root.syncService
        }
      }

      // Card 1: Folders
      Item {
        width: carouselStack.width
        height: carouselStack.height
        x: (1 - root.activeTabIndex) * carouselStack.width
        scale: root.activeTabIndex === 1 ? 1.0 : 0.95
        opacity: Math.max(0.0, 1.0 - Math.abs(1 - root.activeTabIndex) * 0.8)
        visible: Math.abs(1 - root.activeTabIndex) <= 1

        Behavior on x { NumberAnimation { duration: Motion.entryDuration; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on scale { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on opacity { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }

        FoldersCard {
          anchors.fill: parent
          syncService: root.syncService
          dashboard: root
        }
      }

      // Card 2: Activity
      Item {
        width: carouselStack.width
        height: carouselStack.height
        x: (2 - root.activeTabIndex) * carouselStack.width
        scale: root.activeTabIndex === 2 ? 1.0 : 0.95
        opacity: Math.max(0.0, 1.0 - Math.abs(2 - root.activeTabIndex) * 0.8)
        visible: Math.abs(2 - root.activeTabIndex) <= 1

        Behavior on x { NumberAnimation { duration: Motion.entryDuration; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on scale { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on opacity { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }

        ActivityCard {
          anchors.fill: parent
          syncService: root.syncService
        }
      }

      // Card 3: Settings
      Item {
        width: carouselStack.width
        height: carouselStack.height
        x: (3 - root.activeTabIndex) * carouselStack.width
        scale: root.activeTabIndex === 3 ? 1.0 : 0.95
        opacity: Math.max(0.0, 1.0 - Math.abs(3 - root.activeTabIndex) * 0.8)
        visible: Math.abs(3 - root.activeTabIndex) <= 1

        Behavior on x { NumberAnimation { duration: Motion.entryDuration; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on scale { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeExpressive; easing.overshoot: Motion.springOvershoot } }
        Behavior on opacity { NumberAnimation { duration: Motion.standard; easing.type: Motion.easeStandard } }

        SettingsCard {
          anchors.fill: parent
          syncService: root.syncService
        }
      }
    }

    // In-Dashboard Folder Browser Modal (Top Level)
    FolderBrowserModal {
      id: folderBrowser
      syncService: root.syncService
      anchors.fill: parent
      z: 300
    }
  }

  function openFolderBrowser(startPath) {
    folderBrowser.open(startPath || "")
  }
}

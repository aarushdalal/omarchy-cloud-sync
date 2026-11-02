import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui
import "components/polish" as Polish
import "cards"
import "services"

Polish.RefinedKeyboardPanel {
  id: root

  property var syncService: null
  property int activeTabIndex: 0 // 0: Overview, 1: Folders, 2: Activity, 3: Settings
  property bool anchorHovered: false
  onActiveTabIndexChanged: {
    var bounded = Math.max(0, Math.min(3, activeTabIndex))
    if (activeTabIndex !== bounded) activeTabIndex = bounded
  }

  contentWidth: Style.space(560)
  contentHeight: Style.space(438)
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
        root.activeTabIndex = (root.activeTabIndex + (event.modifiers & Qt.ShiftModifier ? 3 : 1)) % 4
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
    Polish.DashboardTabs {
      id: tabSwitcher
      anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
      height: implicitHeight
      title: "GSync"
      currentIndex: root.activeTabIndex
      motionEnabled: root.open
      tabs: [
        { icon: "󰅟", label: "Overview", index: 0 },
        { icon: "󰉋", label: "Folders", index: 1 },
        { icon: "󰓦", label: "Activity", index: 2 },
        { icon: "󰒓", label: "Settings", index: 3 }
      ]
      onSelectionRequested: function(index) { root.activeTabIndex = index }
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
      Polish.DashboardPage {
        width: carouselStack.width
        height: carouselStack.height
        pageIndex: 0; selectedIndex: root.activeTabIndex
        motionEnabled: root.open && !Polish.MotionAdapter.reducedMotion
        enabled: selected && root.open

        OverviewCard {
          anchors.fill: parent
          syncService: root.syncService
        }
      }

      // Card 1: Folders
      Polish.DashboardPage {
        width: carouselStack.width
        height: carouselStack.height
        pageIndex: 1; selectedIndex: root.activeTabIndex
        motionEnabled: root.open && !Polish.MotionAdapter.reducedMotion
        enabled: selected && root.open

        FoldersCard {
          anchors.fill: parent
          syncService: root.syncService
          dashboard: root
        }
      }

      // Card 2: Activity
      Polish.DashboardPage {
        width: carouselStack.width
        height: carouselStack.height
        pageIndex: 2; selectedIndex: root.activeTabIndex
        motionEnabled: root.open && !Polish.MotionAdapter.reducedMotion
        enabled: selected && root.open

        ActivityCard {
          anchors.fill: parent
          syncService: root.syncService
        }
      }

      // Card 3: Settings
      Polish.DashboardPage {
        width: carouselStack.width
        height: carouselStack.height
        pageIndex: 3; selectedIndex: root.activeTabIndex
        motionEnabled: root.open && !Polish.MotionAdapter.reducedMotion
        enabled: selected && root.open

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

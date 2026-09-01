import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root

  moduleName: "io.github.limbdarkening.softether"
  ipcTarget: "io.github.limbdarkening.softether"
  manageIpc: false

  property int accountIndex: 0
  property bool cursorActive: false

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property string selectedFlag: vpn.selectedAccount
    ? String(vpn.selectedAccount.flag || "🏳") : "🏳"
  readonly property color iconColor: {
    if (vpn.state === "error" || vpn.state === "warning") return urgent
    if (vpn.state === "off") return Qt.darker(barForeground, 1.55)
    return barForeground
  }

  function clampIndex() {
    if (vpn.accounts.length === 0) accountIndex = 0
    else accountIndex = Math.max(0, Math.min(vpn.accounts.length - 1, accountIndex))
  }

  function selectedRow() {
    if (vpn.accounts.length === 0) return null
    clampIndex()
    return vpn.accounts[accountIndex]
  }

  function moveCursor(delta) {
    if (vpn.accounts.length === 0) return
    cursorActive = true
    accountIndex = Math.max(0, Math.min(vpn.accounts.length - 1, accountIndex + delta))
  }

  function activateCursor() {
    var account = selectedRow()
    if (account) chooseAccount(account)
  }

  function chooseAccount(account) {
    if (!account) return
    vpn.selectAccount(account.name)
    root.close()
  }

  function persistSelection(accountName) {
    var entry = { id: root.moduleName }
    for (var key in root.settings) if (key !== "id") entry[key] = root.settings[key]
    entry.accountName = accountName
    root.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
      root.bar.shell.updateEntryInline(root.moduleName, entry)
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onOpenedChanged: if (opened) {
    cursorActive = false
    vpn.refresh()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  Service {
    id: vpn
    settings: root.settings
    onSelectionRequested: function(accountName) { root.persistSelection(accountName) }
  }

  Connections {
    target: vpn
    function onAccountsChanged() { root.clampIndex() }
  }

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function togglePanel(): void { root.toggle() }
    function toggleVpn(): string { vpn.toggle(); return "ok" }
    function refresh(): string { vpn.refresh(); return "ok" }
    function status(): string { return vpn.statusText }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    interactive: false
    slotSize: Style.space(38)
    opticalSize: Style.space(30)
    tooltipText: vpn.tooltipText
    iconComponent: Component {
      Item {
        Row {
          anchors.centerIn: parent
          spacing: Style.space(3)

          ShieldIcon {
            anchors.verticalCenter: parent.verticalCenter
            iconSize: Style.space(12)
            color: root.iconColor
            badgeColor: root.urgent
            state: vpn.state
            pulsing: vpn.connectAnimationActive
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.selectedFlag
            textFormat: Text.PlainText
            color: root.foreground
            font.family: "Noto Color Emoji"
            font.pixelSize: Style.space(13)
          }
        }
      }
    }
  }

  // Handle pointer input on this surface directly. Forwarding MouseButton
  // through WidgetButton's integer signal caused right-clicks to arrive as the
  // toggle action on this system.
  MouseArea {
    id: inputSurface
    anchors.fill: button
    z: 10
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onEntered: if (root.bar) root.bar.showTooltip(button, vpn.tooltipText)
    onExited: if (root.bar) root.bar.hideTooltip(button)
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) {
        root.open()
        return
      }
      if (mouse.button === Qt.MiddleButton) {
        vpn.refresh()
        return
      }
      if (mouse.button === Qt.LeftButton) {
        if (mouse.x >= width / 2) root.open()
        else vpn.toggle()
      }
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(310))
    contentHeight: panel.fittedContentHeight(column.implicitHeight, Style.space(460))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onMoveRequested: function(dx, dy) { if (dy !== 0) root.moveCursor(dy) }
      onActivateRequested: root.activateCursor()
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(text) {
        if (text === "r" || text === "R") vpn.refresh()
        else if (text === "t" || text === "T") vpn.toggle()
      }

      Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
          id: column
          width: parent.width
          spacing: Style.space(12)

          RowLayout {
            width: parent.width
            spacing: Style.space(12)

            ShieldIcon {
              iconSize: Style.font.display
              color: root.iconColor
              badgeColor: root.urgent
              state: vpn.state
              pulsing: vpn.connectAnimationActive
              Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: Style.space(2)

              Text {
                Layout.fillWidth: true
                text: root.selectedFlag + "  " + vpn.country
                textFormat: Text.PlainText
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.title
                font.bold: true
                elide: Text.ElideRight
              }

              Text {
                Layout.fillWidth: true
                text: vpn.statusText.toUpperCase()
                textFormat: Text.PlainText
                color: vpn.state === "error" || vpn.state === "warning" ? root.urgent : root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                font.letterSpacing: 1.0
                elide: Text.ElideRight
              }
            }
          }

          Text {
            visible: vpn.lastError !== ""
            width: parent.width
            text: vpn.lastError
            textFormat: Text.PlainText
            color: root.urgent
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            wrapMode: Text.WordWrap
          }

          PanelSeparator {
            foreground: root.foreground
          }

          PanelSectionHeader {
            text: "COUNTRY"
            foreground: root.foreground
            fontFamily: root.fontFamily
          }

          Text {
            visible: vpn.serviceAvailable && vpn.accounts.length === 0
            width: parent.width
            text: "Import a SoftEther connection profile to add a country."
            textFormat: Text.PlainText
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            wrapMode: Text.WordWrap
          }

          Text {
            visible: !vpn.serviceAvailable
            width: parent.width
            text: "Start the softethervpn-client service to load VPN profiles."
            textFormat: Text.PlainText
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            wrapMode: Text.WordWrap
          }

          Column {
            width: parent.width
            spacing: Style.space(6)

            Repeater {
              model: vpn.accounts

              CursorSurface {
                id: accountRow
                required property var modelData
                required property int index
                property var account: modelData
                readonly property bool selectedAccount: vpn.selectedAccountName === account.name
                readonly property bool connectedAccount: account.statusKind === "connected" || account.statusKind === "connecting"

                width: parent.width
                implicitHeight: rowContent.implicitHeight + Style.spacing.rowPaddingX
                hasCursor: root.cursorActive && root.accountIndex === index
                current: selectedAccount
                foreground: root.foreground

                RowLayout {
                  id: rowContent
                  anchors.left: parent.left
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.leftMargin: Style.space(10)
                  anchors.rightMargin: Style.space(10)
                  spacing: Style.space(8)

                  Rectangle {
                    width: Style.space(7)
                    height: width
                    radius: width / 2
                    color: accountRow.connectedAccount ? root.foreground : root.dim
                    opacity: accountRow.connectedAccount ? 1.0 : 0.35
                    Layout.alignment: Qt.AlignVCenter
                  }

                  ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Style.space(1)

                    Text {
                      Layout.fillWidth: true
                      text: String(accountRow.account.flag || "🏳") + "  " + accountRow.account.country
                      textFormat: Text.PlainText
                      color: root.foreground
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.body
                      font.bold: accountRow.selectedAccount
                      elide: Text.ElideRight
                    }

                    Text {
                      Layout.fillWidth: true
                      text: accountRow.account.statusKind === "connected" ? "Connected"
                        : (accountRow.account.statusKind === "connecting" ? "Connecting" : accountRow.account.server)
                      textFormat: Text.PlainText
                      color: root.dim
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.caption
                      elide: Text.ElideRight
                    }
                  }

                  Text {
                    visible: accountRow.selectedAccount
                    text: "✓"
                    textFormat: Text.PlainText
                    color: root.foreground
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.body
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                  }
                }

                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  enabled: !vpn.busy
                  cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                  onEntered: {
                    root.cursorActive = true
                    root.accountIndex = accountRow.index
                  }
                  onClicked: root.chooseAccount(accountRow.account)
                }
              }
            }
          }

          Text {
            visible: vpn.tunnelAddress !== ""
            width: parent.width
            text: "Tunnel address  " + vpn.tunnelAddress
            textFormat: Text.PlainText
            color: root.dim
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            horizontalAlignment: Text.AlignHCenter
          }
        }
      }
    }
  }
}

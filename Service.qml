import QtQuick
import Quickshell
import Quickshell.Io
import "CountryLookup.js" as CountryLookup
import "Model.js" as Model

Item {
  id: root

  property var settings: ({})
  property bool installed: false
  property bool serviceAvailable: false
  property bool refreshing: false
  property bool busy: actionProcess.running
  property var accounts: []
  property string selectedAccountName: ""
  property string tunnelAddress: ""
  property bool hasVpnDefaultRoute: false
  property string actionStatus: ""
  property string lastError: ""
  property string actionKind: ""
  property string actionAccountName: ""
  property string connectAfterDisconnect: ""
  property int desiredState: -1

  signal selectionRequested(string accountName)

  readonly property string adapterName: String(setting("adapterName", "vpn_vpn"))
  readonly property string networkProfileName: String(setting("networkProfileName", "SoftEther VPN Network"))
  readonly property string controlPath: Quickshell.env("HOME") + "/.config/omarchy/plugins/io.github.limbdarkening.softether/softether-control"
  readonly property int refreshIntervalSec: boundedInt(setting("refreshIntervalSec", 10), 10, 5, 300)
  readonly property var selectedAccount: accountNamed(selectedAccountName)
  readonly property var connectedAccount: firstAccountWithState("connected")
  readonly property var connectingAccount: firstAccountWithState("connecting")
  readonly property var activeAccount: connectedAccount || connectingAccount
  readonly property bool active: desiredState === -1 ? activeAccount !== null : desiredState === 1
  readonly property bool usable: connectedAccount !== null && tunnelAddress !== "" && hasVpnDefaultRoute
  readonly property bool connectAnimationActive: Model.shouldPulse(actionKind)
  readonly property string country: selectedAccount ? selectedAccount.country : "VPN"
  readonly property string state: Model.presentationState({
    installed: installed,
    serviceAvailable: serviceAvailable,
    lastError: lastError,
    actionKind: actionKind,
    desiredState: desiredState,
    connecting: connectingAccount !== null,
    connected: connectedAccount !== null,
    usable: usable
  })
  readonly property string statusText: {
    if (!installed) return "SoftEther is not installed"
    if (!serviceAvailable) return "SoftEther client service is stopped"
    if (accounts.length === 0) return "No imported VPN profiles"
    if (lastError !== "") return "Connection failed · " + country
    if (busy && actionKind === "connect") return "Connecting to " + country + "…"
    if (busy && actionKind === "disconnect") return "Disconnecting…"
    if (connectingAccount) return "Connecting to " + connectingAccount.country + "…"
    if (connectedAccount && !usable) return "Connected; waiting for VPN route"
    if (connectedAccount) return "Connected to " + connectedAccount.country
    return "Disconnected · " + country + " selected"
  }
  readonly property string tooltipText: "SoftEther VPN · " + statusText

  property string _accountsOutput: ""
  property string _accountsError: ""
  property string _addressOutput: ""
  property string _routeOutput: ""
  property string _actionOutput: ""
  property string _actionError: ""

  function setting(name, fallback) {
    var value = settings ? settings[name] : undefined
    return value === undefined || value === null ? fallback : value
  }

  function boundedInt(value, fallback, min, max) {
    var parsed = parseInt(String(value), 10)
    if (!isFinite(parsed)) parsed = fallback
    return Math.max(min, Math.min(max, parsed))
  }

  function accountNamed(name) {
    var target = String(name || "")
    for (var i = 0; i < accounts.length; i++)
      if (String(accounts[i].name || "") === target) return accounts[i]
    return null
  }

  function firstAccountWithState(kind) {
    for (var i = 0; i < accounts.length; i++)
      if (accounts[i].statusKind === kind) return accounts[i]
    return null
  }

  function choosePreferredAccount() {
    var configured = String(setting("accountName", ""))
    if (accountNamed(configured)) {
      selectedAccountName = configured
      return
    }
    if (activeAccount) selectedAccountName = activeAccount.name
    else if (accounts.length > 0) selectedAccountName = accounts[0].name
    else selectedAccountName = ""
  }

  function elide(text) {
    var value = String(text || "").replace(/\s+/g, " ").trim()
    return value.length > 180 ? value.substring(0, 177) + "…" : value
  }

  function refresh() {
    if (!installed) {
      if (!whichProcess.running) {
        whichProcess.command = ["which", "vpncmd"]
        whichProcess.running = true
      }
      return
    }
    refreshAccounts()
    refreshNetwork()
  }

  function refreshAccounts() {
    if (accountsProcess.running) return
    refreshing = true
    _accountsOutput = ""
    _accountsError = ""
    accountsProcess.command = ["timeout", "6", "vpncmd", "localhost", "/CLIENT", "/CMD", "AccountList"]
    accountsProcess.running = true
  }

  function refreshNetwork() {
    if (!addressProcess.running) {
      _addressOutput = ""
      addressProcess.command = ["ip", "-j", "address", "show", "dev", adapterName]
      addressProcess.running = true
    }
    if (!routeProcess.running) {
      _routeOutput = ""
      routeProcess.command = ["ip", "-j", "route", "show", "default"]
      routeProcess.running = true
    }
  }

  function toggle() {
    if (busy || !serviceAvailable || !selectedAccount) return
    var current = activeAccount
    if (current) {
      desiredState = 0
      runAction("disconnect", current.name, "")
    } else {
      desiredState = 1
      runAction("connect", selectedAccount.name, "")
    }
  }

  function selectAccount(name) {
    var account = accountNamed(name)
    if (!account || busy) return
    var current = activeAccount
    selectedAccountName = account.name
    selectionRequested(account.name)

    if (current && current.name !== account.name) {
      desiredState = 1
      runAction("disconnect", current.name, account.name)
    }
  }

  function runAction(kind, accountName, nextAccountName) {
    if (actionProcess.running || !accountName) return
    actionKind = kind
    actionAccountName = accountName
    connectAfterDisconnect = String(nextAccountName || "")
    actionStatus = kind === "connect" ? "Connecting…" : "Disconnecting…"
    lastError = ""
    _actionOutput = ""
    _actionError = ""
    actionProcess.command = ["timeout", "80", controlPath, kind, accountName, networkProfileName, adapterName]
    actionProcess.running = true
  }

  Component.onCompleted: refresh()
  onSettingsChanged: choosePreferredAccount()

  Timer {
    interval: root.refreshIntervalSec * 1000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Timer {
    id: delayedRefresh
    interval: 800
    repeat: false
    onTriggered: root.refresh()
  }

  Timer {
    id: settleDesiredState
    interval: 12000
    repeat: false
    onTriggered: root.desiredState = -1
  }

  Process {
    id: whichProcess
    running: false
    command: []
    onExited: function(exitCode) {
      root.installed = exitCode === 0
      if (root.installed) root.refresh()
      else {
        root.serviceAvailable = false
        root.lastError = "vpncmd was not found"
      }
    }
  }

  Process {
    id: accountsProcess
    running: false
    command: []
    stdout: StdioCollector {
      id: accountsStdout
      waitForEnd: true
      onStreamFinished: root._accountsOutput = text
    }
    stderr: StdioCollector {
      id: accountsStderr
      waitForEnd: true
      onStreamFinished: root._accountsError = text
    }
    onExited: function(exitCode) {
      root.refreshing = false
      var stdout = String(accountsStdout.text || root._accountsOutput || "")
      var stderr = String(accountsStderr.text || root._accountsError || "")
      if (exitCode === 0) {
        root.serviceAvailable = true
        var parsedAccounts = Model.parseAccountList(stdout)
        for (var i = 0; i < parsedAccounts.length; i++) {
          var country = CountryLookup.countryDetails(parsedAccounts[i].name)
          parsedAccounts[i].country = country.label
          parsedAccounts[i].countryCode = country.code
          parsedAccounts[i].flag = country.flag
        }
        root.accounts = parsedAccounts
        root.choosePreferredAccount()
        if (root.lastError.indexOf("service") !== -1) root.lastError = ""
        if (root.desiredState === 1 && root.activeAccount) root.desiredState = -1
        if (root.desiredState === 0 && !root.activeAccount) root.desiredState = -1
      } else {
        root.serviceAvailable = false
        root.accounts = []
        root.tunnelAddress = ""
        root.hasVpnDefaultRoute = false
        root.lastError = root.elide(stderr || stdout || "SoftEther client service is unavailable")
      }
    }
  }

  Process {
    id: addressProcess
    running: false
    command: []
    stdout: StdioCollector {
      id: addressStdout
      waitForEnd: true
      onStreamFinished: root._addressOutput = text
    }
    onExited: function(exitCode) {
      root.tunnelAddress = exitCode === 0
        ? Model.parseAddress(String(addressStdout.text || root._addressOutput || "")) : ""
    }
  }

  Process {
    id: routeProcess
    running: false
    command: []
    stdout: StdioCollector {
      id: routeStdout
      waitForEnd: true
      onStreamFinished: root._routeOutput = text
    }
    onExited: function(exitCode) {
      root.hasVpnDefaultRoute = exitCode === 0
        && Model.hasDefaultRoute(String(routeStdout.text || root._routeOutput || ""), root.adapterName)
    }
  }

  Process {
    id: actionProcess
    running: false
    command: []
    stdout: StdioCollector {
      id: actionStdout
      waitForEnd: true
      onStreamFinished: root._actionOutput = text
    }
    stderr: StdioCollector {
      id: actionStderr
      waitForEnd: true
      onStreamFinished: root._actionError = text
    }
    onExited: function(exitCode) {
      var stdout = String(actionStdout.text || root._actionOutput || "")
      var stderr = String(actionStderr.text || root._actionError || "")
      var next = root.connectAfterDisconnect
      var completedKind = root.actionKind
      root.actionKind = ""
      root.actionAccountName = ""
      root.connectAfterDisconnect = ""
      root.actionStatus = ""

      if (exitCode !== 0) {
        root.desiredState = -1
        root.lastError = root.elide(stderr || stdout || "SoftEther command failed")
        root.refresh()
        return
      }

      root.lastError = ""
      if (completedKind === "disconnect" && next !== "") {
        Qt.callLater(function() { root.runAction("connect", next, "") })
      } else {
        settleDesiredState.restart()
        delayedRefresh.restart()
      }
    }
  }
}

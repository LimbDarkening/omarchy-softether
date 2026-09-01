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

  readonly property string configuredAccountName: boundedSetting("accountName", "", 128)
  readonly property string adapterName: boundedSetting("adapterName", "vpn_vpn", 15)
  readonly property string networkProfileName: boundedSetting("networkProfileName", "SoftEther VPN Network", 128)
  readonly property string settingsError: Model.settingsError(
    configuredAccountName, networkProfileName, adapterName)
  readonly property bool settingsValid: settingsError === ""
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
    lastError: settingsError || lastError,
    actionKind: actionKind,
    desiredState: desiredState,
    connecting: connectingAccount !== null,
    connected: connectedAccount !== null,
    usable: usable
  })
  readonly property string statusText: {
    if (!settingsValid) return settingsError
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

  function boundedSetting(name, fallback, maximum) {
    var value = String(setting(name, fallback))
    // Return a deliberately invalid sentinel without retaining an oversized
    // duplicate in the service model.
    return value.length <= maximum ? value : "\n"
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
    var configured = configuredAccountName
    if (accountNamed(configured)) {
      selectedAccountName = configured
      return
    }
    if (activeAccount) selectedAccountName = activeAccount.name
    else if (accounts.length > 0) selectedAccountName = accounts[0].name
    else selectedAccountName = ""
  }

  function elide(text) {
    return Model.elideError(text)
  }

  function refresh() {
    if (!settingsValid) {
      refreshing = false
      serviceAvailable = false
      accounts = []
      tunnelAddress = ""
      hasVpnDefaultRoute = false
      return
    }
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
    accountsProcess.command = ["timeout", "--signal=TERM", "--kill-after=3s", "10s",
      controlPath, "accounts"]
    accountsProcess.running = true
  }

  function refreshNetwork() {
    if (!addressProcess.running) {
      _addressOutput = ""
      addressProcess.command = ["timeout", "--signal=TERM", "--kill-after=3s", "9s",
        controlPath, "address", adapterName]
      addressProcess.running = true
    }
    if (!routeProcess.running) {
      _routeOutput = ""
      routeProcess.command = ["timeout", "--signal=TERM", "--kill-after=3s", "9s",
        controlPath, "routes"]
      routeProcess.running = true
    }
  }

  function toggle() {
    if (!settingsValid) {
      lastError = settingsError
      return
    }
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
    if (!Model.validAccountName(name, false)) {
      lastError = "Invalid SoftEther account name"
      return
    }
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
    if (actionProcess.running || !accountName || !settingsValid
        || !Model.validAccountName(accountName, false)) {
      if (!settingsValid) lastError = settingsError
      else if (accountName && !Model.validAccountName(accountName, false))
        lastError = "Invalid SoftEther account name"
      return
    }
    actionKind = kind
    actionAccountName = accountName
    connectAfterDisconnect = String(nextAccountName || "")
    actionStatus = kind === "connect" ? "Connecting…" : "Disconnecting…"
    lastError = ""
    _actionOutput = ""
    _actionError = ""
    // The forced-kill grace period covers the helper's bounded disconnect and
    // removal of all eight possible transport routes after TERM.
    actionProcess.command = ["timeout", "--signal=TERM", "--kill-after=70s", "100s",
      controlPath, kind, accountName, networkProfileName, adapterName]
    actionProcess.running = true
  }

  Component.onCompleted: refresh()
  onSettingsChanged: {
    choosePreferredAccount()
    if (!settingsValid) lastError = settingsError
    else if (lastError.indexOf("Invalid ") === 0) lastError = ""
  }

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
      onStreamFinished: root._accountsOutput = Model.bounded(text, 65536) || ""
    }
    stderr: StdioCollector {
      id: accountsStderr
      waitForEnd: true
      onStreamFinished: root._accountsError = Model.bounded(text, 4096) || ""
    }
    onExited: function(exitCode) {
      root.refreshing = false
      var stdout = Model.bounded(accountsStdout.text || root._accountsOutput || "", 65536)
      var stderr = Model.bounded(accountsStderr.text || root._accountsError || "", 4096)
      if (exitCode === 0 && stdout !== null && stderr !== null) {
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
      onStreamFinished: root._addressOutput = Model.bounded(text, 32768) || ""
    }
    onExited: function(exitCode) {
      var stdout = Model.bounded(addressStdout.text || root._addressOutput || "", 32768)
      root.tunnelAddress = exitCode === 0 && stdout !== null
        ? Model.parseAddress(stdout) : ""
    }
  }

  Process {
    id: routeProcess
    running: false
    command: []
    stdout: StdioCollector {
      id: routeStdout
      waitForEnd: true
      onStreamFinished: root._routeOutput = Model.bounded(text, 32768) || ""
    }
    onExited: function(exitCode) {
      var stdout = Model.bounded(routeStdout.text || root._routeOutput || "", 32768)
      root.hasVpnDefaultRoute = exitCode === 0 && stdout !== null
        && Model.hasDefaultRoute(stdout, root.adapterName)
    }
  }

  Process {
    id: actionProcess
    running: false
    command: []
    stdout: StdioCollector {
      id: actionStdout
      waitForEnd: true
      onStreamFinished: root._actionOutput = Model.bounded(text, 65536) || ""
    }
    stderr: StdioCollector {
      id: actionStderr
      waitForEnd: true
      onStreamFinished: root._actionError = Model.bounded(text, 4096) || ""
    }
    onExited: function(exitCode) {
      var stdout = Model.bounded(actionStdout.text || root._actionOutput || "", 65536)
      var stderr = Model.bounded(actionStderr.text || root._actionError || "", 4096)
      var next = root.connectAfterDisconnect
      var completedKind = root.actionKind
      root.actionKind = ""
      root.actionAccountName = ""
      root.connectAfterDisconnect = ""
      root.actionStatus = ""

      if (exitCode !== 0 || stdout === null || stderr === null) {
        root.desiredState = -1
        root.lastError = stdout === null || stderr === null
          ? "SoftEther command output exceeded safe limits"
          : root.elide(stderr || stdout || "SoftEther command failed")
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

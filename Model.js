var MAX_COMMAND_CHARS = 65536
var MAX_NETWORK_CHARS = 32768
var MAX_LINES = 1024
var MAX_ACCOUNTS = 128
var MAX_ROW_CHARS = 1024
var MAX_FIELD_CHARS = 256
var MAX_JSON_ITEMS = 128
var MAX_ACCOUNT_NAME_LENGTH = 128
var MAX_PROFILE_NAME_LENGTH = 128

function bounded(value, maximum) {
  var text = String(value || "")
  return text.length <= maximum ? text : null
}

function decoded(value) {
  var text = bounded(value, MAX_FIELD_CHARS)
  return text === null ? "" : text.replace(/\$20/g, " ").trim()
}

function validNamedSetting(value, maximum, allowEmpty) {
  var text = String(value || "")
  if (allowEmpty && text === "") return true
  if (text.length < 1 || text.length > maximum) return false
  return /^[A-Za-z0-9][A-Za-z0-9._@()+,#%=-]*( [A-Za-z0-9._@()+,#%=-]+)*$/.test(text)
}

function validAccountName(value, allowEmpty) {
  return validNamedSetting(value, MAX_ACCOUNT_NAME_LENGTH, allowEmpty === true)
}

function validProfileName(value) {
  return validNamedSetting(value, MAX_PROFILE_NAME_LENGTH, false)
}

function validAdapterName(value) {
  var text = String(value || "")
  return text.length >= 1 && text.length <= 15
    && /^[A-Za-z0-9][A-Za-z0-9_.:-]*$/.test(text)
}

function settingsError(accountName, profileName, adapterName) {
  if (!validAccountName(accountName, true)) return "Invalid preferred SoftEther account setting"
  if (!validProfileName(profileName)) return "Invalid NetworkManager profile setting"
  if (!validAdapterName(adapterName)) return "Invalid virtual adapter setting"
  return ""
}

function elideError(value) {
  var text = String(value || "")
  if (text.length > 4096) text = text.substring(0, 4096)
  text = text.replace(/\s+/g, " ").trim()
  return text.length > 180 ? text.substring(0, 177) + "…" : text
}

function tableRow(line) {
  var text = bounded(line, MAX_ROW_CHARS)
  if (text === null) return null
  var separator = text.indexOf("|")
  if (separator < 0) return null
  var key = text.substring(0, separator).trim()
  var value = decoded(text.substring(separator + 1))
  if (key.length === 0 || key.length > 128 || value.length > MAX_FIELD_CHARS) return null
  return {
    key: key,
    value: value
  }
}

function statusKind(value) {
  var status = String(value || "").trim().toLowerCase()
  if (/disconnect|offline|not connected|disabled|stopped/.test(status)) return "offline"
  if (/connecting|retry|negotiat/.test(status)) return "connecting"
  if (/connected|online|established/.test(status)) return "connected"
  return status === "" ? "offline" : "unknown"
}

function presentationState(options) {
  var state = options || {}
  if (!state.installed || !state.serviceAvailable) return "error"
  if (String(state.lastError || "") !== "") return "error"

  // A requested disconnect is optimistically off. NetworkManager removes the
  // address and route before AccountList reports Offline, and treating that
  // expected gap as an unusable connection produces a false warning badge.
  if (state.desiredState === 0 || state.actionKind === "disconnect") return "off"
  if (state.actionKind === "connect" || state.desiredState === 1 || state.connecting)
    return "connecting"
  if (state.connected && !state.usable) return "warning"
  if (state.connected) return "on"
  return "off"
}

function shouldPulse(actionKind) {
  return String(actionKind || "") === "connect"
}

function parseAccountList(raw) {
  var input = bounded(raw, MAX_COMMAND_CHARS)
  if (input === null) return []
  var lines = input.split(/\r?\n/)
  if (lines.length > MAX_LINES) return []
  var accounts = []
  var current = null
  var seen = {}

  function finish() {
    if (!current || !validAccountName(current.name, false)) return
    if (accounts.length >= MAX_ACCOUNTS || seen[current.name]) return
    current.statusKind = statusKind(current.status)
    accounts.push(current)
    seen[current.name] = true
  }

  for (var i = 0; i < lines.length; i++) {
    var row = tableRow(lines[i])
    if (!row) continue
    var key = row.key.toLowerCase()

    if (/^(vpn connection setting name|account name|connection setting name)$/.test(key)) {
      finish()
      current = { name: row.value, status: "Offline", server: "", hub: "", adapter: "" }
      continue
    }
    if (!current) continue
    if (key === "status" || key === "connection status") current.status = row.value
    else if (key === "vpn server hostname" || key === "server hostname") current.server = row.value
    else if (key === "virtual hub" || key === "virtual hub name") current.hub = row.value
    else if (key === "virtual network adapter name") current.adapter = row.value
  }
  finish()
  return accounts
}

function parseAddress(raw) {
  try {
    var input = bounded(raw, MAX_NETWORK_CHARS)
    if (input === null) return ""
    var devices = JSON.parse(input || "[]")
    if (!Array.isArray(devices) || devices.length > MAX_JSON_ITEMS) return ""
    for (var i = 0; i < devices.length; i++) {
      var addresses = devices[i].addr_info || []
      if (!Array.isArray(addresses) || addresses.length > MAX_JSON_ITEMS) return ""
      for (var j = 0; j < addresses.length; j++) {
        var address = addresses[j] || {}
        var local = String(address.local || "")
        if (address.scope === "global" && (address.family === "inet" || address.family === "inet6")
            && local.length >= 2 && local.length <= 64 && /^[0-9A-Fa-f:.]+$/.test(local))
          return local
      }
    }
  } catch (e) {
  }
  return ""
}

function hasDefaultRoute(raw, adapterName) {
  try {
    var input = bounded(raw, MAX_NETWORK_CHARS)
    if (input === null || !validAdapterName(adapterName)) return false
    var routes = JSON.parse(input || "[]")
    if (!Array.isArray(routes) || routes.length > MAX_JSON_ITEMS) return false
    var adapter = String(adapterName || "")
    for (var i = 0; i < routes.length; i++) {
      var route = routes[i] || {}
      var destination = String(route.dst || "default")
      var device = String(route.dev || "")
      if (destination.length <= 64 && device.length <= 15
          && destination === "default" && device === adapter)
        return true
    }
  } catch (e) {
  }
  return false
}

if (typeof module !== "undefined") {
  module.exports = {
    decoded: decoded,
    bounded: bounded,
    validAccountName: validAccountName,
    validProfileName: validProfileName,
    validAdapterName: validAdapterName,
    settingsError: settingsError,
    elideError: elideError,
    tableRow: tableRow,
    statusKind: statusKind,
    presentationState: presentationState,
    shouldPulse: shouldPulse,
    parseAccountList: parseAccountList,
    parseAddress: parseAddress,
    hasDefaultRoute: hasDefaultRoute
  }
}

function decoded(value) {
  return String(value || "").replace(/\$20/g, " ").trim()
}

function tableRow(line) {
  var text = String(line || "")
  var separator = text.indexOf("|")
  if (separator < 0) return null
  return {
    key: text.substring(0, separator).trim(),
    value: decoded(text.substring(separator + 1))
  }
}

function statusKind(value) {
  var status = String(value || "").trim().toLowerCase()
  if (/disconnect|offline|not connected|disabled|stopped/.test(status)) return "offline"
  if (/connecting|retry|negotiat/.test(status)) return "connecting"
  if (/connected|online|established/.test(status)) return "connected"
  return status === "" ? "offline" : "unknown"
}

function parseAccountList(raw) {
  var lines = String(raw || "").split(/\r?\n/)
  var accounts = []
  var current = null

  function finish() {
    if (!current || !current.name) return
    current.statusKind = statusKind(current.status)
    accounts.push(current)
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
    var devices = JSON.parse(String(raw || "[]"))
    for (var i = 0; i < devices.length; i++) {
      var addresses = devices[i].addr_info || []
      for (var j = 0; j < addresses.length; j++) {
        var address = addresses[j] || {}
        if (address.scope === "global" && (address.family === "inet" || address.family === "inet6"))
          return String(address.local || "")
      }
    }
  } catch (e) {
  }
  return ""
}

function hasDefaultRoute(raw, adapterName) {
  try {
    var routes = JSON.parse(String(raw || "[]"))
    var adapter = String(adapterName || "")
    for (var i = 0; i < routes.length; i++) {
      var route = routes[i] || {}
      if (String(route.dst || "default") === "default" && String(route.dev || "") === adapter)
        return true
    }
  } catch (e) {
  }
  return false
}

if (typeof module !== "undefined") {
  module.exports = {
    decoded: decoded,
    tableRow: tableRow,
    statusKind: statusKind,
    parseAccountList: parseAccountList,
    parseAddress: parseAddress,
    hasDefaultRoute: hasDefaultRoute
  }
}

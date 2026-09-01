const assert = require("node:assert/strict")
const model = require("../Model.js")

const ready = {
  installed: true,
  serviceAvailable: true,
  lastError: "",
  actionKind: "",
  desiredState: -1,
  connecting: false,
  connected: false,
  usable: false
}

function state(overrides) {
  return model.presentationState({ ...ready, ...overrides })
}

assert.equal(state({}), "off")
assert.equal(state({ connected: true, usable: true }), "on")
assert.equal(state({ connecting: true }), "connecting")
assert.equal(state({ actionKind: "connect", desiredState: 1 }), "connecting")

// Startup status polling must not manufacture a connecting state.
assert.equal(state({ actionKind: "", desiredState: -1 }), "off")
assert.equal(model.shouldPulse(""), false)
assert.equal(model.shouldPulse("disconnect"), false)
assert.equal(model.shouldPulse("connect"), true)

// An externally reported connecting account can still be described accurately
// without playing an animation that implies the widget initiated the action.
assert.equal(state({ connecting: true }), "connecting")
assert.equal(model.shouldPulse(""), false)

// During a normal disconnect, the route can disappear before AccountList
// changes to Offline. That expected intermediate state must not turn red.
assert.equal(state({
  actionKind: "disconnect",
  desiredState: 0,
  connected: true,
  usable: false
}), "off")

assert.equal(state({ connected: true, usable: false }), "warning")
assert.equal(state({ lastError: "command failed", desiredState: 0 }), "error")
assert.equal(state({ installed: false }), "error")

assert.equal(model.validAccountName("Test VPN Germany", false), true)
assert.equal(model.validAccountName("", true), true)
assert.equal(model.validAccountName("<b>unsafe</b>", false), false)
assert.equal(model.validAccountName("line\nbreak", false), false)
assert.equal(model.validAccountName("A".repeat(129), false), false)
assert.equal(model.validProfileName("SoftEther VPN Network"), true)
assert.equal(model.validProfileName("profile|route-state", false), false)
assert.equal(model.validAdapterName("vpn_vpn"), true)
assert.equal(model.validAdapterName("adapter/name"), false)
assert.equal(model.validAdapterName("a".repeat(16)), false)
assert.equal(model.settingsError("", "SoftEther VPN Network", "vpn_vpn"), "")
assert.match(model.settingsError("", "bad\nprofile", "vpn_vpn"), /NetworkManager/)

const accountRow = [
  "VPN Connection Setting Name | Test VPN Germany",
  "Status | Connected",
  "VPN Server Hostname | vpn.example.com"
].join("\n")
assert.equal(model.parseAccountList(accountRow).length, 1)
assert.equal(model.parseAccountList("A".repeat(65537)).length, 0)
assert.equal(model.parseAccountList("x\n".repeat(1025)).length, 0)
assert.equal(model.parseAccountList(
  "VPN Connection Setting Name | <b>unsafe</b>\nStatus | Connected").length, 0)

const manyAccounts = Array.from({ length: 140 }, (_, index) =>
  `VPN Connection Setting Name | VPN ${index}\nStatus | Offline`).join("\n")
assert.equal(model.parseAccountList(manyAccounts).length, 128)

assert.equal(model.parseAddress("x".repeat(32769)), "")
assert.equal(model.parseAddress(JSON.stringify(Array.from({ length: 129 }, () => ({})))), "")
assert.equal(model.hasDefaultRoute("x".repeat(32769), "vpn_vpn"), false)
assert.equal(model.hasDefaultRoute(JSON.stringify(Array.from({ length: 129 }, () => ({}))), "vpn_vpn"), false)
assert.ok(model.elideError("x".repeat(5000)).length <= 180)
assert.ok(model.elideError("x".repeat(5000)).endsWith("…"))

console.log("model state tests passed")

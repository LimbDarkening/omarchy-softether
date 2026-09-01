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

console.log("model state tests passed")

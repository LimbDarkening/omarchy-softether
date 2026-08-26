const assert = require("node:assert/strict")
const lookup = require("../CountryLookup.js")

const cases = [
  ["Premiumize.me - Netherlands", "NL", "Netherlands", "🇳🇱"],
  ["Work VPN Germany 02", "DE", "Germany", "🇩🇪"],
  ["London - Great Britain", "GB", "United Kingdom", "🇬🇧"],
  ["us-west-01", "US", "United States", "🇺🇸"],
  ["Seoul South Korea #3", "KR", "South Korea", "🇰🇷"],
  ["Congo Kinshasa", "CD", "Democratic Republic of the Congo", "🇨🇩"],
  ["Provider-NL-Amsterdam", "NL", "Netherlands", "🇳🇱"]
]

for (const [accountName, code, label, flag] of cases) {
  assert.deepEqual(lookup.countryDetails(accountName), { code, label, flag })
}

assert.deepEqual(lookup.countryDetails("Provider - Atlantis"), {
  code: "",
  label: "Atlantis",
  flag: "🏳"
})

assert.equal(lookup.countryDetails("Premium in Germany").code, "DE")
assert.equal(lookup.countryDetails("Premium in transit").code, "")

console.log("country lookup tests passed")

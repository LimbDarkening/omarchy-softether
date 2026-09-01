var COUNTRY_DATA = [
  ["AD", "Andorra"],
  ["AE", "United Arab Emirates"],
  ["AF", "Afghanistan"],
  ["AG", "Antigua & Barbuda"],
  ["AI", "Anguilla"],
  ["AL", "Albania"],
  ["AM", "Armenia"],
  ["AO", "Angola"],
  ["AQ", "Antarctica"],
  ["AR", "Argentina"],
  ["AS", "Samoa (American)"],
  ["AT", "Austria"],
  ["AU", "Australia"],
  ["AW", "Aruba"],
  ["AX", "Åland Islands"],
  ["AZ", "Azerbaijan"],
  ["BA", "Bosnia & Herzegovina"],
  ["BB", "Barbados"],
  ["BD", "Bangladesh"],
  ["BE", "Belgium"],
  ["BF", "Burkina Faso"],
  ["BG", "Bulgaria"],
  ["BH", "Bahrain"],
  ["BI", "Burundi"],
  ["BJ", "Benin"],
  ["BL", "St Barthelemy"],
  ["BM", "Bermuda"],
  ["BN", "Brunei"],
  ["BO", "Bolivia"],
  ["BQ", "Caribbean NL"],
  ["BR", "Brazil"],
  ["BS", "Bahamas"],
  ["BT", "Bhutan"],
  ["BV", "Bouvet Island"],
  ["BW", "Botswana"],
  ["BY", "Belarus"],
  ["BZ", "Belize"],
  ["CA", "Canada"],
  ["CC", "Cocos (Keeling) Islands"],
  ["CD", "Congo (Dem. Rep.)"],
  ["CF", "Central African Rep."],
  ["CG", "Congo (Rep.)"],
  ["CH", "Switzerland"],
  ["CI", "Côte d’Ivoire"],
  ["CK", "Cook Islands"],
  ["CL", "Chile"],
  ["CM", "Cameroon"],
  ["CN", "China"],
  ["CO", "Colombia"],
  ["CR", "Costa Rica"],
  ["CU", "Cuba"],
  ["CV", "Cape Verde"],
  ["CW", "Curaçao"],
  ["CX", "Christmas Island"],
  ["CY", "Cyprus"],
  ["CZ", "Czech Republic"],
  ["DE", "Germany"],
  ["DJ", "Djibouti"],
  ["DK", "Denmark"],
  ["DM", "Dominica"],
  ["DO", "Dominican Republic"],
  ["DZ", "Algeria"],
  ["EC", "Ecuador"],
  ["EE", "Estonia"],
  ["EG", "Egypt"],
  ["EH", "Western Sahara"],
  ["ER", "Eritrea"],
  ["ES", "Spain"],
  ["ET", "Ethiopia"],
  ["FI", "Finland"],
  ["FJ", "Fiji"],
  ["FK", "Falkland Islands"],
  ["FM", "Micronesia"],
  ["FO", "Faroe Islands"],
  ["FR", "France"],
  ["GA", "Gabon"],
  ["GB", "Britain (UK)"],
  ["GD", "Grenada"],
  ["GE", "Georgia"],
  ["GF", "French Guiana"],
  ["GG", "Guernsey"],
  ["GH", "Ghana"],
  ["GI", "Gibraltar"],
  ["GL", "Greenland"],
  ["GM", "Gambia"],
  ["GN", "Guinea"],
  ["GP", "Guadeloupe"],
  ["GQ", "Equatorial Guinea"],
  ["GR", "Greece"],
  ["GS", "South Georgia & the South Sandwich Islands"],
  ["GT", "Guatemala"],
  ["GU", "Guam"],
  ["GW", "Guinea-Bissau"],
  ["GY", "Guyana"],
  ["HK", "Hong Kong"],
  ["HM", "Heard Island & McDonald Islands"],
  ["HN", "Honduras"],
  ["HR", "Croatia"],
  ["HT", "Haiti"],
  ["HU", "Hungary"],
  ["ID", "Indonesia"],
  ["IE", "Ireland"],
  ["IL", "Israel"],
  ["IM", "Isle of Man"],
  ["IN", "India"],
  ["IO", "British Indian Ocean Territory"],
  ["IQ", "Iraq"],
  ["IR", "Iran"],
  ["IS", "Iceland"],
  ["IT", "Italy"],
  ["JE", "Jersey"],
  ["JM", "Jamaica"],
  ["JO", "Jordan"],
  ["JP", "Japan"],
  ["KE", "Kenya"],
  ["KG", "Kyrgyzstan"],
  ["KH", "Cambodia"],
  ["KI", "Kiribati"],
  ["KM", "Comoros"],
  ["KN", "St Kitts & Nevis"],
  ["KP", "Korea (North)"],
  ["KR", "Korea (South)"],
  ["KW", "Kuwait"],
  ["KY", "Cayman Islands"],
  ["KZ", "Kazakhstan"],
  ["LA", "Laos"],
  ["LB", "Lebanon"],
  ["LC", "St Lucia"],
  ["LI", "Liechtenstein"],
  ["LK", "Sri Lanka"],
  ["LR", "Liberia"],
  ["LS", "Lesotho"],
  ["LT", "Lithuania"],
  ["LU", "Luxembourg"],
  ["LV", "Latvia"],
  ["LY", "Libya"],
  ["MA", "Morocco"],
  ["MC", "Monaco"],
  ["MD", "Moldova"],
  ["ME", "Montenegro"],
  ["MF", "St Martin (French)"],
  ["MG", "Madagascar"],
  ["MH", "Marshall Islands"],
  ["MK", "North Macedonia"],
  ["ML", "Mali"],
  ["MM", "Myanmar (Burma)"],
  ["MN", "Mongolia"],
  ["MO", "Macau"],
  ["MP", "Northern Mariana Islands"],
  ["MQ", "Martinique"],
  ["MR", "Mauritania"],
  ["MS", "Montserrat"],
  ["MT", "Malta"],
  ["MU", "Mauritius"],
  ["MV", "Maldives"],
  ["MW", "Malawi"],
  ["MX", "Mexico"],
  ["MY", "Malaysia"],
  ["MZ", "Mozambique"],
  ["NA", "Namibia"],
  ["NC", "New Caledonia"],
  ["NE", "Niger"],
  ["NF", "Norfolk Island"],
  ["NG", "Nigeria"],
  ["NI", "Nicaragua"],
  ["NL", "Netherlands"],
  ["NO", "Norway"],
  ["NP", "Nepal"],
  ["NR", "Nauru"],
  ["NU", "Niue"],
  ["NZ", "New Zealand"],
  ["OM", "Oman"],
  ["PA", "Panama"],
  ["PE", "Peru"],
  ["PF", "French Polynesia"],
  ["PG", "Papua New Guinea"],
  ["PH", "Philippines"],
  ["PK", "Pakistan"],
  ["PL", "Poland"],
  ["PM", "St Pierre & Miquelon"],
  ["PN", "Pitcairn"],
  ["PR", "Puerto Rico"],
  ["PS", "Palestine"],
  ["PT", "Portugal"],
  ["PW", "Palau"],
  ["PY", "Paraguay"],
  ["QA", "Qatar"],
  ["RE", "Réunion"],
  ["RO", "Romania"],
  ["RS", "Serbia"],
  ["RU", "Russia"],
  ["RW", "Rwanda"],
  ["SA", "Saudi Arabia"],
  ["SB", "Solomon Islands"],
  ["SC", "Seychelles"],
  ["SD", "Sudan"],
  ["SE", "Sweden"],
  ["SG", "Singapore"],
  ["SH", "St Helena"],
  ["SI", "Slovenia"],
  ["SJ", "Svalbard & Jan Mayen"],
  ["SK", "Slovakia"],
  ["SL", "Sierra Leone"],
  ["SM", "San Marino"],
  ["SN", "Senegal"],
  ["SO", "Somalia"],
  ["SR", "Suriname"],
  ["SS", "South Sudan"],
  ["ST", "Sao Tome & Principe"],
  ["SV", "El Salvador"],
  ["SX", "St Maarten (Dutch)"],
  ["SY", "Syria"],
  ["SZ", "Eswatini (Swaziland)"],
  ["TC", "Turks & Caicos Is"],
  ["TD", "Chad"],
  ["TF", "French S. Terr."],
  ["TG", "Togo"],
  ["TH", "Thailand"],
  ["TJ", "Tajikistan"],
  ["TK", "Tokelau"],
  ["TL", "East Timor"],
  ["TM", "Turkmenistan"],
  ["TN", "Tunisia"],
  ["TO", "Tonga"],
  ["TR", "Turkey"],
  ["TT", "Trinidad & Tobago"],
  ["TV", "Tuvalu"],
  ["TW", "Taiwan"],
  ["TZ", "Tanzania"],
  ["UA", "Ukraine"],
  ["UG", "Uganda"],
  ["UM", "US minor outlying islands"],
  ["US", "United States"],
  ["UY", "Uruguay"],
  ["UZ", "Uzbekistan"],
  ["VA", "Vatican City"],
  ["VC", "St Vincent"],
  ["VE", "Venezuela"],
  ["VG", "Virgin Islands (UK)"],
  ["VI", "Virgin Islands (US)"],
  ["VN", "Vietnam"],
  ["VU", "Vanuatu"],
  ["WF", "Wallis & Futuna"],
  ["WS", "Samoa (western)"],
  ["YE", "Yemen"],
  ["YT", "Mayotte"],
  ["ZA", "South Africa"],
  ["ZM", "Zambia"],
  ["ZW", "Zimbabwe"],
]

var COUNTRY_ALIASES = {
  "AE": ["United Arab Emirates", "UAE"],
  "AS": ["American Samoa"],
  "BO": ["Bolivia"],
  "BQ": ["Bonaire", "Caribbean Netherlands"],
  "BN": ["Brunei"],
  "CC": ["Cocos Islands", "Keeling Islands"],
  "CD": ["Democratic Republic of the Congo", "DR Congo", "Congo Kinshasa"],
  "CG": ["Republic of the Congo", "Congo Brazzaville"],
  "CI": ["Cote d Ivoire", "Ivory Coast"],
  "CV": ["Cape Verde"],
  "CZ": ["Czechia", "Czech Republic"],
  "DE": ["Deutschland"],
  "ES": ["Espana"],
  "FK": ["Falkland Islands"],
  "FM": ["Micronesia"],
  "GB": ["United Kingdom", "Great Britain", "Britain", "England", "Scotland", "Wales", "Northern Ireland", "UK"],
  "GR": ["Hellas"],
  "HK": ["Hong Kong"],
  "IO": ["British Indian Ocean Territory"],
  "IR": ["Iran"],
  "KP": ["North Korea", "Korea North"],
  "KR": ["South Korea", "Korea South", "Republic of Korea"],
  "LA": ["Laos"],
  "MD": ["Moldova"],
  "MM": ["Myanmar", "Burma"],
  "MO": ["Macau", "Macao"],
  "MK": ["North Macedonia", "Macedonia"],
  "NL": ["Holland"],
  "PS": ["Palestine", "Palestinian Territories"],
  "RE": ["Reunion"],
  "RU": ["Russia", "Russian Federation"],
  "SH": ["Saint Helena"],
  "SY": ["Syria"],
  "SZ": ["Eswatini", "Swaziland"],
  "TW": ["Taiwan"],
  "TZ": ["Tanzania"],
  "TR": ["Turkey", "Turkiye"],
  "US": ["United States", "United States of America", "America", "USA", "US"],
  "VA": ["Vatican", "Vatican City"],
  "VE": ["Venezuela"],
  "VG": ["British Virgin Islands"],
  "VI": ["US Virgin Islands", "United States Virgin Islands"],
  "VN": ["Vietnam", "Viet Nam"]
}

var COUNTRY_LABELS = {
  "AS": "American Samoa",
  "BQ": "Caribbean Netherlands",
  "CD": "Democratic Republic of the Congo",
  "CG": "Republic of the Congo",
  "FK": "Falkland Islands",
  "GB": "United Kingdom",
  "IO": "British Indian Ocean Territory",
  "KP": "North Korea",
  "KR": "South Korea",
  "MM": "Myanmar",
  "PN": "Pitcairn Islands",
  "SH": "Saint Helena",
  "SJ": "Svalbard and Jan Mayen",
  "SX": "Sint Maarten",
  "TC": "Turks and Caicos Islands",
  "UM": "United States Minor Outlying Islands",
  "VG": "British Virgin Islands",
  "VI": "U.S. Virgin Islands",
  "WS": "Samoa"
}

function decoded(value) {
  return String(value || "").substring(0, 128).replace(/\$20/g, " ").trim()
}

function normalizedWords(value) {
  var text = decoded(value).toLowerCase()
  try {
    text = text.normalize("NFD").replace(/[\u0300-\u036f]/g, "")
  } catch (error) {
  }
  return text
    .replace(/&/g, " and ")
    .replace(/[^a-z0-9]+/g, " ")
    .replace(/\s+/g, " ")
    .trim()
}

function definitionForCode(code) {
  var expected = String(code || "").toUpperCase()
  for (var i = 0; i < COUNTRY_DATA.length; i++)
    if (COUNTRY_DATA[i][0] === expected)
      return {
        code: COUNTRY_DATA[i][0],
        label: COUNTRY_LABELS[expected] || COUNTRY_DATA[i][1]
      }
  return null
}

function buildCandidates() {
  var candidates = []
  for (var i = 0; i < COUNTRY_DATA.length; i++) {
    var code = COUNTRY_DATA[i][0]
    var sourceLabel = COUNTRY_DATA[i][1]
    var label = COUNTRY_LABELS[code] || sourceLabel
    var aliases = [sourceLabel, label].concat(COUNTRY_ALIASES[code] || [])
    for (var j = 0; j < aliases.length; j++) {
      var normalized = normalizedWords(aliases[j])
      if (normalized !== "")
        candidates.push({ code: code, label: label, alias: normalized })
    }
  }
  candidates.sort(function(left, right) {
    return right.alias.length - left.alias.length
  })
  return candidates
}

var COUNTRY_CANDIDATES = buildCandidates()

function flagForCode(code) {
  var normalized = String(code || "").trim().toUpperCase()
  if (!/^[A-Z]{2}$/.test(normalized)) return "🏳"
  return String.fromCodePoint(
    0x1F1E6 + normalized.charCodeAt(0) - 65,
    0x1F1E6 + normalized.charCodeAt(1) - 65
  )
}

function inferredDefinition(accountName) {
  var paddedName = " " + normalizedWords(accountName) + " "
  for (var i = 0; i < COUNTRY_CANDIDATES.length; i++) {
    var candidate = COUNTRY_CANDIDATES[i]
    if (paddedName.indexOf(" " + candidate.alias + " ") !== -1)
      return { code: candidate.code, label: candidate.label }
  }

  var tokens = String(accountName || "").substring(0, 128).split(/[^A-Za-z]+/)
  for (var j = 0; j < tokens.length; j++) {
    if (/^[A-Z]{2}$/.test(tokens[j])) {
      var definition = definitionForCode(tokens[j])
      if (definition) return definition
    }
  }
  return null
}

function fallbackLabel(accountName) {
  var name = decoded(accountName)
  var pieces = name.split(/\s+-\s+/)
  if (pieces.length > 1 && pieces[pieces.length - 1].trim() !== "")
    return pieces[pieces.length - 1].trim()
  return name || "Unknown"
}

function countryDetails(accountName) {
  var definition = inferredDefinition(accountName)
  if (!definition)
    return { code: "", label: fallbackLabel(accountName), flag: "🏳" }
  return {
    code: definition.code,
    label: definition.label,
    flag: flagForCode(definition.code)
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    normalizedWords: normalizedWords,
    definitionForCode: definitionForCode,
    flagForCode: flagForCode,
    inferredDefinition: inferredDefinition,
    fallbackLabel: fallbackLabel,
    countryDetails: countryDetails
  }
}

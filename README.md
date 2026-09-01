# SoftEther VPN for Omarchy

A native Omarchy bar widget for controlling imported SoftEther VPN Client
accounts.

## Features

- Left-click the shield to connect or disconnect the selected account.
- Left-click the flag, or right-click the widget, to choose an imported account.
- Middle-click to refresh the current status.
- Recognizes country names and common aliases anywhere in account names and
  renders the corresponding flag without network lookups.
- Reports the VPN as usable only after SoftEther is connected, the virtual
  adapter has an address, and the adapter owns a default route.
- Protects the VPN server's physical route before making the tunnel the default
  route, preventing the tunnel from trying to carry its own transport.

## Requirements

- Omarchy 4 or later.
- SoftEther VPN Client with `vpncmd` available on `PATH`.
- NetworkManager and `nmcli`.
- `ip` from `iproute2`, plus the standard `timeout`, `getent`, `flock`, and
  coreutils command-line tools included with Omarchy.
- At least one account already imported into SoftEther VPN Client.
- A SoftEther virtual adapter and a matching NetworkManager TAP profile.

The default adapter is `vpn_vpn`, and the default NetworkManager profile is
`SoftEther VPN Network`. Create that profile with:

```bash
nmcli connection add type tun ifname vpn_vpn \
  con-name "SoftEther VPN Network" mode tap \
  ipv4.method auto ipv6.method auto connection.autoconnect no
```

Both names can be changed later in the widget settings.

For safety, account and NetworkManager profile names must be 1–128 ASCII
characters, start with a letter or number, and contain only letters, numbers,
single spaces, or `. _ @ ( ) + , # % = -`. Linux adapter names must be 1–15
characters and contain only letters, numbers, `. _ : -`.

## Installation

```bash
omarchy plugin add https://github.com/limbdarkening/omarchy-softether.git --enable
```

The widget appears in the right section of the bar by default. Open the
Omarchy bar settings to choose the preferred SoftEther account, adapter,
NetworkManager profile, and refresh interval.

## Privacy and security

The plugin does not collect telemetry, contact an analytics service, read VPN
profile files, or store credentials. It asks the local SoftEther client for
account status through `vpncmd` and manages the selected connection and routes
through `vpncmd`, `nmcli`, and `ip`.

All helper processes have TERM and forced-KILL deadlines. Individual command
results are limited to at most 64 KiB and 1,024 lines, with tighter limits for
network and account-detail queries. The model accepts at most 128 accounts or
network records and eight resolved server addresses; rows, identifiers, and
display strings have separate length limits. Values obtained from external
commands are rendered as plain text.

The temporary transport-route record is kept under the current user's private
XDG runtime directory. Its directory is pinned for the lifetime of each helper
process, actions are serialized, and the mode-`0600` state file is created
privately and published with an atomic rename. Existing symlinks and state with
unexpected type, ownership, permissions, link count, size, or contents are
rejected without being followed.

Omarchy plugins execute as unsandboxed user code. Review the source before
enabling any third-party plugin.

## Updating

```bash
omarchy plugin update io.github.limbdarkening.softether
```

## Removal

```bash
omarchy plugin remove io.github.limbdarkening.softether
```

## License

MIT

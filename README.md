# SoftEther VPN for Omarchy

A native Omarchy bar widget for controlling imported SoftEther VPN Client
accounts.

## Features

- Left-click to connect or disconnect the selected account.
- Right-click to choose an imported account.
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

## Installation

After this repository is public:

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

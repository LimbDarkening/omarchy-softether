#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

project_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
control="$project_root/softether-control"
fixture="$project_root/test/fixtures/fake-command"
test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT

runtime_dir="$test_root/runtime"
fake_bin="$test_root/bin"
command_log="$test_root/commands.log"
mkdir -m 700 -- "$runtime_dir" "$fake_bin"
for command_name in vpncmd nmcli ip getent; do
  ln -s -- "$fixture" "$fake_bin/$command_name"
done

export PATH="$fake_bin:$PATH"
export XDG_RUNTIME_DIR="$runtime_dir"
export FAKE_COMMAND_LOG="$command_log"

runtime_link="$test_root/runtime-link"
ln -s -- "$runtime_dir" "$runtime_link"
if XDG_RUNTIME_DIR="$runtime_link" $control accounts >/dev/null 2>&1; then
  printf 'symlink XDG runtime directory was accepted\n' >&2
  exit 1
fi

linked_state_runtime="$test_root/linked-state-runtime"
linked_state_target="$test_root/linked-state-target"
mkdir -m 700 -- "$linked_state_runtime" "$linked_state_target"
ln -s -- "$linked_state_target" "$linked_state_runtime/softether-vpn"
if XDG_RUNTIME_DIR="$linked_state_runtime" $control accounts >/dev/null 2>&1; then
  printf 'symlink runtime state directory was accepted\n' >&2
  exit 1
fi

accounts=$($control accounts)
[[ $accounts == *'Test VPN Germany'* ]]
[[ $($control address vpn_vpn) == *'10.0.0.2'* ]]
[[ $($control routes) == *'"dev":"vpn_vpn"'* ]]

if $control disconnect '<b>unsafe</b>' 'SoftEther VPN Network' vpn_vpn >/dev/null 2>&1; then
  printf 'unsafe account name was accepted\n' >&2
  exit 1
fi
if $control disconnect 'Test VPN Germany' 'SoftEther VPN Network' 'adapter/name' >/dev/null 2>&1; then
  printf 'unsafe adapter name was accepted\n' >&2
  exit 1
fi

if FAKE_OVERSIZED_OUTPUT=1 $control accounts >/dev/null 2>&1; then
  printf 'oversized command output was accepted\n' >&2
  exit 1
fi
if FAKE_EXCESS_LINES=1 $control accounts >/dev/null 2>&1; then
  printf 'excessive command-output lines were accepted\n' >&2
  exit 1
fi
deadline_started=$SECONDS
if FAKE_TERM_RESISTANT=1 timeout --signal=TERM --kill-after=1s 12s \
    $control accounts >/dev/null 2>&1; then
  printf 'TERM-resistant command was accepted\n' >&2
  exit 1
fi
((SECONDS - deadline_started < 12)) || {
  printf 'TERM-resistant command exceeded its cleanup deadline\n' >&2
  exit 1
}

state_dir="$runtime_dir/softether-vpn"
victim="$test_root/victim"
printf '%s\n' 'must remain unchanged' > "$victim"
ln -s -- "$victim" "$state_dir/transport-route"
if $control disconnect 'Test VPN Germany' 'SoftEther VPN Network' vpn_vpn >/dev/null 2>&1; then
  printf 'symlink route state was accepted\n' >&2
  exit 1
fi
[[ $(<"$victim") == 'must remain unchanged' ]]
[[ ! -e $state_dir/transport-route && ! -L $state_dir/transport-route ]]

FAKE_CONNECTION_DELAY=1 $control connect 'Test VPN Germany' 'SoftEther VPN Network' vpn_vpn &
connect_pid=$!
sleep 0.1
if $control disconnect 'Test VPN Germany' 'SoftEther VPN Network' vpn_vpn >/dev/null 2>&1; then
  printf 'concurrent VPN action was accepted\n' >&2
  exit 1
fi
wait "$connect_pid"
[[ -f $state_dir/transport-route && ! -L $state_dir/transport-route ]]
[[ $(stat -c '%a' -- "$state_dir/transport-route") == 600 ]]
[[ $(stat -c '%u' -- "$state_dir/transport-route") == "$UID" ]]
[[ $(wc -l < "$state_dir/transport-route") -le 8 ]]

$control disconnect 'Test VPN Germany' 'SoftEther VPN Network' vpn_vpn
[[ ! -e $state_dir/transport-route && ! -L $state_dir/transport-route ]]
grep -F -- '<-ipv4.routes> <198.51.100.10/32 192.0.2.1>' "$command_log" >/dev/null

printf 'security hardening tests passed\n'

#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  exec sudo --preserve-env=DONT_TOUCH_IPTABLES /usr/bin/env bash "$0" "$@"
fi

# systemd-run --collect --unit=no-proxy --user --pty --shell

FWMARK="${FWMARK:-0x8964}"
TABLE="${TABLE:-100}"
# /system.slice/coredns.service
CGROUP="${CGROUP:-/user.slice/user-1000.slice/user@1000.service/app.slice/no-proxy.service}"

if [[ -z "$(ip rule list fwmark "$FWMARK" table "$TABLE")" ]]; then
  ip rule add fwmark "$FWMARK" table "$TABLE" 
fi
default_route_table="$(ip route show default)"
default_link="$(ip -j route show default | grep -E -o '"dev":\s*"([^"]*)"' | awk -F\" '{print $4}')"
ip route replace $default_route_table table "$TABLE"

iptables -t mangle -I OUTPUT -m cgroup --path "$CGROUP" -j MARK --set-mark "$FWMARK"
iptables -t nat -A POSTROUTING -o "$default_link" -j MASQUERADE

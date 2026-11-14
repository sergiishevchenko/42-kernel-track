#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
LOG="proof.log"

if [ "$(id -u)" -ne 0 ]; then
	echo "Run as root."
	exit 1
fi

find_keyboard_interface() {
	local iface

	for iface in /sys/bus/usb/devices/*:*; do
		[ -f "$iface/bInterfaceClass" ] || continue
		if [ "$(cat "$iface/bInterfaceClass")" = "03" ] &&
			[ "$(cat "$iface/bInterfaceSubClass")" = "01" ] &&
			[ "$(cat "$iface/bInterfaceProtocol")" = "01" ]; then
			echo "$iface"
			return 0
		fi
	done
	return 1
}

make
make install install-udev
rmmod main 2>/dev/null || true
dmesg -C

{
	echo "=== uname -r ==="
	uname -r
	echo "=== modinfo -F alias main ==="
	modinfo -F alias main
	echo "=== /etc/udev/rules.d/99-keyboard.rules ==="
	cat /etc/udev/rules.d/99-keyboard.rules
	echo "=== lsmod before replug ==="
	lsmod | grep -E '^main\b' || echo "main is not loaded"
} 2>&1 | tee "$LOG"

IFACE="$(find_keyboard_interface || true)"
if [ -n "$IFACE" ]; then
	DEVICE="/sys/bus/usb/devices/$(basename "$IFACE" | cut -d: -f1)"
	{
		echo "=== USB keyboard interface: $(basename "$IFACE") ==="
		echo "=== udevadm test --action=add (rule match) ==="
		udevadm test --action=add "$(readlink -f "$IFACE")" 2>&1 |
			grep -E "99-keyboard|modprobe main" || echo "rule did not match"
		echo "=== replug: $(basename "$DEVICE")/authorized 0 -> 1 ==="
	} 2>&1 | tee -a "$LOG"
	echo 0 > "$DEVICE/authorized"
	sleep 1
	echo 1 > "$DEVICE/authorized"
	sleep 2
else
	echo "No USB keyboard found." | tee -a "$LOG"
	read -rp "Plug in a USB keyboard, then press Enter... "
	echo "=== keyboard plugged in by hand ===" >> "$LOG"
fi

{
	echo "=== lsmod after replug ==="
	lsmod | grep -E '^main\b' || echo "main is not loaded"
	echo "=== dmesg ==="
	dmesg
} 2>&1 | tee -a "$LOG"

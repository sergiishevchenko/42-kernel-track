#!/bin/bash
set -uo pipefail

ERR=0

check_cmd() {
	if command -v "$1" > /dev/null 2>&1; then
		echo "OK: $1"
	else
		echo "MISSING: $1 ${2:-}"
		ERR=1
	fi
}

check_path() {
	if [ -e "$1" ]; then
		echo "OK: $1"
	else
		echo "MISSING: $1 ${2:-}"
		ERR=1
	fi
}

if [ "$(id -u)" -ne 0 ]; then
	echo "WARNING: scripts in this repo expect to run as root on ft_linux"
fi

echo "=== Kernel build tools ==="
for cmd in gcc make ld bc flex bison perl tar xz openssl; do
	check_cmd "$cmd"
done
check_path /usr/include/openssl/ssl.h
check_path /usr/include/libelf.h "(elfutils)"

echo "=== Module and hotplug tools ==="
for cmd in depmod modprobe insmod rmmod lsmod modinfo udevadm dmesg mountpoint su useradd; do
	check_cmd "$cmd"
done

echo "=== Git ==="
check_cmd git "(run scripts/install-git.sh)"
if command -v git > /dev/null 2>&1; then
	git config --global user.name > /dev/null || {
		echo "MISSING: git config --global user.name"
		ERR=1
	}
	git config --global user.email > /dev/null || {
		echo "MISSING: git config --global user.email"
		ERR=1
	}
fi

echo "=== Network ==="
if command -v curl > /dev/null 2>&1 && curl -fsSI --max-time 10 https://git.kernel.org > /dev/null; then
	echo "OK: https://git.kernel.org reachable"
else
	echo "MISSING: HTTPS access to git.kernel.org"
	ERR=1
fi

echo "=== Disk space ==="
df -h / /boot 2>/dev/null

exit $ERR

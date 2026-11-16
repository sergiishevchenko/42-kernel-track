#!/bin/bash
set -euo pipefail

MODULE_DIR="${1:-.}"
MODULE_NAME="${2:-main}"

if [ "$(id -u)" -ne 0 ]; then
	echo "Run as root."
	exit 1
fi

cd "$MODULE_DIR"
make clean
make
rmmod "$MODULE_NAME" 2>/dev/null || true
insmod "${MODULE_NAME}.ko"
dmesg | tail -1
rmmod "$MODULE_NAME"
dmesg | tail -1

#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ASSIGNMENT="$REPO_ROOT/assignment-00"
KERNEL_DIR="${1:-/usr/src/little-penguin/linux}"

if [ ! -d "$KERNEL_DIR" ]; then
	echo "Kernel source not found at $KERNEL_DIR"
	echo "Run: scripts/build-kernel.sh torvalds"
	exit 1
fi

EXPECTED="$(make -s -C "$KERNEL_DIR" kernelrelease)"
RUNNING="$(uname -r)"
if [ "$RUNNING" != "$EXPECTED" ]; then
	echo "Running kernel is $RUNNING, expected $EXPECTED from $KERNEL_DIR."
	echo "Boot the freshly built kernel before collecting artifacts."
	exit 1
fi

if ! grep -q '^CONFIG_LOCALVERSION_AUTO=y' "$KERNEL_DIR/.config"; then
	echo "CONFIG_LOCALVERSION_AUTO=y is missing from $KERNEL_DIR/.config"
	exit 1
fi

cp "$KERNEL_DIR/.config" "$ASSIGNMENT/.config"
dmesg > "$ASSIGNMENT/kern.log"

echo "Saved assignment-00 artifacts for $RUNNING."

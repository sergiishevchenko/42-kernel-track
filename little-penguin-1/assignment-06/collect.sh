#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ASSIGNMENT="$REPO_ROOT/assignment-06"
KERNEL_DIR="${1:-/usr/src/little-penguin/linux-next}"

if [ ! -d "$KERNEL_DIR" ]; then
	echo "linux-next source not found at $KERNEL_DIR"
	echo "Run: scripts/build-kernel.sh linux-next"
	exit 1
fi

EXPECTED="$(make -s -C "$KERNEL_DIR" kernelrelease)"
RUNNING="$(uname -r)"
if [ "$RUNNING" != "$EXPECTED" ] || [[ "$RUNNING" != *-next-* ]]; then
	echo "Running kernel is $RUNNING, expected linux-next build $EXPECTED."
	echo "Boot the linux-next kernel before collecting artifacts."
	exit 1
fi

dmesg > "$ASSIGNMENT/kern.log"

echo "Saved assignment-06/kern.log for $RUNNING."

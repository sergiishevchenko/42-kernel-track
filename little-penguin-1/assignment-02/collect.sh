#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ASSIGNMENT="$REPO_ROOT/assignment-02"
KERNEL_DIR="${1:-/usr/src/little-penguin/linux}"

if [ ! -d "$KERNEL_DIR" ]; then
	echo "Kernel source not found at $KERNEL_DIR"
	echo "Run: scripts/build-kernel.sh thor"
	exit 1
fi

EXPECTED="$(make -s -C "$KERNEL_DIR" kernelrelease)"
RUNNING="$(uname -r)"
if [ "$RUNNING" != "$EXPECTED" ] || [[ "$RUNNING" != *-thor_kernel* ]]; then
	echo "Running kernel is $RUNNING, expected $EXPECTED with -thor_kernel."
	echo "Boot the thor_kernel build before collecting artifacts."
	exit 1
fi

CHANGED="$(git -C "$KERNEL_DIR" diff-tree --no-commit-id --name-only -r HEAD)"
if [ "$CHANGED" != "Makefile" ]; then
	echo "HEAD of $KERNEL_DIR must be the EXTRAVERSION commit touching only Makefile."
	exit 1
fi

git -C "$KERNEL_DIR" format-patch -1 --stdout HEAD > "$ASSIGNMENT/Makefile.patch"
dmesg > "$ASSIGNMENT/kern.log"

echo "=== checkpatch ==="
"$KERNEL_DIR/scripts/checkpatch.pl" "$ASSIGNMENT/Makefile.patch" || true

echo "Saved assignment-02 artifacts for $RUNNING."

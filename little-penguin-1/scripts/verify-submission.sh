#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ERR=0

check_file() {
	if [ ! -f "$1" ]; then
		echo "MISSING: $1"
		ERR=1
	else
		echo "OK: $1"
	fi
}

check_grep() {
	local description="$1"
	local pattern="$2"
	local file="$3"

	if grep -qE -- "$pattern" "$file" 2>/dev/null; then
		echo "OK: $description"
	else
		echo "FAIL: $description"
		ERR=1
	fi
}

check_no_grep() {
	local description="$1"
	local pattern="$2"
	local file="$3"

	if grep -qE -- "$pattern" "$file" 2>/dev/null; then
		echo "FAIL: $description"
		ERR=1
	else
		echo "OK: $description"
	fi
}

echo "=== Structure check ==="
check_file "$REPO_ROOT/assignment-00/kern.log"
check_file "$REPO_ROOT/assignment-00/.config"
check_file "$REPO_ROOT/assignment-01/main.c"
check_file "$REPO_ROOT/assignment-01/Makefile"
check_file "$REPO_ROOT/assignment-02/kern.log"
check_file "$REPO_ROOT/assignment-02/Makefile.patch"
check_file "$REPO_ROOT/assignment-03/fixed.c"
check_file "$REPO_ROOT/assignment-04/main.c"
check_file "$REPO_ROOT/assignment-04/Makefile"
check_file "$REPO_ROOT/assignment-04/99-keyboard.rules"
check_file "$REPO_ROOT/assignment-04/proof.log"
check_file "$REPO_ROOT/assignment-05/main.c"
check_file "$REPO_ROOT/assignment-05/Makefile"
check_file "$REPO_ROOT/assignment-05/proof.log"
check_file "$REPO_ROOT/assignment-06/kern.log"
check_file "$REPO_ROOT/assignment-07/main.c"
check_file "$REPO_ROOT/assignment-07/Makefile"
check_file "$REPO_ROOT/assignment-07/proof.log"
check_file "$REPO_ROOT/assignment-08/fixed.c"
check_file "$REPO_ROOT/assignment-09/main.c"
check_file "$REPO_ROOT/assignment-09/Makefile"

echo "=== Content check ==="
CONFIG="$REPO_ROOT/assignment-00/.config"
check_grep "CONFIG_LOCALVERSION_AUTO=y" '^CONFIG_LOCALVERSION_AUTO=y' "$CONFIG"

CONFIG_VERSION="$(sed -nE 's/^# Linux\/[^ ]+ ([^ ]+) Kernel Configuration$/\1/p' "$CONFIG" 2>/dev/null)"
for log in assignment-00 assignment-02 assignment-06; do
	check_no_grep "$log/kern.log is not a stock distro/Docker kernel" \
		'Linux version [^ ]*-(linuxkit|generic|amd64|arm64)' \
		"$REPO_ROOT/$log/kern.log"
done
check_grep "assignment-00/kern.log boots $CONFIG_VERSION from .config" \
	"Linux version ${CONFIG_VERSION//./\\.}" "$REPO_ROOT/assignment-00/kern.log"
check_grep "assignment-02/kern.log boots a -thor_kernel release" \
	'Linux version [^ ]*-thor_kernel' "$REPO_ROOT/assignment-02/kern.log"
check_grep "assignment-02/Makefile.patch is git format-patch output" \
	'^From [0-9a-f]{40} ' "$REPO_ROOT/assignment-02/Makefile.patch"
check_grep "assignment-02/Makefile.patch sets -thor_kernel" \
	'^\+EXTRAVERSION = .*-thor_kernel' "$REPO_ROOT/assignment-02/Makefile.patch"
check_grep "assignment-06/kern.log boots a linux-next release" \
	'Linux version [^ ]*-next-[0-9]{8}' "$REPO_ROOT/assignment-06/kern.log"

if cmp -s "$REPO_ROOT/assignment-00/kern.log" "$REPO_ROOT/assignment-06/kern.log"; then
	echo "FAIL: assignment-00 and assignment-06 kern.log are identical"
	ERR=1
fi

check_grep "login sshevche in assignment-05" 'sshevche' "$REPO_ROOT/assignment-05/main.c"

echo "=== Git check ==="
if ! git -C "$REPO_ROOT" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
	echo "SKIP: $REPO_ROOT is not a git checkout"
	exit $ERR
fi
UNTRACKED="$(git -C "$REPO_ROOT" status --porcelain --untracked-files=all -- .)"
if [ -n "$UNTRACKED" ]; then
	echo "FAIL: uncommitted or untracked files:"
	echo "$UNTRACKED"
	ERR=1
else
	echo "OK: everything is committed"
fi

exit $ERR

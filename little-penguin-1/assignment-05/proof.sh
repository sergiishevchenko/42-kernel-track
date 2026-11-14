#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
LOG="proof.log"
PROOF_USER="${PROOF_USER:-penguin}"

if [ "$(id -u)" -ne 0 ]; then
	echo "Run as root."
	exit 1
fi
if ! id "$PROOF_USER" > /dev/null 2>&1; then
	echo "User $PROOF_USER does not exist. Create it: useradd -m $PROOF_USER"
	exit 1
fi

as_user() {
	su -s /bin/bash -c "$1" "$PROOF_USER"
}

make
rmmod main 2>/dev/null || true
insmod main.ko

{
	echo "=== uname -r ==="
	uname -r
	echo "=== ls -l /dev/fortytwo ==="
	ls -l /dev/fortytwo
	echo "=== [$PROOF_USER] cat /dev/fortytwo ==="
	as_user "cat /dev/fortytwo"
	echo
	echo "=== [$PROOF_USER] echo -n sshevche > /dev/fortytwo ==="
	as_user "echo -n sshevche > /dev/fortytwo" && echo "write succeeded"
	echo "=== [$PROOF_USER] echo -n wrong > /dev/fortytwo ==="
	as_user "echo -n wrong > /dev/fortytwo" || echo "write failed as expected"
	echo "=== [$PROOF_USER] echo sshevche > /dev/fortytwo (trailing newline) ==="
	as_user "echo sshevche > /dev/fortytwo" || echo "write failed as expected"
} 2>&1 | tee "$LOG"

rmmod main
{
	echo "=== after rmmod ==="
	ls -l /dev/fortytwo || echo "/dev/fortytwo removed"
} 2>&1 | tee -a "$LOG"

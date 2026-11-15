#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
LOG="proof.log"
PROOF_USER="${PROOF_USER:-penguin}"
DEBUGFS="/sys/kernel/debug"
BASE="$DEBUGFS/fortytwo"

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

if ! mountpoint -q "$DEBUGFS"; then
	mount -t debugfs none "$DEBUGFS"
fi
chmod o+rx "$DEBUGFS"

make
rmmod main 2>/dev/null || true
insmod main.ko

{
	echo "=== uname -r ==="
	uname -r
	echo "=== ls -ld $DEBUGFS $BASE ==="
	ls -ld "$DEBUGFS" "$BASE"
	echo "=== ls -l $BASE ==="
	ls -l "$BASE"

	echo "=== [$PROOF_USER] cat id ==="
	as_user "cat $BASE/id"
	echo
	echo "=== [$PROOF_USER] echo -n sshevche > id ==="
	as_user "echo -n sshevche > $BASE/id" && echo "write succeeded"
	echo "=== [$PROOF_USER] echo -n wrong > id ==="
	as_user "echo -n wrong > $BASE/id" || echo "write failed as expected"

	echo "=== [$PROOF_USER] cat jiffies (twice, 1s apart) ==="
	as_user "cat $BASE/jiffies"
	sleep 1
	as_user "cat $BASE/jiffies"
	echo "=== [$PROOF_USER] echo -n x > jiffies ==="
	as_user "echo -n x > $BASE/jiffies" || echo "write failed as expected"

	echo "=== [$PROOF_USER] echo -n user > foo ==="
	as_user "echo -n user > $BASE/foo" || echo "write failed as expected"
	echo "=== [root] echo -n 'hello from root' > foo ==="
	echo -n "hello from root" > "$BASE/foo"
	echo "=== [$PROOF_USER] cat foo ==="
	as_user "cat $BASE/foo"
	echo
	echo "=== [root] write 4097 bytes to foo ==="
	head -c 4097 /dev/zero > "$BASE/foo" || echo "write failed as expected"
} 2>&1 | tee "$LOG"

rmmod main
{
	echo "=== after rmmod ==="
	ls "$BASE" || echo "$BASE removed"
} 2>&1 | tee -a "$LOG"

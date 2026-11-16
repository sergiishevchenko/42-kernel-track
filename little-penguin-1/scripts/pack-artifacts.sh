#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-/tmp/little-penguin-artifacts.tar.gz}"
ARTIFACTS=(
	assignment-00/kern.log
	assignment-00/.config
	assignment-02/kern.log
	assignment-02/Makefile.patch
	assignment-04/proof.log
	assignment-05/proof.log
	assignment-06/kern.log
	assignment-07/proof.log
)

cd "$REPO_ROOT"
FILES=()
for f in "${ARTIFACTS[@]}"; do
	if [ -f "$f" ]; then
		FILES+=("$f")
	else
		echo "Skipping missing $f"
	fi
done

tar -czf "$OUT" "${FILES[@]}"
echo "Packed ${#FILES[@]} files into $OUT"

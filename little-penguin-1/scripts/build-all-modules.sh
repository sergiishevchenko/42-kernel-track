#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODULE_DIRS=(
	assignment-01
	assignment-04
	assignment-05
	assignment-07
	assignment-09
)

for dir in "${MODULE_DIRS[@]}"; do
	echo "=== Building $dir ==="
	make -C "$REPO_ROOT/$dir" clean 2>/dev/null || true
	make -C "$REPO_ROOT/$dir"
done

echo "All modules built successfully."

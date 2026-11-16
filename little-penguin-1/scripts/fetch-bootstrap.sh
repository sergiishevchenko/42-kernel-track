#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$REPO_ROOT/bootstrap"

CURL_VERSION="8.11.1"
GIT_VERSION="2.47.1"

mkdir -p "$DEST"
cd "$DEST"

fetch() {
	local url="$1"
	local file="${url##*/}"

	if [ -s "$file" ]; then
		echo "Already present: $file"
	else
		echo "Downloading $url"
		curl -fL --retry 3 -o "$file" "$url"
	fi
}

fetch "https://curl.se/download/curl-${CURL_VERSION}.tar.xz"
fetch "https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.xz"
fetch "https://curl.se/ca/cacert.pem"

echo "Bootstrap sources are in $DEST"

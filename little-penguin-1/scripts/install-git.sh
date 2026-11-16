#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO_ROOT/bootstrap"
BUILD="/tmp/little-penguin-bootstrap"
CA_BUNDLE="/etc/ssl/certs/ca-bundle.crt"
GIT_FLAGS=(prefix=/usr NO_TCLTK=1 NO_GETTEXT=1)

if [ "$(id -u)" -ne 0 ]; then
	echo "Run as root."
	exit 1
fi

CURL_TAR="$(ls "$SRC"/curl-*.tar.xz 2>/dev/null | head -1)"
GIT_TAR="$(ls "$SRC"/git-*.tar.xz 2>/dev/null | head -1)"
if [ -z "$CURL_TAR" ] || [ -z "$GIT_TAR" ] || [ ! -s "$SRC/cacert.pem" ]; then
	echo "Missing sources in $SRC. Run scripts/fetch-bootstrap.sh on the Mac first."
	exit 1
fi

install -D -m 644 "$SRC/cacert.pem" "$CA_BUNDLE"

rm -rf "$BUILD"
mkdir -p "$BUILD"

tar -xf "$CURL_TAR" -C "$BUILD"
cd "$BUILD"/curl-*/
./configure --prefix=/usr --disable-static --with-openssl \
	--without-libpsl --with-ca-bundle="$CA_BUNDLE"
make -j"$(nproc)"
make install
ldconfig

tar -xf "$GIT_TAR" -C "$BUILD"
cd "$BUILD"/git-*/
make -j"$(nproc)" "${GIT_FLAGS[@]}" all
make "${GIT_FLAGS[@]}" install

git config --global http.sslCAInfo "$CA_BUNDLE"

rm -rf "$BUILD"

curl -fsSI https://git.kernel.org > /dev/null && echo "HTTPS works."
git --version

#!/bin/bash
set -euo pipefail

usage() {
	echo "Usage: $0 <torvalds|thor|linux-next> [output_dir]"
	echo "  torvalds    - clone/build Linus tree (assignment-00)"
	echo "  thor        - commit -thor_kernel EXTRAVERSION and rebuild (assignment-02)"
	echo "  linux-next  - clone/build linux-next (assignment-06)"
	exit 1
}

[ $# -lt 1 ] && usage

if [ "$(id -u)" -ne 0 ]; then
	echo "Run as root."
	exit 1
fi

TREE_TYPE="$1"
OUT_DIR="${2:-/usr/src/little-penguin}"
GRUB_CFG="${GRUB_CFG:-/boot/grub/grub.cfg}"
JOBS="$(nproc)"

case "$TREE_TYPE" in
torvalds)
	REPO="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
	DIR="linux"
	COLLECT="assignment-00/collect.sh"
	;;
thor)
	REPO="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
	DIR="linux"
	COLLECT="assignment-02/collect.sh"
	;;
linux-next)
	REPO="https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git"
	DIR="linux-next"
	COLLECT="assignment-06/collect.sh"
	;;
*)
	usage
	;;
esac

case "$(uname -m)" in
x86_64 | i?86)
	IMAGE="arch/x86/boot/bzImage"
	;;
aarch64 | arm64)
	IMAGE="arch/arm64/boot/Image"
	;;
*)
	echo "Unsupported architecture: $(uname -m)"
	exit 1
	;;
esac

add_grub_entry() {
	local release="$1"
	local title="little-penguin $release"
	local kernel_path="/boot/vmlinuz-$release"
	local cmdline
	local entry

	if [ ! -f "$GRUB_CFG" ]; then
		echo "$GRUB_CFG not found: add a menuentry for /boot/vmlinuz-$release by hand."
		return
	fi
	if grep -qF "\"$title\"" "$GRUB_CFG"; then
		echo "GRUB entry \"$title\" already exists."
		return
	fi

	if mountpoint -q /boot; then
		kernel_path="/vmlinuz-$release"
	fi
	cmdline="$(tr ' ' '\n' < /proc/cmdline | grep -v '^BOOT_IMAGE=' | tr '\n' ' ')"
	cmdline="${cmdline% }"

	entry="$(printf '%s\n' \
		"menuentry \"$title\" {" \
		"    insmod ext2" \
		"    search --no-floppy --set=root --file $kernel_path" \
		"    linux $kernel_path $cmdline" \
		"}")"

	cp "$GRUB_CFG" "$GRUB_CFG.bak"
	printf '\n%s\n' "$entry" >> "$GRUB_CFG"
	echo "Added GRUB entry:"
	echo "$entry"
}

mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

if [ ! -d "$DIR" ]; then
	git clone --depth 1 "$REPO" "$DIR"
fi

cd "$DIR"

if [ ! -f .config ]; then
	if [ -f "/boot/config-$(uname -r)" ]; then
		cp "/boot/config-$(uname -r)" .config
	elif [ -f /proc/config.gz ]; then
		zcat /proc/config.gz > .config
	else
		make defconfig
		make kvm_guest.config
	fi
fi

./scripts/config \
	--enable LOCALVERSION_AUTO \
	--enable MODULES \
	--enable MODULE_UNLOAD \
	--enable PROC_FS \
	--enable DEBUG_FS \
	--enable USB_SUPPORT \
	--enable USB \
	--enable USB_XHCI_HCD \
	--enable USB_XHCI_PCI \
	--enable HID \
	--enable HID_GENERIC \
	--enable USB_HID \
	--disable DEBUG_INFO_BTF
make olddefconfig

if [ "$TREE_TYPE" = "thor" ] && ! grep -q '^EXTRAVERSION = .*-thor_kernel' Makefile; then
	sed -i 's/^EXTRAVERSION =[[:space:]]*\(.*\)$/EXTRAVERSION = \1-thor_kernel/' Makefile
	git commit -s Makefile \
		-m "Makefile: append -thor_kernel to EXTRAVERSION" \
		-m "Tag the kernel release string with -thor_kernel so the running custom build is easy to identify with uname -r."
fi

make -j"$JOBS"
RELEASE="$(make -s kernelrelease)"

make modules_install
cp "$IMAGE" "/boot/vmlinuz-$RELEASE"
cp System.map "/boot/System.map-$RELEASE"
cp .config "/boot/config-$RELEASE"
ln -sfn "$PWD" "/lib/modules/$RELEASE/build"

add_grub_entry "$RELEASE"

echo
echo "Installed $RELEASE."
echo "Reboot, pick \"little-penguin $RELEASE\" in the GRUB menu, then run from the repo:"
echo "  $COLLECT $PWD"

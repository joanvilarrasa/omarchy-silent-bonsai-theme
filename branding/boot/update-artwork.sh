#!/usr/bin/env bash
# Refresh only the existing bonsai artwork, preserving boot appearance settings.
set -Eeuo pipefail

[[ $EUID -eq 0 ]] || { echo "Administrator privileges are required." >&2; exit 1; }
SOURCE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
DEST=/usr/share/plymouth/themes/silent-bonsai
[[ ! -e /var/lib/pacman/db.lck ]] || { echo "A package update is running; try again later." >&2; exit 1; }
[[ -f $DEST/silent-bonsai.plymouth ]] || { echo "Install the Silent Bonsai Plymouth theme first." >&2; exit 1; }
for file in "$SOURCE/plymouth/logo.png" "$SOURCE/limine-bonsai.png" "$DEST/logo.png" /boot/silent-bonsai.png; do
  [[ -s $file ]] || { echo "Missing artwork: $file" >&2; exit 1; }
done

BACKUP=/var/backups/silent-bonsai/$(date +%Y%m%d-%H%M%S)
install -d -m700 "$BACKUP"
cp -a /boot/limine.conf "$BACKUP/limine.conf"
cp -a /etc/plymouth/plymouthd.conf "$BACKUP/plymouthd.conf"
cp -a /boot/EFI/Linux "$BACKUP/EFI-Linux"
cp -a /boot/silent-bonsai.png "$BACKUP/silent-bonsai.png"
cp -a "$DEST/logo.png" "$BACKUP/plymouth-logo.png"
echo "Boot artwork, configuration, and kernel-image backups: $BACKUP"

rollback() {
  trap - ERR
  echo "Update failed. Restoring the previous artwork and boot images." >&2
  cp -a "$BACKUP/EFI-Linux/." /boot/EFI/Linux/
  cp -a "$BACKUP/limine.conf" /boot/limine.conf
  cp -a "$BACKUP/plymouthd.conf" /etc/plymouth/plymouthd.conf
  cp -a "$BACKUP/silent-bonsai.png" /boot/silent-bonsai.png
  cp -a "$BACKUP/plymouth-logo.png" "$DEST/logo.png"
  sync -f /boot
  exit 1
}
trap rollback ERR

install -m644 "$SOURCE/plymouth/logo.png" "$DEST/logo.png"
# System updates can restore Omarchy's stock Plymouth selection.
/usr/bin/plymouth-set-default-theme silent-bonsai
/usr/bin/limine-mkinitcpio linux-omarchy linux
for kernel in linux-omarchy linux; do
  image="/boot/EFI/Linux/omarchy_${kernel}.efi"
  /usr/bin/lsinitcpio "$image" > "$BACKUP/${kernel}-initramfs.list"
  grep -q 'usr/share/plymouth/themes/silent-bonsai/logo.png' "$BACKUP/${kernel}-initramfs.list"
  if cmp -s "$image" "$BACKUP/EFI-Linux/omarchy_${kernel}.efi"; then
    echo "Kernel image was not rebuilt: $kernel" >&2
    false
  fi
done

install -m644 "$SOURCE/limine-bonsai.png" /boot/silent-bonsai.png
/usr/bin/python - <<'PY'
from pathlib import Path
import hashlib
import re

path = Path('/boot/limine.conf')
config = path.read_text()
digest = hashlib.blake2b(Path('/boot/silent-bonsai.png').read_bytes()).hexdigest()
updated, count = re.subn(
    r'^(wallpaper:[ \t]*boot\(\):/silent-bonsai\.png)(?:#[0-9a-fA-F]+)?[ \t]*$',
    lambda match: match[1] + '#' + digest,
    config,
    flags=re.M,
)
assert count == 1, 'Expected exactly one existing bonsai wallpaper setting.'
path.write_text(updated)
PY
if grep -Eq '^ENABLE_ENROLL_LIMINE_CONFIG=["\x27]?yes' /etc/default/limine /etc/limine-entry-tool.conf /etc/limine-entry-tool.d/*.conf; then
  /usr/bin/limine-enroll-config
fi
sync -f /boot
trap - ERR
echo "Updated Limine and Plymouth artwork. Backups: $BACKUP"

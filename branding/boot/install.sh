#!/usr/bin/env bash
set -Eeuo pipefail

[[ $EUID -eq 0 ]] || { echo "Run this installer with administrator privileges." >&2; exit 1; }
SOURCE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
DEST=/usr/share/plymouth/themes/silent-bonsai
[[ ! -e /var/lib/pacman/db.lck ]] || { echo "A package update is running; try again later." >&2; exit 1; }
[[ ! -e $DEST ]] || { echo "$DEST already exists; refusing to overwrite it." >&2; exit 1; }
for file in plymouth/silent-bonsai.plymouth plymouth/silent-bonsai.script plymouth/logo.png limine-bonsai.png limine-appearance.conf; do
  [[ -s $SOURCE/$file ]] || { echo "Missing prepared asset: $file" >&2; exit 1; }
done

BACKUP=/var/backups/silent-bonsai/$(date +%Y%m%d-%H%M%S)
install -d -m700 "$BACKUP"
cp -a /boot/limine.conf "$BACKUP/limine.conf"
cp -a /etc/plymouth/plymouthd.conf "$BACKUP/plymouthd.conf"
cp -a /boot/EFI/Linux "$BACKUP/EFI-Linux"
if [[ -e /boot/silent-bonsai.png ]]; then
  cp -a /boot/silent-bonsai.png "$BACKUP/silent-bonsai.png"
fi
echo "Boot configuration and kernel-image backups: $BACKUP"

rollback() {
  trap - ERR
  echo "Installation failed. Restoring the original boot images and settings." >&2
  cp -a "$BACKUP/EFI-Linux/." /boot/EFI/Linux/
  cp -a "$BACKUP/limine.conf" /boot/limine.conf
  cp -a "$BACKUP/plymouthd.conf" /etc/plymouth/plymouthd.conf
  if [[ -f $BACKUP/silent-bonsai.png ]]; then
    cp -a "$BACKUP/silent-bonsai.png" /boot/silent-bonsai.png
  fi
  sync -f /boot
  exit 1
}
trap rollback ERR

install -d -m755 "$DEST"
install -m644 "$SOURCE"/plymouth/* "$DEST/"
/usr/bin/plymouth-set-default-theme silent-bonsai

# The supported Limine rebuild path also refreshes UKI hashes in boot entries.
# Do not use mkinitcpio -P: this installation has no mkinitcpio presets.
/usr/bin/limine-mkinitcpio linux-omarchy linux
for kernel in linux-omarchy linux; do
  /usr/bin/lsinitcpio "/boot/EFI/Linux/omarchy_${kernel}.efi" > "$BACKUP/${kernel}-initramfs.list"
  grep -q 'usr/share/plymouth/themes/silent-bonsai/logo.png' "$BACKUP/${kernel}-initramfs.list"
  grep -q 'usr/share/plymouth/themes/silent-bonsai/silent-bonsai.script' "$BACKUP/${kernel}-initramfs.list"
done

install -m644 "$SOURCE/limine-bonsai.png" /boot/silent-bonsai.png
/usr/bin/python - "$SOURCE/limine-appearance.conf" <<'PY'
from pathlib import Path
import hashlib
import re
import sys

path = Path('/boot/limine.conf')
config = path.read_text()
match = re.search(r'^/', config, re.M)
assert match, 'Cannot locate boot entries; refusing to rewrite configuration.'
header, entries = config[:match.start()], config[match.start():]
appearance = Path(sys.argv[1]).read_text().splitlines()
digest = hashlib.blake2b(Path('/boot/silent-bonsai.png').read_bytes()).hexdigest()
for line in appearance:
    key, value = line.split(':', 1)
    if key == 'wallpaper':
        value += '#' + digest
    header = re.sub(r'^' + re.escape(key) + r'\s*:.*\n?', '', header, flags=re.M)
    header = header.rstrip() + '\n' + key + ':' + value + '\n'
path.write_text(header.rstrip() + '\n\n' + entries)
assert path.read_text().split(entries, 1)[1] == ''
assert path.read_text().endswith(entries)
PY

# Preserve config-enrollment/signing policies where enabled by this system.
if grep -Eq '^ENABLE_ENROLL_LIMINE_CONFIG=["\x27]?yes' /etc/default/limine /etc/limine-entry-tool.d/*.conf; then
  /usr/bin/limine-enroll-config
fi
sync -f /boot
trap - ERR
echo "Installed Silent Bonsai for the Limine menu and Plymouth boot/unlock splash."
echo "Backups are in $BACKUP. Reboot when convenient to see the result."

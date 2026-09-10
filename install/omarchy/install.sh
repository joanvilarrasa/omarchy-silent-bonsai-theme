#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HYPR_DIR="$HOME/.config/hypr"
PLUGIN_SOURCE_DIR="$SCRIPT_DIR/plugins"
PLUGIN_DIR="$HOME/.config/omarchy/plugins"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

install -Dm644 "$SCRIPT_DIR/bindings.lua" "$HYPR_DIR/bindings.lua"
install -Dm644 "$SCRIPT_DIR/input.lua" "$HYPR_DIR/input.lua"
install -Dm644 "$SCRIPT_DIR/looknfeel.lua" "$HYPR_DIR/looknfeel.lua"

for plugin in silent-bonsai.bar silent-bonsai.workspaces silent-bonsai.screenshot; do
  install -d "$PLUGIN_DIR/$plugin"
  cp -a "$PLUGIN_SOURCE_DIR/$plugin/." "$PLUGIN_DIR/$plugin/"
done

install -Dm644 "$SCRIPT_DIR/silent-bonsai-stay-awake.service" \
  "$SYSTEMD_USER_DIR/silent-bonsai-stay-awake.service"

omarchy-shell shell rescanPlugins >/dev/null
omarchy plugin enable silent-bonsai.bar
omarchy plugin enable silent-bonsai.workspaces
omarchy plugin enable silent-bonsai.screenshot --section center --before omarchy.clock
omarchy bar transparent true
omarchy toggle idle allow-idle >/dev/null
omarchy toggle suspend-off on >/dev/null

systemctl --user daemon-reload
systemctl --user enable --now silent-bonsai-stay-awake.service

omarchy restart shell

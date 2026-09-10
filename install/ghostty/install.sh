#!/usr/bin/env bash

set -euo pipefail

GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
FONT_SIZE=12

install -d "$(dirname -- "$GHOSTTY_CONFIG")"
touch "$GHOSTTY_CONFIG"

if grep -qE '^[[:space:]]*font-size[[:space:]]*=' "$GHOSTTY_CONFIG"; then
  sed -i -E "s/^[[:space:]]*font-size[[:space:]]*=.*/font-size = $FONT_SIZE/" "$GHOSTTY_CONFIG"
else
  printf '\nfont-size = %s\n' "$FONT_SIZE" >> "$GHOSTTY_CONFIG"
fi

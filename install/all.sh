#!/usr/bin/env bash

set -euo pipefail

SB_THEME_NAME="silent-bonsai"
INSTALL_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SB_THEME_PATH="$(dirname -- "$INSTALL_DIR")"
export SB_THEME_PATH

bash "$SB_THEME_PATH/install/packages/install.sh"
bash "$SB_THEME_PATH/install/packages/uninstall-terminals.sh"
bash "$SB_THEME_PATH/install/omarchy/install.sh"
bash "$SB_THEME_PATH/install/ghostty/install.sh"

omarchy theme set "$SB_THEME_NAME"

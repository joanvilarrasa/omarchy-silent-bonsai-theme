THEMES_DIR="$HOME/.config/omarchy/themes/"
SB_THEME_NAME="silent-bonsai"
SB_THEME_PATH="$THEMES_DIR$SB_THEME_NAME"
export SB_THEME_PATH

$SB_THEME_PATH/install/packages/install.sh
$SB_THEME_PATH/install/omarchy/install.sh
$SB_THEME_PATH/install/waybar/install.sh

omarchy-theme-set silent-bonsai

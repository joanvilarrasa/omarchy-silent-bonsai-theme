# Install 
mapfile -t packagestoinstall < <(grep -v '^#' "$SB_THEME_PATH/install/packages/to-install.packages" | grep -v '^$')
yay -S --noconfirm --needed "${packagestoinstall[@]}"

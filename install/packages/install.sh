# Install
mapfile -t requested_packages < <(grep -Ev '^\s*(#|$)' "$SB_THEME_PATH/install/packages/to-install.packages")
missing_packages=()

for package in "${requested_packages[@]}"; do
  pacman -Qq "$package" >/dev/null 2>&1 || missing_packages+=("$package")
done

if (( ${#missing_packages[@]} )); then
  yay -S --noconfirm --needed "${missing_packages[@]}"
fi

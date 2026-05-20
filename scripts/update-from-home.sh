#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DST="$DOTFILES_DIR/home"

copy_path() {
  local src="$1"
  local dst="$HOME_DST/${src#$HOME/}"

  if [[ ! -e "$src" && ! -L "$src" ]]; then
    echo "Missing, skipping: $src" >&2
    return 0
  fi

  mkdir -p "$(dirname "$dst")"
  cp -a "$src" "$dst"
  echo "Updated ${dst#$DOTFILES_DIR/}"
}

cleanup_ignored_state() {
  rm -rf \
    "$HOME_DST/.config/hypr/companion/__pycache__" \
    "$HOME_DST/.config/OpenRGB/logs"

  find "$HOME_DST" -type f \( -name '*.bak' -o -name '*.pyc' -o -name '*.log' \) -delete
}

copy_path "$HOME/.zshrc"
copy_path "$HOME/.bashrc"
copy_path "$HOME/.bash_profile"
copy_path "$HOME/.bash_logout"
copy_path "$HOME/.p10k.zsh"
copy_path "$HOME/.npmrc"

copy_path "$HOME/.config/hypr"
copy_path "$HOME/.config/kitty"
copy_path "$HOME/.config/waybar"
copy_path "$HOME/.config/wofi"
copy_path "$HOME/.config/cava"
copy_path "$HOME/.config/fontconfig"
copy_path "$HOME/.config/gtk-3.0"
copy_path "$HOME/.config/Thunar"
copy_path "$HOME/.config/OpenRGB"
copy_path "$HOME/.config/wal"
copy_path "$HOME/.config/pokefetch"
copy_path "$HOME/.config/fastfetch"
copy_path "$HOME/.config/mimeapps.list"
copy_path "$HOME/.config/user-dirs.dirs"
copy_path "$HOME/.config/user-dirs.locale"

pacman -Qqe | sort > "$DOTFILES_DIR/packages/pacman-explicit.txt"
pacman -Qqm | sort > "$DOTFILES_DIR/packages/aur.txt"
comm -23 "$DOTFILES_DIR/packages/pacman-explicit.txt" "$DOTFILES_DIR/packages/aur.txt" > "$DOTFILES_DIR/packages/pacman-native.txt"

if command -v npm >/dev/null 2>&1; then
  (npm list -g --depth=0 --parseable 2>/dev/null || true) \
    | awk -v home="$HOME" '$0 ~ "^"home"/.npm-global/lib/node_modules/" { sub("^"home"/.npm-global/lib/node_modules/", ""); print; next } $0 == home"/.npm-global/lib" { next } { print }' \
    > "$DOTFILES_DIR/packages/npm-global.txt"
fi

if command -v brew >/dev/null 2>&1; then
  brew bundle dump --file="$DOTFILES_DIR/packages/Brewfile" --force
fi

if command -v dconf >/dev/null 2>&1; then
  dconf dump / > "$DOTFILES_DIR/packages/dconf.ini" || true
fi

cleanup_ignored_state

echo "Dotfiles refreshed."

#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_SRC="$DOTFILES_DIR/home"
BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)}"

install_files=false
install_packages=false
install_aur=false
install_brew=false
install_npm=false
load_dconf=false

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options]

Options:
  --all            Install files and package lists
  --files          Copy dotfiles into $HOME
  --packages       Install official Arch packages
  --aur            Install AUR packages with yay
  --brew           Install Homebrew packages from packages/Brewfile
  --npm            Install global npm packages
  --dconf          Load packages/dconf.ini with dconf
  -h, --help       Show this help

By default, running without options is the same as --files.
Existing files are backed up under ~/.dotfiles-backup before replacement.
USAGE
}

if [[ $# -eq 0 ]]; then
  install_files=true
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      install_files=true
      install_packages=true
      install_aur=true
      install_brew=true
      install_npm=true
      ;;
    --files) install_files=true ;;
    --packages) install_packages=true ;;
    --aur) install_aur=true ;;
    --brew) install_brew=true ;;
    --npm) install_npm=true ;;
    --dconf) load_dconf=true ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

backup_target() {
  local target="$1"
  local rel="${target#$HOME/}"
  local backup="$BACKUP_DIR/$rel"

  mkdir -p "$(dirname "$backup")"
  cp -a "$target" "$backup"
  echo "Backed up $target -> $backup"
}

copy_home_files() {
  [[ -d "$HOME_SRC" ]] || return 0

  while IFS= read -r -d '' dir; do
    local rel="${dir#$HOME_SRC/}"
    [[ "$rel" == "$dir" ]] && continue
    mkdir -p "$HOME/$rel"
  done < <(find "$HOME_SRC" -type d -print0)

  while IFS= read -r -d '' src; do
    local rel="${src#$HOME_SRC/}"
    local target="$HOME/$rel"

    mkdir -p "$(dirname "$target")"

    if [[ -e "$target" || -L "$target" ]]; then
      if [[ -f "$src" && -f "$target" ]] && cmp -s "$src" "$target"; then
        continue
      fi
      backup_target "$target"
    fi

    cp -a "$src" "$target"
    echo "Installed $target"
  done < <(find "$HOME_SRC" \( -type f -o -type l \) -print0)
}

install_arch_packages() {
  local list="$DOTFILES_DIR/packages/pacman-native.txt"
  [[ -s "$list" ]] || return 0

  if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman not found; skipping Arch packages" >&2
    return 0
  fi

  sudo pacman -S --needed - < "$list"
}

install_aur_packages() {
  local list="$DOTFILES_DIR/packages/aur.txt"
  [[ -s "$list" ]] || return 0

  if ! command -v yay >/dev/null 2>&1; then
    echo "yay not found; install yay first, then rerun ./install.sh --aur" >&2
    return 0
  fi

  yay -S --needed - < "$list"
}

install_brew_packages() {
  local brewfile="$DOTFILES_DIR/packages/Brewfile"
  [[ -s "$brewfile" ]] || return 0

  if ! command -v brew >/dev/null 2>&1; then
    echo "brew not found; skipping Homebrew packages" >&2
    return 0
  fi

  brew bundle --file="$brewfile"
}

install_npm_packages() {
  local list="$DOTFILES_DIR/packages/npm-global.txt"
  [[ -s "$list" ]] || return 0

  if ! command -v npm >/dev/null 2>&1; then
    echo "npm not found; skipping global npm packages" >&2
    return 0
  fi

  xargs -r npm install -g < "$list"
}

load_dconf_settings() {
  local dump="$DOTFILES_DIR/packages/dconf.ini"
  [[ -s "$dump" ]] || return 0

  if ! command -v dconf >/dev/null 2>&1; then
    echo "dconf not found; skipping dconf import" >&2
    return 0
  fi

  dconf load / < "$dump"
}

$install_files && copy_home_files
$install_packages && install_arch_packages
$install_aur && install_aur_packages
$install_brew && install_brew_packages
$install_npm && install_npm_packages
$load_dconf && load_dconf_settings

echo "Done."

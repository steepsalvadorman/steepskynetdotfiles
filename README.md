# Dotfiles

Personal dotfiles for the `steepskynet` Linux desktop.

## What is included

- Shell config: `.zshrc`, `.bashrc`, `.bash_profile`, `.p10k.zsh`, `.npmrc`
- Desktop config: Hyprland, Waybar, Kitty, Wofi, Cava, GTK, Thunar, OpenRGB, fontconfig
- Package manifests:
  - `packages/pacman-native.txt` for official Arch packages
  - `packages/aur.txt` for AUR packages
  - `packages/npm-global.txt` for global npm packages
  - `packages/Brewfile` for Homebrew, when available
  - `packages/dconf.ini` for optional dconf settings

Browser profiles, caches, cookies, shell history, GPG keys and SSH keys are intentionally excluded.

## Install on a new machine

Clone the repository:

```bash
git clone https://github.com/<your-user>/<your-repo>.git ~/dotfiles
cd ~/dotfiles
```

Restore only files:

```bash
./install.sh
```

Restore files and install packages:

```bash
./install.sh --all
```

More selective examples:

```bash
./install.sh --files --packages
./install.sh --aur
./install.sh --npm
./install.sh --dconf
```

Existing files are copied to `~/.dotfiles-backup/<timestamp>/` before being replaced.

## Refresh this repo from the current machine

After changing local configuration:

```bash
./scripts/update-from-home.sh
git status
git add .
git commit -m "Update dotfiles"
git push
```

Review `git diff` before committing so secrets or machine-specific state do not enter the repo.

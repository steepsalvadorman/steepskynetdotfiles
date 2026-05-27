# steepskynet dotfiles

Arch Linux desktop · Hyprland · Mirror's Edge aesthetic

![Desktop](assets/desktop.png)

## Stack

| Layer | Tool |
|---|---|
| Compositor | [Hyprland](https://hyprland.org) |
| Bar | [eww](https://github.com/elkowar/eww) |
| Projects popup | [AGS / Astal](https://aylur.github.io/astal) |
| Terminal | [Kitty](https://sw.kovidgoyal.net/kitty/) |
| Launcher | [Wofi](https://hg.sr.ht/~scoopta/wofi) |
| Notifications | [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) |
| Theming | [pywal](https://github.com/dylanaraps/pywal) |
| Shell | Zsh + Powerlevel10k |
| GPU | NVIDIA (drivers + NVAPI + DXVK) |
| Display | 2560×1440 @ 180 Hz (DP-1) |

## Bar widgets

- Workspaces (hyprctl live listener)
- Clock + date
- Music player (playerctl → Chromium/Spotify)
- CPU · CPU temp · RAM · GPU · GPU temp
- CAVA VU meter
- Volume slider (wpctl)
- Docker status (lazydocker)
- OBS recording badge
- Notification bell (swaync)
- **Projects popup** — scans `~/Documentos/programacion/` by language, opens in VS Code (powered by AGS)

## Color theming

Colors are generated live from the wallpaper via **pywal**.  
Template: `~/.config/wal/templates/eww-colors.css` → `~/.cache/wal/eww-colors.css`

After changing wallpaper run:
```bash
wal -i /path/to/wallpaper
```

## Gaming config (Hyprland)

- `allow_tearing = true` + `vrr = 2` for low-latency gaming
- `immediate` rendering for Steam games (`steam_app_*`)
- Full-screen rules for Diablo IV and Marvel Rivals
- NVIDIA: `NVD_BACKEND=direct`, `PROTON_ENABLE_NVAPI=1`, `DXVK_ASYNC=1`

## What is included

- Shell: `.zshrc` · `.bashrc` · `.bash_profile` · `.p10k.zsh` · `.npmrc`
- Config: Hyprland · eww · AGS · Kitty · Wofi · Cava · GTK · Thunar · OpenRGB · fontconfig · pywal templates
- Package lists: `packages/pacman-native.txt` · `packages/aur.txt` · `packages/npm-global.txt`

Browser profiles, caches, shell history, GPG/SSH keys excluded.

## Install on a new machine

```bash
git clone https://github.com/steepsalvadorman/steepsamadotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Restore only files:
```bash
./install.sh --files
```

Restore files + packages:
```bash
./install.sh --all
```

Backup of existing files is written to `~/.dotfiles-backup/<timestamp>/` before overwriting.

## Refresh repo from current machine

```bash
cd ~/dotfiles
./scripts/update-from-home.sh
git add .
git commit -m "Update dotfiles"
git push
```

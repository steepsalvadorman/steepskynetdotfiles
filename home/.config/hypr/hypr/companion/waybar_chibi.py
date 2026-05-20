#!/usr/bin/env python3
import sys
import os
import subprocess
import json

SPRITE_DIR = "/home/steepskynet/.config/hypr/companion/frames"
STATE_FILE = "/tmp/chibi_state"

def is_music_playing():
    try:
        result = subprocess.run(
            ["playerctl", "status"],
            capture_output=True,
            text=True,
            timeout=0.2,
        )
        return result.stdout.strip() == "Playing"
    except Exception:
        return False

def get_active_window_state():
    try:
        result = subprocess.run(
            ["hyprctl", "activewindow", "-j"],
            capture_output=True,
            text=True,
            timeout=0.2,
        )
        data = json.loads(result.stdout.strip())
        cls = data.get("class", "").lower()
        title = data.get("title", "").lower()
        
        # Gaming detection
        gaming_classes = ["steam", "retroarch", "lutris", "heroic", "minecraft", "cs2", "dota2", "osu", "rpcs3", "yuzu", "ryujinx"]
        if any(g in cls for g in gaming_classes) or "steam_app_" in cls or "game" in title:
            return "play"
            
        # Programming detection
        programming_classes = ["code", "kitty", "antigravity", "cursor", "sublime", "neovim", "neovide", "jetbrains", "intellij", "pycharm", "webstorm", "clion"]
        if any(p in cls for p in programming_classes) or "neovim" in title or "vscode" in title:
            return "code"
            
        # Typing/Writing/Browsing detection
        writing_classes = ["obsidian", "libreoffice", "office", "thunderbird", "geany", "typora", "firefox", "chrome", "chromium", "brave-browser", "opera", "vivaldi", "discord", "slack"]
        if any(w in cls for w in writing_classes):
            return "type"
            
    except Exception:
        pass
    return None

def main():
    # Priority 1: Music
    if is_music_playing():
        state = "music"
    else:
        # Priority 2: Active Window context
        win_state = get_active_window_state()
        if win_state:
            state = win_state
        else:
            # Priority 3: Fallback to idle
            state = "idle"
        
    # Read last frame
    frame = 0
    last_state = "idle"
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r") as f:
                last_state, frame_str = f.read().split()
                frame = int(frame_str)
        except:
            pass
            
    if last_state != state:
        frame = 0
    else:
        frame = (frame + 1) % 4
        
    with open(STATE_FILE, "w") as f:
        f.write(f"{state} {frame}")

    print(f"{SPRITE_DIR}/{state}_{frame}.png")

if __name__ == "__main__":
    main()

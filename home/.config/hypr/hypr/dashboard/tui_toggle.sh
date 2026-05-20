#!/bin/bash
# TUI Dashboard Toggle Launcher

# Check if TUI Dashboard is already running
PID=$(pgrep -f "tui_dashboard.py")

if [ -n "$PID" ]; then
    kill "$PID"
else
    kitty --class "tui-dashboard" -e python3 /home/steepskynet/.config/hypr/dashboard/tui_dashboard.py
fi

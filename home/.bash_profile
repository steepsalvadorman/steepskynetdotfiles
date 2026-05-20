#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

if uwsm check may-start; then
    exec uwsm start hyprland-uwsm.desktop
fi


# Added by Antigravity CLI installer
export PATH="/home/steepskynet/.local/bin:$PATH"

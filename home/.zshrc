# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH=~/.npm-global/bin:$PATH


# Added by Antigravity CLI installer
export PATH="/home/steepskynet/.local/bin:$PATH"
export PATH="/home/steepskynet/.local/bin:$PATH"


# ---------------------------------------------------------------------
# Mis Alias y Atajos Personales
# ---------------------------------------------------------------------
alias lofi="bash /home/steepskynet/Documentos/anime/lofi_anime.sh"

# Pokémon Fastfetch
alias pokefetch="bash ~/.config/hypr/companion/pokefetch.sh"
alias pf="pokefetch"

# ============================================================
# 🐱 PokéFetch - Ejecutar al abrir terminal (Hyde style)
# ============================================================
# Descomenta la siguiente línea para que se ejecute automáticamente
# pokefetch

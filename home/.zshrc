# 1. Inicializaciones del sistema que modifican el entorno (Van antes de Instant Prompt)
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# 2. Cargar funciones interactivas base de Zsh (Evita fallos de p10k)
autoload -Uz compinit && compinit

# 3. Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 4. Cargar el tema y su configuración
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# 5. Exportaciones de PATH (Limpias y sin duplicados)
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.cargo/bin:$PATH"

# 6. Mis Alias y Atajos Personales
alias lofi="bash /home/steepskynet/Documentos/anime/lofi_anime.sh"
alias pokefetch="bash ~/.config/hypr/companion/pokefetch.sh"
alias pf="pokefetch"

# 7. Ejecución automática (Si decides activarla, déjala al final)
# pokefetch
export PATH="$HOME/.local/bin/eww:$PATH"

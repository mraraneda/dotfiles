# Start configuration

DOTFILES_PATH="$HOME/dotfiles"
DOTFILES_BASE_PATH="${DOTFILES_PATH}/base"

# 1) Entorno y herramientas base
source "${DOTFILES_BASE_PATH}/shell/exports.sh"

# 2) Aliases
source "${DOTFILES_BASE_PATH}/shell/aliases.sh"

# 3) Funciones (incluye ZLE widgets, timers, helpers)
source "${DOTFILES_BASE_PATH}/shell/functions.sh"

# 4) Prompt (Starship)
eval "$(starship init zsh)"

# Added by Antigravity
export PATH="/Users/marane4/.antigravity/antigravity/bin:$PATH"

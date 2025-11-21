# Enable aliases to be sudo’ed
alias sudo='sudo '

# ------------------------------------------------------------------------------
# ls / lsd (protegido por disponibilidad de lsd)
# ------------------------------------------------------------------------------
if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd'
  alias ll='lsd -lrt'
  alias l='ls -lrt'
  alias la='ls -lrta'
  alias lla='ls -la'
  alias lt='ls --tree'
else
  # Fallback razonable si lsd no está disponible
  alias ls='ls -F'
  alias ll='ls -alF'
  alias l='ls -lrt'
  alias la='ls -lrta'
  alias lla='ls -la'
  alias lt='ls -R'
fi

# ------------------------------------------------------------------------------
# Jumps
# cd ahora es gestionado por zoxide (--cmd cd en exports.sh)
# ------------------------------------------------------------------------------
alias ..="cd .."
alias ...="cd ../.."

# Jumps to specific paths
alias cgh="cd /Users/marane4/dev/github.com"
alias cge="cd /Users/marane4/dev/gecgithub01.walmart.com"
alias dev="cd ~/dev"

# ------------------------------------------------------------------------------
# Git
# ------------------------------------------------------------------------------
alias gaa="git add -A"
alias gc='$DOTLY_PATH/bin/dot git commit'
alias gca="git add --all && git commit --amend --no-edit"
alias gco="git checkout"
alias gd='$DOTLY_PATH/bin/dot git pretty-diff'
alias gs="git status -sb"
alias gf="git fetch --all -p"
alias gps="git push"
alias gpsf="git push --force"
alias gpl="git pull --rebase --autostash"
alias gb="git branch"
alias gl='$DOTLY_PATH/bin/dot git pretty-log'

# ------------------------------------------------------------------------------
# Utils (protegidos por disponibilidad)
# ------------------------------------------------------------------------------
if command -v idea >/dev/null 2>&1; then
  alias i.='(idea "$PWD" &>/dev/null &)'
fi

if command -v code >/dev/null 2>&1; then
  alias c.='(code "$PWD" &>/dev/null &)'
fi

alias o.='open .'
alias up='dot package update_all'
alias x='exit'

if command -v goland >/dev/null 2>&1; then
  alias g.='(goland "$PWD" &>/dev/null &)'
fi

if command -v rustrover >/dev/null 2>&1; then
  alias r.='(rustrover "$PWD" &>/dev/null &)'
fi

alias tailf="tail -F"

if command -v cmatrix >/dev/null 2>&1; then
  alias matrix="cmatrix -b -r"
fi

# ------------------------------------------------------------------------------
# Rust and Cargo
# ------------------------------------------------------------------------------
alias crun="cargo run"
alias ctest="cargo test"
alias cbuild="cargo build"
alias check="cargo check"

# ------------------------------------------------------------------------------
# VIM - NeoVIM
# ------------------------------------------------------------------------------
alias v='nvim'                              # default Neovim config
alias vim='nvim'                            # default Neovim config
alias vi='nvim'                             # default Neovim config
alias vz='NVIM_APPNAME=nvim-lazyvim nvim'   # LazyVim
alias vc='NVIM_APPNAME=nvim-nvchad nvim'    # NvChad
alias vk='NVIM_APPNAME=nvim-kickstart nvim' # Kickstart

# ------------------------------------------------------------------------------
# Containers
# ------------------------------------------------------------------------------
alias docker='podman'
alias docker-compose='podman compose'
alias dc='podman compose'

# ------------------------------------------------------------------------------
# cat wrapper: usar bat en interacción, cat real en pipes/redirecciones
# ------------------------------------------------------------------------------
# Queremos que al escribir "cat" en la terminal, se use bat con:
#  - color siempre
#  - numeración de líneas
#  - sin paginador (comportamiento tipo cat)
# Pero que en pipelines/scripts siga existiendo el cat clásico cuando
# la salida no va a una TTY (para no ensuciar con códigos de color).
# ------------------------------------------------------------------------------
if command -v bat >/dev/null 2>&1; then
  cat() {
    # Si stdout es un TTY (terminal interactiva)
    if [ -t 1 ]; then
      command bat --color=always --style=numbers --paging=never "$@"
    else
      # Si estamos en un pipe/redirección, delegar al cat real
      command cat "$@"
    fi
  }
fi

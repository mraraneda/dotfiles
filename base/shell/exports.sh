# Shell-wide environment and tooling setup for zsh

# ------------------------------------------------------------------------------
# Homebrew environment
# ------------------------------------------------------------------------------
if command -v brew >/dev/null 2>&1; then
  eval "$(brew shellenv)"
fi

# Default Homebrew prefix (Apple Silicon)
export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"

# Helper: detectar si la shell es interactiva (para no spamear warnings en scripts)
_is_interactive_shell() {
  [[ $- == *i* ]]
}

# ------------------------------------------------------------------------------
# Languages
# ------------------------------------------------------------------------------
export JAVA_HOME='/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home'
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"   # puedes ajustar a ${HOMEBREW_PREFIX} si quieres
export GEM_HOME="$HOME/.gem"
export PYENV_ROOT="$HOME/.pyenv"
export GOPATH="$HOME/.go"
export GOBIN="$GOPATH/bin"

# ------------------------------------------------------------------------------
# Apps / API keys (ojo: esto es sensible)
# ------------------------------------------------------------------------------
# Mantén aquí tu API key real; lo enmascaro en este ejemplo.
export OPENAI_API_KEY='TU_OPENAI_API_KEY_AQUI'

# ------------------------------------------------------------------------------
# Path - The higher it is, the more priority it has
# (usamos el array 'path' propio de zsh)
# ------------------------------------------------------------------------------
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$DOTFILES_PATH/bin"
  "$DOTFILES_PATH/scripts"
  "$JAVA_HOME/bin"
  "$GEM_HOME/bin"
  "$GOPATH/bin"
  "$HOME/.cargo/bin"
  "$HOME/.sledge/bin"
  "/opt/homebrew/opt/libpq/bin"
  "/usr/local/opt/ruby/bin"
  "/usr/local/opt/python/libexec/bin"
  "/usr/local/go/bin"
  "$HOMEBREW_PREFIX/bin"
  "/usr/local/bin"
  "/usr/local/sbin"
  "/bin"
  "/usr/bin"
  "/usr/sbin"
  "/sbin"
  "$path"
)
export path

# ------------------------------------------------------------------------------
# Handling env variables if you are connected to VPN Walmart
# (dejado tal cual, solo comentado)
# ------------------------------------------------------------------------------
# vpnstatus="$(/opt/cisco/anyconnect/bin/vpn status | tail -4 | head -1 | cut -d' ' -f5)"
#
# if [[ ${vpnstatus} == "Connected" ]]; then
#   export GOPRIVATE="gecgithub01.walmart.com/*"
#   export GONOPROXY="gecgithub01.walmart.com/*"
#   export GONOSUMDB="gecgithub01.walmart.com/*"
#   export HTTP_PROXY="http://sysproxy.wal-mart.com:8080"
#   export HTTPS_PROXY="http://sysproxy.wal-mart.com:8080"
# else # Variable delete
#   unset GOPRIVATE
#   unset GONOPROXY
#   unset GONOSUMDB
#   unset HTTP_PROXY
#   unset HTTPS_PROXY
#   export GOPROXY="https://proxy.golang.org,direct"
# fi

# ------------------------------------------------------------------------------
# zsh history configuration (alimenta autocomplete y Atuin)
# ------------------------------------------------------------------------------
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=200000
export SAVEHIST=200000

setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# Para recent_dirs y navegación con pushd
setopt AUTO_PUSHD PUSHD_SILENT PUSHD_IGNORE_DUPS

# ------------------------------------------------------------------------------
# zsh-autocomplete: autocompletado agresivo en vivo
# ------------------------------------------------------------------------------
_zsh_autocomplete_path="${HOMEBREW_PREFIX}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
if [[ -r "${_zsh_autocomplete_path}" ]]; then
  source "${_zsh_autocomplete_path}"
elif _is_interactive_shell; then
  echo "[zsh] WARNING: zsh-autocomplete plugin not found at ${_zsh_autocomplete_path}" >&2
fi

# Estilos básicos para zsh-autocomplete (puedes tunear más)
zstyle ':autocomplete:history-search:*' insert-unambiguous yes
zstyle ':autocomplete:history-search:*' fuzzy yes
zstyle ':autocomplete:*' min-input 1

# ------------------------------------------------------------------------------
# zsh-autosuggestions: autosugerencias basadas en historial (ghost-text)
# ------------------------------------------------------------------------------
_zsh_autosuggestions_path="${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
if [[ -r "${_zsh_autosuggestions_path}" ]]; then
  source "${_zsh_autosuggestions_path}"
elif _is_interactive_shell; then
  echo "[zsh] WARNING: zsh-autosuggestions plugin not found at ${_zsh_autosuggestions_path}" >&2
fi

# Color de las sugerencias (gris claro)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# ------------------------------------------------------------------------------
# fzf: key bindings + completion (Ctrl+T, Alt+C, etc.)
# (sin previews automáticas; previews quedan a cargo de widgets específicos)
# ------------------------------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
  if [[ -f "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh" ]]; then
    source "${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
  fi
  if [[ -f "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh" ]]; then
    source "${HOMEBREW_PREFIX}/opt/fzf/shell/completion.zsh"
  fi
fi

# ------------------------------------------------------------------------------
# Atuin: historial avanzado con Ctrl+R
# ------------------------------------------------------------------------------
if command -v atuin >/dev/null 2>&1; then
  # No dejes que Atuin haga sus propios keybindings; los controlamos nosotros
  export ATUIN_NOBIND="true"
  eval "$(atuin init zsh)"

  # Ctrl+R -> interfaz de búsqueda de Atuin
  bindkey '^r' atuin-search
elif _is_interactive_shell; then
  echo "[zsh] WARNING: Atuin not found in PATH; Ctrl+R fallback is the default zsh history search" >&2
fi

# ------------------------------------------------------------------------------
# zoxide: navegación inteligente basada en frecuencia
# ------------------------------------------------------------------------------
if command -v zoxide >/dev/null 2>&1; then
  # Haz que 'cd' sea zoxide-powered, respetando tu hábito de usar cd
  eval "$(zoxide init zsh --cmd cd)"
elif _is_interactive_shell; then
  echo "[zsh] WARNING: zoxide not found in PATH; 'cd' will behave as standard builtin" >&2
fi

# ------------------------------------------------------------------------------
# pyenv integration
# (equivalente a lo que tenías repartido entre exports.sh y functions.sh)
# ------------------------------------------------------------------------------
if command -v pyenv >/dev/null 2>&1; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  # --path para ajustar PATH; '-' para shims y completions
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
elif _is_interactive_shell; then
  echo "[zsh] WARNING: pyenv not found in PATH; Python version management may not be available" >&2
fi

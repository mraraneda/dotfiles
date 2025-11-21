# ------------------------------------------------------------------------------
# recent_dirs: pick from your directory stack using fzf
# ------------------------------------------------------------------------------
recent_dirs() {
  # This script depends on pushd. It works better with AUTO_PUSHD enabled in ZSH
  # (AUTO_PUSHD, PUSHD_SILENT, PUSHD_IGNORE_DUPS están en exports.sh)
  local escaped_home selected

  escaped_home=$(printf '%s\n' "$HOME" | sed 's/\//\\\//g')

  selected=$(dirs -p | sort -u | fzf) || return 1

  cd "$(printf '%s\n' "$selected" | sed "s/\~/$escaped_home/")" \
    || printf 'Invalid directory: %s\n' "$selected"
}

# ------------------------------------------------------------------------------
# zj: helper for zoxide interactive (zi)
# ------------------------------------------------------------------------------
zj() {
  if command -v zi >/dev/null 2>&1; then
    zi "$@"
  else
    echo "zoxide interactive command 'zi' not available"
  fi
}

# ------------------------------------------------------------------------------
# shell_doctor: quick check of core tools and dependencies used in your config
# ------------------------------------------------------------------------------
shell_doctor() {
  echo "Shell doctor:"
  local cmd

  # Herramientas base de shell / historial / navegación
  for cmd in brew fzf bat atuin zoxide pyenv; do
    if command -v "$cmd" >/dev/null 2>&1; then
      printf '  [OK]      %s\n' "$cmd"
    else
      printf '  [MISSING] %s\n' "$cmd"
    fi
  done

  # Herramientas usadas en alias y calidad de vida
  for cmd in lsd cmatrix idea code goland rustrover nvim podman; do
    if command -v "$cmd" >/dev/null 2>&1; then
      printf '  [OK]      %s\n' "$cmd"
    else
      printf '  [MISSING] %s\n' "$cmd"
    fi
  done

  # Plugins de zsh (validación de archivos en disco)
  echo "Plugins:"
  local auto_path="${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
  local sugg_path="${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

  if [[ -r "$auto_path" ]]; then
    printf '  [OK]      zsh-autocomplete (%s)\n' "$auto_path"
  else
    printf '  [MISSING] zsh-autocomplete plugin file (%s)\n' "$auto_path"
  fi

  if [[ -r "$sugg_path" ]]; then
    printf '  [OK]      zsh-autosuggestions (%s)\n' "$sugg_path"
  else
    printf '  [MISSING] zsh-autosuggestions plugin file (%s)\n' "$sugg_path"
  fi
}

# ------------------------------------------------------------------------------
# Command execution timer (preexec/precmd hooks)
# ------------------------------------------------------------------------------
# Mide el tiempo real de cada comando y muestra un aviso si toma > 2s.
# Usa EPOCHREALTIME (float) y los arrays preexec_functions/precmd_functions
# para no pisar otros hooks.
# ------------------------------------------------------------------------------
typeset -g MARCO_COMMAND_START_TIME=0

marco_preexec() {
  MARCO_COMMAND_START_TIME=$EPOCHREALTIME
}

marco_precmd() {
  if (( MARCO_COMMAND_START_TIME )); then
    local end diff
    end=$EPOCHREALTIME
    diff=$(( end - MARCO_COMMAND_START_TIME ))
    if (( diff > 2.0 )); then
      printf '⏱  Command took %.3fs\n' "$diff"
    fi
  fi
  MARCO_COMMAND_START_TIME=0
}

# Registra los hooks sin pisar otros que puedan existir
typeset -ga preexec_functions precmd_functions
preexec_functions+=('marco_preexec')
precmd_functions+=('marco_precmd')

# ------------------------------------------------------------------------------
# ZLE widgets avanzados
# ------------------------------------------------------------------------------
# 1) Ctrl+Right: aceptar autosugerencia completa (si zsh-autosuggestions está cargado)
# 2) Ctrl+Shift+Right: aceptar autosugerencia palabra por palabra
# 3) Ctrl+F: selector de archivos con fzf + bat (si están disponibles)
# 4) Ctrl+G: cd difuso con fzf (usa fd si está disponible, si no find)
# ------------------------------------------------------------------------------
# Aceptar autosugerencia completa con Ctrl+Right
if (( $+widgets[autosuggest-accept] )); then
  # ^[[1;5C suele ser Ctrl+Right en la mayoría de terminales
  bindkey '^[[1;5C' autosuggest-accept
fi

# Aceptar autosugerencia palabra por palabra con Ctrl+Shift+Right
_autosuggest_accept_word_by_word() {
  # Requiere zsh-autosuggestions
  local suggestion next_word
  suggestion=$ZSH_AUTOSUGGEST_BUFFER
  [[ -z "$suggestion" ]] && return 0

  # Toma la primera "palabra" de la sugerencia
  next_word=${suggestion%% *}

  BUFFER+="$next_word"
  # Si había más texto en la sugerencia, añade un espacio al final
  if [[ "$suggestion" == *" "* ]]; then
    BUFFER+=" "
  fi
  CURSOR=${#BUFFER}
}
zle -N autosuggest-accept-word-by-word _autosuggest_accept_word_by_word
# ^[[1;6C suele ser Ctrl+Shift+Right
bindkey '^[[1;6C' autosuggest-accept-word-by-word

# ------------------------------------------------------------------------------
# Ctrl+F: fzf_file_paste - seleccionar archivo y pegar ruta en la línea
# Usa bat como previsualización si está disponible, sin tocar FZF_DEFAULT_OPTS global.
# ------------------------------------------------------------------------------
fzf_file_paste() {
  local file

  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not available" >&2
    return 1
  fi

  if command -v bat >/dev/null 2>&1; then
    file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:200 {}' \
               --preview-window=right:60%) || return 1
  else
    file=$(fzf) || return 1
  fi

  [[ -z "$file" ]] && return 0

  BUFFER+="$file"
  CURSOR=${#BUFFER}
}
zle -N fzf-file-paste fzf_file_paste
# Ctrl+F
bindkey '^F' fzf-file-paste

# ------------------------------------------------------------------------------
# Ctrl+G: fzf_cd - fuzzy cd usando fd si existe, si no find
# ------------------------------------------------------------------------------
fzf_cd() {
  local dir

  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not available" >&2
    return 1
  fi

  if command -v fd >/dev/null 2>&1; then
    dir=$(fd -t d . "$HOME" 2>/dev/null | fzf --preview 'ls -la {}' --preview-window=right:60%) || return 1
  else
    dir=$(find "$HOME" -type d 2>/dev/null | fzf --preview 'ls -la {}' --preview-window=right:60%) || return 1
  fi

  [[ -z "$dir" ]] && return 0

  cd "$dir" || return 1
  # Refresca el prompt después del cd
  zle reset-prompt
}
zle -N fzf-cd fzf_cd
# Ctrl+G
bindkey '^G' fzf-cd

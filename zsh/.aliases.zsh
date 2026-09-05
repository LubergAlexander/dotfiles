alias gpm='gcm && ggpull && gco -'
if [[ "$OSTYPE" == darwin* ]]; then
  alias brewall='brew update && brew upgrade && brew cleanup'
fi
alias vim='nvim'
alias vimdiff='nvim -d'
alias ls='eza'
alias ll='eza -la --git'
alias tree='eza --tree'
alias uv-tools-upgrade='uv tool upgrade --all'

update_neovim_venvs () {
  local venv="$HOME/.virtualenvs/neovim3"
  if [[ ! -e "$venv" && ! -L "$venv" ]]; then
    uv venv --python python3 "$venv" || return
  fi
  if [[ ! -f "$venv/pyvenv.cfg" || ! -x "$venv/bin/python" ]]; then
    print -u2 -- "Refusing to replace $venv: move the existing path to a backup and retry."
    return 1
  fi
  uv pip install --python "$venv/bin/python" --upgrade pynvim
}

# Respect an explicit theme; otherwise follow macOS appearance or default dark.
bat() {
  local mode=dark
  if [[ -z "$BAT_THEME" && "$OSTYPE" == darwin* ]] && (( $+commands[dark-notify] )); then
    [[ "$(dark-notify -e)" != light ]] || mode=light
  fi
  BAT_THEME="${BAT_THEME:-gruvbox-$mode}" command bat "$@"
}

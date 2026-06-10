alias gpm='gcm && ggpull && gco -'
alias brewall='brew update && brew upgrade && brew cleanup'
alias vim='nvim'
alias vimdiff='nvim -d'
alias ls='eza'
alias ll='eza -la --git'
alias tree='eza --tree'
alias pip-upgrade="pip list --outdated | sed 's/(.*//g' | xargs -n1 pip install -U"

update_neovim_venvs () {
  rm -rf ~/.virtualenvs/neovim*;

  python3 -m venv ~/.virtualenvs/neovim3;

  source ~/.virtualenvs/neovim3/bin/activate;
  pip install --upgrade pip pynvim;

  deactivate;
}

# Bat wrapper with dark-mode detection
bat() {
    BAT_THEME="gruvbox-$(dark-notify -e)" command bat "$@"
}

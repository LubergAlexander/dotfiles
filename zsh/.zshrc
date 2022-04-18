# Zsh settings
# Environment
BREW_PREFIX="$(brew --prefix)"

ZSH=$HOME/.oh-my-zsh
ZSH_THEME="kolo"
DISABLE_UPDATE_PROMPT="true"
DISABLE_LS_COLORS="true"
plugins=(git brew sudo macos)

export SHELL="$BREW_PREFIX/bin/zsh"
export EDITOR="$BREW_PREFIX/bin/nvim"
export GIT_EDITOR="$EDITOR"
export FONTCONFIG_PATH="/opt/X11/lib/X11/fontconfig"
export GOPATH="$BREW_PREFIX/gobin"
export TERM=screen-256color
export VIRTUALENVWRAPPER_PYTHON="$BREW_PREFIX/bin/python3"
export WORKON_HOME="$HOME/.virtualenvs"
export DASHT_DOCSETS_DIR="$HOME/.dasht"
export MPD_HOST="::1"

# Extra environment/aliases
source "$HOME/.linkedin.environment.zsh"
source "$HOME/.aliases.zsh"
source "$ZSH/oh-my-zsh.sh"
source "$BREW_PREFIX/etc/profile.d/z.sh"
source "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

path=(
  "$HOME/node_tools/node_modules/.bin"      # node/js tooling
  "$BREW_PREFIX/opt/node@6/bin"
  "$BREW_PREFIX/opt/go/libexec/bin"         # go
  "$BREW_PREFIX/opt/gnu-sed/libexec/gnubin" # override system sed with gnu-sed
  $path
)

workon() {
  source "$BREW_PREFIX/bin/virtualenvwrapper.sh"
  workon $@
}

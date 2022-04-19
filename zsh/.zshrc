# Zsh settings
# Environment
unsetopt nomatch

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        BREW_PREFIX="/usr/"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        BREW_PREFIX="$(brew --prefix)"
fi

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
source "$HOME/.aliases.zsh"
source "$ZSH/oh-my-zsh.sh"

if [[ "$OSTYPE" == "darwin"* ]]; then
        source "$HOME/.linkedin.environment.zsh"
        source "$BREW_PREFIX/etc/profile.d/z.sh"
        source "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

        workon() {
          source "$BREW_PREFIX/bin/virtualenvwrapper.sh"
          workon $@
        }
fi

path=(
  "$HOME/node_tools/node_modules/.bin"      # node/js tooling
  "$BREW_PREFIX/opt/node@6/bin"
  "$BREW_PREFIX/opt/go/libexec/bin"         # go
  "$BREW_PREFIX/opt/gnu-sed/libexec/gnubin" # override system sed with gnu-sed
  "$HOME/.gem/ruby/2.6.0/bin"               # ruby
  $path
)

workon() {
  source "$BREW_PREFIX/bin/virtualenvwrapper.sh"
  workon $@
}
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

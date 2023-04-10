# Zsh settings
# Environment
unsetopt nomatch

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        BREW_PREFIX="/usr/"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        BREW_PREFIX="/opt/homebrew/"
fi

ZSH=$HOME/.oh-my-zsh
ZSH_THEME="kolo"
DISABLE_UPDATE_PROMPT="true"
DISABLE_LS_COLORS="true"
plugins=(git brew)

export SHELL="$BREW_PREFIX/bin/zsh"
export EDITOR="$BREW_PREFIX/bin/nvim"
export GIT_EDITOR="$EDITOR"
export GOPATH="$BREW_PREFIX/gobin"

# Extra environment/aliases
source "$HOME/.aliases.zsh"
source "$ZSH/oh-my-zsh.sh"

path=(
  "$BREW_PREFIX/bin"
  "$HOME/node_tools/node_modules/.bin"      # node/js tooling
  "$HOME/.gem/ruby/2.6.0/bin"               # ruby
  "/opt/homebrew/opt/libcouchbase@2/bin"
  $path
)
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Instant prompt initialization
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 256 colors & Ghostty handling
export TERM="xterm-256color"
[ -n "$TMUX" ] && export TERM="tmux-256color"

<<<<<<< HEAD
# Editor setup
export EDITOR="nvim"
export VISUAL="$EDITOR"
export GIT_EDITOR="$EDITOR"
<<<<<<< HEAD
export GOPATH=$HOME/go

# Path setup
path=("$GOPATH/bin" "$BREW_PREFIX/bin" "$BREW_PREFIX/sbin" $path)
=======

# Path setup
path=(
    "$BREW_PREFIX/bin"
    "$BREW_PREFIX/sbin"
    "${KREW_ROOT:-$HOME/.krew}/bin"
    "/opt/homebrew/Cellar/mysql@8.0/8.0.40/bin"
    $path
)
>>>>>>> afced96 (cleanup of zshrc)
typeset -U path

# Load Zinit
=======
# Zinit initialization
>>>>>>> 776c22b (zshrc config)
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Environment setup
export EDITOR="nvim"
export VISUAL="$EDITOR"
export GIT_EDITOR="$EDITOR"

<<<<<<< HEAD
zinit snippet OMZL::git.zsh
<<<<<<< HEAD
=======
zinit snippet OMZL::directories.zsh
>>>>>>> afced96 (cleanup of zshrc)
zinit snippet OMZL::history.zsh
zinit snippet OMZL::key-bindings.zsh
zinit snippet OMZP::git
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::kube-ps1
=======
# Path configuration - moved after brew to use its paths
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew";
fi
>>>>>>> 776c22b (zshrc config)


path=(
    "$HOMEBREW_PREFIX/bin"
    "$HOMEBREW_PREFIX/sbin"
    "$HOMEBREW_PREFIX/opt/mysql@8.0/bin"
    "$HOME/.krew/bin"
    "$HOME/.cargo/bin"
    "$HOME/.volta/bin"
    $path
)
typeset -U path

# Add completions paths
[[ ! -d ${ZSH_CACHE_DIR}/completions ]] && mkdir -p ${ZSH_CACHE_DIR}/completions

fpath=(
    "$HOMEBREW_PREFIX/share/zsh/site-functions/"
    "$ZSH_CACHE_DIR/completions"
    $fpath
)
typeset -U fpath

# Core ZSH configuration
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' completer _expand _complete _correct _approximate

# FZF-tab styling
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Docker completion for stacked flags
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# Key bindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History settings
HISTSIZE=50000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory sharehistory
setopt hist_ignore_all_dups hist_find_no_dups
setopt AUTO_CD
unsetopt nomatch

<<<<<<< HEAD
# Source additional configurations
source ~/.zsh_colors
<<<<<<< HEAD
=======
# Theme
zinit ice depth=1 lucid
zinit light romkatv/powerlevel10k

# Load p10k config (needed for prompt)
>>>>>>> 776c22b (zshrc config)
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Essential plugins
zinit wait lucid light-mode for \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-completions \
    Aloxaf/fzf-tab

# Core plugins & snippets
zinit wait lucid for \
    OMZL::git.zsh \
    OMZL::history.zsh \
    OMZL::directories.zsh \
    OMZL::theme-and-appearance.zsh \
    OMZP::sudo \
    OMZP::zoxide \
    OMZP::fzf

# Development tools
zinit wait lucid for \
    OMZP::git \
    OMZP::kubectl \
    OMZP::kubectx \
    OMZP::argocd \
    OMZP::direnv \
    OMZP::docker \
    OMZP::helm \
    OMZP::command-not-found \
    OMZP::colored-man-pages

# Local configs
zinit wait lucid is-snippet for ~/.aliases.zsh

=======
source ~/.aliases.zsh
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
# $HOME/.cargo/bin is added to user PATH by MDM
case ":${PATH}:" in
    *:"$HOME/.cargo/bin":*)
    ;;
    *)
    export PATH="$PATH:$HOME/.cargo/bin"
    ;;
esac
>>>>>>> afced96 (cleanup of zshrc)

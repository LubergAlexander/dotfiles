# Must be first lines of .zshrc
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
typeset -g POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false

# Minimal p10k config for faster startup
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

# Instant prompt initialization
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
 source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

skip_global_compinit=1
DISABLE_COMPFIX=true
ZSH_DISABLE_COMPFIX=true

# Performance optimization
typeset -g HISTFILE_LOCK_TIMEOUT=5
typeset -g ZSH_AUTOSUGGEST_MANUAL_REBIND=1
typeset -g ZSH_AUTOSUGGEST_USE_ASYNC=1

# 256 colors & Ghostty handling
export TERM="xterm-256color"
[ -n "$TMUX" ] && export TERM="tmux-256color"

# Zinit initialization
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[[ ! -d "$ZINIT_HOME" ]] && mkdir -p "$(dirname $ZINIT_HOME)" && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Reduce zinit's self-reporting
ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1
ZINIT[COMPINIT_OPTS]=-C

# Environment setup
export EDITOR="nvim"
export VISUAL="$EDITOR"
export GIT_EDITOR="$EDITOR"
# SSH-Agent(linux)
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket

# Path configuration
if [[ -f "/opt/homebrew/bin/brew" ]]; then
 export HOMEBREW_PREFIX="/opt/homebrew";
fi
path=(
   "$HOMEBREW_PREFIX/bin"
   "$HOMEBREW_PREFIX/sbin"
   "$HOMEBREW_PREFIX/opt/mysql@8.0/bin"
   "$HOMEBREW_PREFIX/opt/rustup/bin"
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

# Optimized completion initialization
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
 compinit -C
else
 compinit
 zcompile ${ZDOTDIR}/.zcompdump
fi
_comp_options+=(globdots)

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' completer _expand _complete _correct _approximate

# FZF-tab styling
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Docker completion
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# History settings
HISTSIZE=50000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory sharehistory
setopt hist_ignore_all_dups hist_find_no_dups
setopt AUTO_CD
unsetopt nomatch

# Theme with minified loading
zinit ice depth=1 atload'source ~/.p10k.zsh' nocd
zinit light romkatv/powerlevel10k

# Essential plugins in turbo mode
zinit wait'0' lucid for \
   atinit"zicompinit; zicdreplay" \
   zdharma-continuum/fast-syntax-highlighting \
   atload"_zsh_autosuggest_start" \
   zsh-users/zsh-autosuggestions

# Completions and tools
zinit wait'0' lucid for \
   blockf \
   zsh-users/zsh-completions \
   Aloxaf/fzf-tab

# Basic OMZ libs
zinit wait'0' lucid for \
   OMZL::git.zsh \
   OMZL::history.zsh \
   OMZL::directories.zsh \
   OMZL::theme-and-appearance.zsh

# Common development tools
zinit wait'1' lucid for \
   OMZP::sudo \
   OMZP::zoxide \
   OMZP::fzf \
   OMZP::git \
   OMZP::kubectl \
   OMZP::docker \
   OMZP::helm

# Less frequently used plugins
zinit wait'2' lucid for \
   OMZP::kubectx \
   OMZP::direnv \
   OMZP::command-not-found \
   OMZP::colored-man-pages \
   is-snippet ~/.aliases.zsh

# Enable Powerlevel10k instant prompt
if [[ $TERM == "xterm-ghostty" ]]; then
    export TERM="xterm-256color"
fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# OS-specific setup
if [[ "$OSTYPE" == "darwin"* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    BREW_PREFIX="/usr"
fi

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
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -f $ZINIT_HOME/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing Zinit...%f"
    command mkdir -p "$(dirname $ZINIT_HOME)"
    command git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Load plugins and snippets
zinit light-mode for \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-completions

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

# Load Powerlevel10k theme
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Completions and hooks
autoload -Uz compinit && compinit -C

(( $+commands[kubectl] )) && source <(kubectl completion zsh)
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# Zsh options
setopt AUTO_CD
unsetopt nomatch

# Source additional configurations
source ~/.zsh_colors
<<<<<<< HEAD
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
check_custom_aliases() {
    # Read aliases.zsh and store only its aliases
    local -A custom_aliases
    while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]*alias[[:space:]]+([-_a-zA-Z0-9]+)=(.+)$ ]]; then
            local alias_name="${match[1]}"
            local alias_value="${match[2]}"
            custom_aliases[$alias_name]=$alias_value
        fi
    done < "$HOME/.aliases.zsh"

    # Now check each custom alias against loaded plugin aliases
    for k v in "${(kv)custom_aliases[@]}"; do
        if [[ -n "${aliases[$k]}" && "${aliases[$k]}" != "$v" ]]; then
            echo "Found overlap for: $k"
            echo "Plugin defines as: ${aliases[$k]}"
            echo "Your aliases.zsh defines as: $v"
            echo "---"
        fi
    done
}

check_custom_aliases
#source ~/.aliases.zsh


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

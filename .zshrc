# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="robbyrussell"
ZSH_THEME="kolo"
DISABLE_UPDATE_PROMPT="true"
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git brew svn osx pip fabric virtualenvwrapper)

source $ZSH/oh-my-zsh.sh
# source /Users/luberg/Library/Python/2.7/lib/python/site-packages/powerline/bindings/zsh/powerline.zsh

# Customize to your needs...
export PATH=/Users/luberg/Library/Python/2.7/bin:/Users/luberg/Library/Python/2.7/lib/python/site-packages:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin:/usr/local/sbin

export GREP_OPTIONS="--exclude=\*.svn\*"
sublime(){ subl `find . -iname "$1"`; }
fvim(){ vim `find . -iname "$1"`; }
svnvimlog(){ svn log -v "$1" | vim -; }
# find file with same name in 2 different directories and compare
dcmdiff(){ vimdiff `find "$1" -iname "$3"` `find "$2" -iname "$3"`; }
# full context diff
fulldiff() {
    # $4 - outfile patch
    # $3 - to revision
    # $2 - from revision
    # $1 - branch
svn diff --old=$1@$2 --new=$1@$3 --diff-cmd /usr/bin/diff -x "-U 10000" > $4
}
alias ..='cd ..'
alias .='pwd'
alias c='~/Code'
tmux attach -t base || tmux new -s base

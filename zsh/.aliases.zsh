alias gpm='gcm && ggpull && gco -'
alias brewall='brew update && brew upgrade && brew cleanup && brew prune'
alias vim='nvim'
alias vimdiff='nvim -d'
alias dockerrmall="docker rm -f `docker ps -a -q`"
alias octave='octave-cli'
alias youtube-dl="youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4'"
alias mux='tmuxinator'
alias inops='mux start inops'
alias pivo='mux start pivo'
alias pip-upgrade="pip list --outdated | sed 's/(.*//g' | xargs -n1 pip install -U"

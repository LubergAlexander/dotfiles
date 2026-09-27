# Gruvbox colors for zinit's own output (update, self-update, reports).
#
# zinit hardcodes 256-color indices (\e[38;5;Nm and %F{N}), which bypass the
# terminal palette. Everything here uses only the 16 ANSI slots, so Ghostty's
# gruvbox-dark / gruvbox-light themes supply the actual colors.
#
# Source right after zinit.zsh. `zinit self-update` re-sources zinit.zsh when it
# pulls new commits, which restores the defaults for the rest of that run.

# zinit leaves colors empty when the terminal has none; keep it that way.
[[ -n ${ZINIT[col-rst]} ]] || return 0

ZINIT+=(
  col-annex   $'\e[36m'       col-faint   $'\e[90m'       col-msg2    $'\e[33m'       col-quo     $'\e[1;34m'
  col-apo     $'\e[1;36m'     col-file    $'\e[3;34m'     col-msg3    $'\e[90m'       col-quos    $'\e[1;31m'
  col-aps     $'\e[34m'       col-flag    $'\e[1;3;36m'   col-func    $'\e[35m'       col-slight  $'\e[37m'
  col-b-lhi   $'\e[1;34m'     col-glob    $'\e[33m'       col-b-warn  $'\e[1;33m'     col-happy   $'\e[1;32m'
  col-note    $'\e[32m'       col-bapo    $'\e[1;33m'     col-hi      $'\e[1;35m'     col-term    $'\e[33m'
  col-baps    $'\e[1;32m'     col-ice     $'\e[34m'       col-th-bar  $'\e[32m'       col-bar     $'\e[32m'
  col-id-as   $'\e[4;33m'     col-num     $'\e[3;32m'     col-time    $'\e[33m'       col-bcmd    $'\e[33m'
  col-info    $'\e[32m'       col-obj     $'\e[35m'       col-txt     $'\e[39m'       col-info2   $'\e[33m'
  col-obj2    $'\e[32m'       col-cmd     $'\e[32m'       col-info3   $'\e[1;33m'     col-ok      $'\e[33m'
  col-u-warn  $'\e[4;33m'     col-data    $'\e[32m'       col-opt     $'\e[35m'       col-uname   $'\e[1;4;35m'
  col-data2   $'\e[34m'       col-keyword $'\e[32m'       col-p       $'\e[36m'       col-uninst  $'\e[32m'
  col-dir     $'\e[3;34m'     col-lhi     $'\e[36m'       col-pkg     $'\e[1;3;34m'   col-url     $'\e[34m'
  col-ehi     $'\e[1;31m'     col-meta    $'\e[35m'       col-pname   $'\e[1;4;32m'   col-var     $'\e[36m'
  col-error   $'\e[1;31m'     col-meta2   $'\e[35m'       col-pre     $'\e[35m'       col-version $'\e[3;36m'
  col-failure $'\e[31m'       col-profile $'\e[32m'       col-warn    $'\e[33m'
  col-e       $'\e[1;31m'"Error"$'\e[0m'":"
  col-i       $'\e[1;32m'"==>"$'\e[0m'
  col-m       $'\e[34m'"==>"$'\e[0m'
  col-w       $'\e[1;33m'"Warning"$'\e[0m'":"
  col-mdsh    $'\e[1;33m'"${${${(M)LANG:#*UTF-8*}:+–}:--}"$'\e[0m'
  col-mmdsh   $'\e[1;33m'"${${${(M)LANG:#*UTF-8*}:+――}:--}"$'\e[0m'
  col-↔       ${${${(M)LANG:#*UTF-8*}:+$'\e[32m↔\e[0m'}:-$'\e[32m«-»\e[0m'}
)

# Replaces zinit.zsh's .zinit-formatter-url, which colors URLs and snippet IDs
# such as OMZP::git with %F{220}/%F{227}/%F{82}/%F{183}/%F{81}. Same parsing,
# ANSI colors: scheme/separators yellow, host green, TLD magenta, path cyan.
.zinit-formatter-url() {
  builtin emulate -LR zsh -o extendedglob
  #              1:proto        3:domain/5:start      6:end-of-it         7:no-dot-domain        9:file-path
  if [[ $1 = (#b)([^:]#)(://|::)((([[:alnum:]._+-]##).([[:alnum:]_+-]##))|([[:alnum:].+_-]##))(|/(*)) ]]; then
    local y=$'\e[22;33m' g=$'\e[1;32m' m=$'\e[1;35m' c=$'\e[22;36m' rst=$'\e[0m'
    if [[ -n $match[4] ]]; then
      REPLY=$y$match[1]$match[2]$g$match[5]$y.$m$match[6]$rst
    else
      REPLY=$y$match[1]$match[2]$g$match[7]$rst
    fi
    [[ -n $match[9] ]] && REPLY+=$y/$c${match[9]//\//$y/$c}$rst
  else
    REPLY=$ZINIT[col-url]$1$ZINIT[col-rst]
  fi
}

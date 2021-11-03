# zplug
export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug 'zplug/zplug', hook-build:'zplug --self-manage'
# 非同期処理できるようになる
zplug "mafredri/zsh-async"

# テーマ(ここは好みで。調べた感じpureが人気)
#zplug "sindresorhus/pure"
#zplug "eendroroy/alien"
#zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme, as:theme
#zplug "themes/wedisagree", from:oh-my-zsh, as:theme
#zplug "themes/agnoster", from:oh-my-zsh
#zplug "themes/RobbyRussell", from:oh-my-zsh
zplug 'dracula/zsh', as:theme

# 構文のハイライト(https://github.com/zsh-users/zsh-syntax-highlighting)
zplug "zsh-users/zsh-syntax-highlighting"
# コマンド入力途中で上下キー押したときの過去履歴がいい感じに出るようになる
zplug "zsh-users/zsh-history-substring-search"
# 過去に入力したコマンドの履歴が灰色のサジェストで出る
zplug "zsh-users/zsh-autosuggestions"
# 補完強化
zplug "zsh-users/zsh-completions"
# 256色表示にする
zplug "chrissicool/zsh-256color"
# コマンドライン上の文字リテラルの絵文字を emoji 化する
zplug "mrowa44/emojify", as:command
# install z
zplug "rupa/z", use:z.sh

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi
# コマンドの履歴機能
# 履歴ファイルの保存先
HISTFILE=$HOME/.zsh_history
# メモリに保存される履歴の件数
HISTSIZE=10000
# HISTFILE で指定したファイルに保存される履歴の件数
SAVEHIST=10000
# Then, source plugins and add commands to $PATH
zplug load


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniforge/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniforge/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# Starship
eval "$(starship init zsh)"

# fasd
eval "$(fasd --init posix-alias zsh-hook)"

# exa alias
if [[ $(command -v exa) ]]; then
  alias e='exa --icons --git'
  alias l=e
  alias ls=e
  alias ea='exa -a --icons --git'
  alias la=ea
  alias ee='exa -aahl --icons --git'
  alias ll=ee
  alias et='exa -T -L 3 -a -I "node_modules|.git|.cache" --icons'
  alias lt=et
  alias eta='exa -T -a -I "node_modules|.git|.cache" --color=always --icons | less -r'
  alias lta=eta
  alias l='clear && ls'
fi

# fzf
zplug "junegunn/fzf", from:gh-r, as:command, rename-to:fzf

# ghq
alias g='cd $(ghq root)/$(ghq list | fzf --reverse)'

# git
alias -g B='`git branch --all | grep -v HEAD | fzf -m | sed "s/.* //" | sed "s#remotes/[^/]*/##"`'

fbr() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

# fshow - git commit browser
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

fzf-z-search() {
    local res=$(z | sort -rn | cut -c 12- | fzf)
    if [ -n "$res" ]; then
        BUFFER+="cd $res"
        zle accept-line
    else
        return 1
    fi
}

zle -N fzf-z-search
bindkey '^f' fzf-z-search


# fzf
cd-fzf-find() {
    local DIR=$(find ./ -path '*/\.*' -name .git -prune -o -type d -print 2> /dev/null | fzf +m)
    if [ -n "$DIR" ]; then
        cd $DIR
    fi
}
alias fd=cd-fzf-find

function cd-fzf-ghqlist() {
    local GHQ_ROOT=`ghq root`
    local REPO=`ghq list -p | sed -e 's;'${GHQ_ROOT}/';;g' |fzf +m`
    if [ -n "${REPO}" ]; then
        BUFFER="cd ${GHQ_ROOT}/${REPO}"
    fi
    zle accept-line
}
zle -N cd-fzf-ghqlist
bindkey '^G' cd-fzf-ghqlist

function buffer-fzf-history() {
    local HISTORY=$(history -n -r 1 | fzf +m)
    BUFFER=$HISTORY
    if [ -n "$HISTORY" ]; then
        CURSOR=$#BUFFER
    else
        zle accept-line
    fi
}
zle -N buffer-fzf-history
bindkey '^R' buffer-fzf-history

unalias z
# fasd & fzf change directory - jump using `fasd` if given argument, filter output of `fasd` using `fzf` else
z() {
    [ $# -gt 0 ] && fasd_cd -d "$*" && return
    local dir
    dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "${dir}" || return 1
}


fe() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}


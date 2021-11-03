
### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/z-a-rust \
    zdharma-continuum/z-a-as-monitor \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-bin-gem-node

### End of Zinit's installer chunk


#################################  COMPLEMENT  #################################
# enable completion
autoload -Uz compinit && compinit

# 補完候補をそのまま探す -> 小文字を大文字に変えて探す -> 大文字を小文字に変えて探す
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}'

### 補完方法毎にグループ化する。
zstyle ':completion:*' format '%B%F{blue}%d%f%b'
zstyle ':completion:*' group-name ''


### 補完侯補をメニューから選択する。
### select=2: 補完候補を一覧から選択する。補完候補が2つ以上なければすぐに補完する。
zstyle ':completion:*:default' menu select=2


#################################  テーマ  #################################
# テーマ
zinit ice as"theme"
zinit load dracula/zsh


#################################  プラグイン  #################################
# 構文のハイライト(https://github.com/zsh-users/zsh-syntax-highlighting)
zinit load zsh-users/zsh-syntax-highlighting

# コマンド入力途中で上下キー押したときの過去履歴がいい感じに出るようになる
zinit load zsh-users/zsh-history-substring-search

# 過去に入力したコマンドの履歴が灰色のサジェストで出る
zinit load zsh-users/zsh-autosuggestions

# 補完強化
zinit load zsh-users/zsh-completions

# 256色表示にする
zinit load chrissicool/zsh-256color

# コマンドライン上の文字リテラルの絵文字を emoji 化する
zinit ice as"command" cp"zemojify* -> emojify"
zinit load filipekiss/zemojify

# jq をインタラクティブに使える。JSONを標準出力に出すコマンドを入力した状態で `Alt+j` すると jq のクエリが書ける。
# 要 jq
zinit light reegnz/jq-zsh-plugin

# batをインストールし、catの代わりにbatを呼び出す
zinit ice as"program" from"gh-r" mv"bat* -> bat" pick"bat/bat"
zinit light sharkdp/bat
if [[ $(command -v bat) ]]; then
  alias cat="bat"
fi

# fzf
zinit ice from"gh-r" as"command" mv"fzf"
zinit load junegunn/fzf

# fzfでpreviewする。Ctrl-oでvscodeで開く
# https://qiita.com/kompiro/items/a09c0b44e7c741724c80
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --no-messages --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS='--preview "bat  --color=always --style=header,grid --line-range :100 {}"'
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='
--height 50% --reverse --border
--bind="ctrl-o:execute(code {})+abort"
--color fg:15,fg+:15,bg+:239,hl+:108
--color info:2,prompt:109,spinner:2,pointer:168,marker:168
'


#################################  zsh設定  #################################
# コマンドの履歴機能
# 履歴ファイルの保存先
HISTFILE=$HOME/.zsh_history
# メモリに保存される履歴の件数
HISTSIZE=10000
# HISTFILE で指定したファイルに保存される履歴の件数
SAVEHIST=10000


#################################  連携設定  #################################

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
if [[ $(command -v starship) ]]; then
    eval "$(starship init zsh)"
fi

# fasd
if [[ $(command -v fasd) ]]; then
    eval "$(fasd --init posix-alias zsh-hook)"
fi

# exaがインストールされてたらlsの代わりに使うようにする
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


# fbrコマンドで今ローカルに存在するbranchを選択して切り替えられるように
# https://qiita.com/kamykn/items/aa9920f07487559c0c7e
fbr() {
    local branches branch
    branches=$(git branch -vv) &&
    branch=$(echo "$branches" | fzf +m) &&
    git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

# fshow - git commit browser
# https://qiita.com/kamykn/items/aa9920f07487559c0c7e
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


# ディレクトリ配下のディレクトリに移動する(find > cd)
# https://qiita.com/lighttiger2505/items/1d2b93cbbfb31fa87786
cd-fzf-find() {
    local DIR=$(find ./ -path '*/\.*' -name .git -prune -o -type d -print 2> /dev/null | fzf +m)
    if [ -n "$DIR" ]; then
        cd $DIR
    fi
}
alias fd=cd-fzf-find


# ghqでgetしたレポジトリ一覧をfzfで絞り込み素早くcdする
# レポジトリのTOPにあるREADMEをbatでpreviewする機能付き
# https://qiita.com/kompiro/items/a09c0b44e7c741724c80
function cd-fzf-ghqlist() {
    local GHQ_ROOT=`ghq root`
    local REPO=`ghq list -p | sed -e 's;'${GHQ_ROOT}/';;g' |fzf --height 70% --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*" +m`
    if [ -n "${REPO}" ]; then
        BUFFER="cd ${GHQ_ROOT}/${REPO}"
    fi
    zle accept-line
}
zle -N cd-fzf-ghqlist
bindkey '^G' cd-fzf-ghqlist


# historyをfzfで絞り込む
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


# fasd & fzf change directory - jump using `fasd` if given argument, filter output of `fasd` using `fzf` else
# https://github.com/junegunn/fzf/wiki/examples
unalias z
z() {
    [ $# -gt 0 ] && fasd_cd -d "$*" && return
    local dir
    dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "${dir}" || return 1
}


# feコマンドで、ファイルの一覧を表示し、選択したファイルをエディタで開く
fe() {
    local files
    IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
    [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}


#!/bin/zsh

# A lot from http://www.aperiodic.net/phil/prompt/

PR_FLAGS=()
PR_SAVED_STATUS="0"

function pr_width {
    local pat
    pat="%{*%}"
    msg=${(%)${(S)${(e)1}//${~pat}}}
    print -n ${#msg}
}

function pr_justify {
    local strwidth divider parts targwidth numitems
    local toshift eachshift extrashift premsg

    premsg="$1"
    divider="${2:----}"
    targwidth="${3:-${COLUMNS}}"
    padstring="${4:- }"

    strwidth=$(pr_width "$premsg")
    parts="\${(ps:${divider}:)premsg}"
    parts=( ${(e)parts} )
    numitems=${#parts}

    if [[ $numitems == "1" ]]; then
        echo -n "$premsg"
        return
    fi

    (( strwidth = strwidth - (3 * (numitems - 1) ) ))
    (( toshift = (targwidth - strwidth) ))
    (( eachshift = toshift / (numitems - 1) ))
    (( extrashift = toshift - (eachshift * (numitems - 1) ) ))
    if (( eachshift < 0 )) || (( extrashift < 0 )) ; then
        echo -n "$premsg"
        return
    fi

    padder="\${(l.extrashift..${padstring}.)}"
    premsg=${premsg/${divider}/${(e)padder}${divider}}
    padder="\${(l.eachshift..${padstring}.)}"
    premsg=${premsg//${divider}/${(e)padder}}
    echo -n "$premsg"
}

function pr_sig_num {
    local val
    val=$PR_SAVED_STATUS
    if ((val == 0)); then
        return 0
    fi

    echo -n "${fg_bold[red]}"
    if ((val < 128)); then
        echo -n "$val"
    else
        ((val = val-128))
        echo -n `kill -l $val`
    fi
    return 0
}

function pr_loadflags {
    local -a flag_strings
    for a in "$PR_FLAGS[@]"; do
        local thisflag="`eval $a`"
        if [[ -z "$thisflag" ]] ; then
            thisflag="-"
        fi
        flag_strings+=( '%{${fg_bold[white]}%}'"$thisflag"'%{${fg_bold[green]}%}' )
    done
    echo "${(e):-${(j/:/)flag_strings}}"
}

ZSH_THEME_GIT_PROMPT_PREFIX="%{${fg_no_bold[yellow]}%}"
ZSH_THEME_GIT_PROMPT_SUFFIX=""

PR_FLAGS+=(pr_sig_num)
PR_FLAGS+=(git_prompt_info)

PROMPT_TOP_LINE='%{${fg_bold[white]}%}[%{${fg_no_bold[yellow]}%}%D{%H:%M}%{${fg_bold[white]}%}]\
 %{${fg_no_bold[green]}%}%n@%m\
---$(pr_loadflags)---%{${fg_bold[white]}%}[%{$fg_no_bold[yellow]%}%D{%a, %b %d}%{${fg_bold[white]}%}]'

PROMPT='\
${${PR_SAVED_STATUS::=$?}##*}${(e):-$(pr_justify "$PROMPT_TOP_LINE")}
%{${fg_bold[magenta]}%}%4~%{${fg_bold[white]}%} \
%# %{$reset_color%}'

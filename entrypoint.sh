#!/bin/sh
set -e

#/*
# * This file is part of TangoMan Makefile Generator package.
# *
# * Copyright (c) 2021 "Matthias Morin" <mat@tangoman.io>
# *
# * This source file is subject to the MIT license that is bundled
# * with this source code in the file LICENSE.
# */

#/**
# * TangoMan Entrypoint
# *
# * Run CI related tasks
# *
# * @license MIT
# * @author  "Matthias Morin" <mat@tangoman.io>
# * @version 2.2.0-light
# * @link    https://github.com/TangoMan75/glyphicons
# */

## Compile scss
build() {
    if [ ! -x "$(command -v sass)" ]; then
        echo_error "\"$0\" requires sass, try: \"./entrypoint.sh install\""
    fi
    echo_info 'sass ./scss/glyphicons.scss ./css/glyphicons.css'
    sass ./scss/glyphicons.scss ./css/glyphicons.css
}

## Install git hooks
hooks() {
    if [ ! -d .githooks ]; then
        echo_error "\"$0\" requires \".githooks\" folder"
        exit 1
    fi

    echo_info 'rm -fr .git/hooks'
    rm -fr .git/hooks

    echo_info 'cp -r .githooks .git/hooks'
    cp -r .githooks .git/hooks

    echo_info 'chmod +x .git/hooks/*'
    chmod +x .git/hooks/*
}

## Install standalone Sass binary globally
install() {
    if [ -x "$(command -v yarn)" ]; then
        printf "${INFO}sudo yarn global add sass${NL}";
        sudo yarn global add sass;
    elif [ -x "$(command -v npm)" ]; then
        printf "${INFO}sudo npm install -g sass${NL}";
        sudo npm install -g sass;
    else
        printf "${DANGER}error: yarn and npm missing, skipping...${NL}";
    fi;
}

## Watch scss folder
watch() {
    if [ ! -x "$(command -v sass)" ]; then
        echo_error "\"$0\" requires sass, try: \"./entrypoint.sh install\""
    fi
    echo_info 'sass --watch ./scss:./css'
    sass --watch ./scss:./css
}

#--------------------------------------------------
# copy/paste here TangoMan helper functions
# (like a nice set of semantic colors)
#--------------------------------------------------

echo_info()  { printf "\033[95m%s\033[0m\n"    "${*}"; }
echo_error() { printf "\033[1;31merror:\t\033[0;91m%s\033[0m\n" "${*}"; }

#--------------------------------------------------
# You do not need to worry about anything that's
# placed after this line. ;-)
#--------------------------------------------------

## Print this help (default)
help() {
    _padding=6
    _print_title       "$(_get_docbloc_title)"
    _print_infos       "${_padding}"
    _print_description "$(_get_docbloc_description)"
    _print_usage
    _print_commands    "${_padding}"
}

_print_infos() {
    _padding="$1"
    printf '\033[33mInfos:\033[0m\n'
    printf "\033[32m  %-$((_padding+2))s \033[0m%s\n" 'author'  "$(_get_docbloc 'author')"
    printf "\033[32m  %-$((_padding+2))s \033[0m%s\n" 'license' "$(_get_docbloc 'license')"
    printf "\033[32m  %-$((_padding+2))s \033[0m%s\n" 'version' "$(_get_docbloc 'version')"
    printf "\033[32m  %-$((_padding+2))s \033[0m%s\n" 'link'    "$(_get_docbloc 'link')"
    printf '\n'
}

_print_title() {
    printf "\033[0m\n\033[1;104;97m%64s\033[0m\n\033[1;104;97m %-63s\033[0m\n\033[1;104;97m%64s\033[0m\n\n" '' "$1" '';
}

_print_description() {
    printf '\033[33mDescription:\033[0m\n'
    printf '\033[97m  %s\033[0m\n\n' "$1"
}

_print_usage() {
    printf '\033[33mUsage:\033[0m\n'
    printf '\033[95m  sh %s \033[95m[\033[32mcommand\033[95m]\033[0m\n\n' "$(basename "$0")"
}

_print_commands() {
    printf '\033[33mCommands:\033[0m\n'
    awk -v PADDING="$1" '/^(function )? *[a-zA-Z0-9_]+ *\(\) *\{/ {
        sub("^function ",""); gsub("[ ()]","");
        FUNCTION = substr($0, 1, index($0, "{"));
        sub("{$", "", FUNCTION);
        if (substr(PREV, 1, 3) == "## " && substr($0, 1, 1) != "_")
        printf "\033[32m  %-*s \033[0m%s\n", PADDING+2, FUNCTION, substr(PREV, 4)
    } { PREV = $0 }' "$0"
    printf '\n'
}

_get_docbloc_title() {
    awk '/^#\/\*\*$/,/^# \*\/$/{i+=1; if (i==2) print substr($0, 5)}' "$0"
}

_get_docbloc_description() {
    awk '/^# \* @/ {i=2} /^#\/\*\*$/,/^# \*\/$/{i+=1; if (i>3) printf "%s ", substr($0, 5)}' "$0"
}

_get_docbloc() {
    awk -v TAG="$1" '/^#\/\*\*$/,/^# \*\/$/{if($3=="@"TAG){for(i=4;i<=NF;++i){printf "%s ",$i}}}' "$0"
}

_get_functions() {
    awk '/^(function )? *[a-zA-Z0-9_]+ *\(\) *\{/ {
        sub("^function ",""); gsub("[ ()]","");   # remove leading "function ", round brackets and extra spaces
        FUNCTION = substr($0, 1, index($0, "{")); # truncate string after opening curly brace
        sub("{$", "", FUNCTION);                  # remove trailing curly brace
        if (substr(PREV, 1, 3) == "## " && substr($0, 1, 1) != "_") print FUNCTION
    } { PREV = $0 }' "$0"
}

_main() {
    if [ $# -lt 1 ]; then
        help
        exit 0
    fi

    _execute=''
    for _argument in "$@"; do
        _is_valid=false
        for _function in $(_get_functions); do
            # get shorthand character
            _shorthand="$(echo "${_function}" | awk '{$0=substr($0, 1, 1); print}')"
            if [ "${_argument}" = "${_function}" ] || [ "${_argument}" = "${_shorthand}" ]; then
                # append argument to the execute stack
                _execute="${_execute} ${_function}"
                _is_valid=true
                break
            fi
        done
        if [ "${_is_valid}" = false ]; then
            printf '\033[1;31merror:\t\033[0;91m"%s" is not a valid command\033[0m\n' "${_argument}"
            help
            exit 1
        fi
    done

    for _function in ${_execute}; do
        eval "${_function}"
    done
}

_main "$@"

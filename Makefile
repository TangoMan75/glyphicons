#/**
# * TangoMan Glyphicons
# *
# * TangoMan Glyphicons is a copy of Bootstrap 3.4.1 Glyphicons Halfling
# *
# * @version  0.1.0
# * @author   "Matthias Morin" <mat@tangoman.io>
# * @license  Apache
# * @link     https://github.com/TangoMan75/glyphicons
# * @link     https://www.linkedin.com/in/morinmatthias
# */

.PHONY: help sass watch install 

#--------------------------------------------------
# Colors
#--------------------------------------------------

TITLE     = \033[33m
PRIMARY   = \033[97m
SECONDARY = \033[96m
SUCCESS   = \033[92m
DANGER    = \033[31m
WARNING   = \033[93m
INFO      = \033[95m
LIGHT     = \033[47;90m
DARK      = \033[40;37m
MUTED     = \033[37m
PROMPT    = \033[96m
LABEL     = \033[32m
ERROR     = \033[1;31
DEFAULT   = \033[0m
NL        = \033[0m\n

#--------------------------------------------------
# Help
#--------------------------------------------------

## Print this help
help:
	@printf "${LIGHT} TangoMan Glyphicons ${NL}\n"

	@printf "${TITLE}Infos:${NL}"
	@printf "${LABEL}  %-9s${INFO} %s${NL}" "login"  "$(shell whoami)"
	@printf "${LABEL}  %-9s${INFO} %s${NL}" "system" "$(shell uname -s)"
	@printf "${NL}"

	@printf "${TITLE}Description:${NL}"
	@printf "${PRIMARY}  TangoMan Glyphicons is a copy of Bootstrap 3.4.1 Glyphicons${NL}\n"

	@printf "${TITLE}Usage:${NL}"
	@printf "${PRIMARY}  make [command] `awk -F '?' '/^[ \t]+?[a-zA-Z0-9_-]+[ \t]+?\?=/{gsub(/[ \t]+/,"");printf"%s=[%s]\n",$$1,$$1}' ${MAKEFILE_LIST}|sort|uniq|tr '\n' ' '`${NL}\n"

	@printf "${TITLE}Commands:${NL}"
	@awk '/^### /{printf"\n${TITLE}%s${NL}",substr($$0,5)} \
	/^[a-zA-Z0-9_-]+:/{HELP="";if(match(PREV,/^## /))HELP=substr(PREV, 4); \
		printf "  ${LABEL}%-9s${DEFAULT} ${PRIMARY}%s${NL}",substr($$1,0,index($$1,":")),HELP \
	}{PREV=$$0}' ${MAKEFILE_LIST}

##################################################
### Sass
##################################################

## Compile scss
sass:
	@printf "${INFO}sass ./scss/glyphicons.scss ./css/glyphicons.css${NL}"
	@sass ./scss/glyphicons.scss ./css/glyphicons.css

## Watch scss folder
watch:
	@printf "${INFO}sass --watch ./scss:./css${NL}"
	@sass --watch ./scss:./css

##################################################
### Sass
##################################################

## Install standalone Sass globally
install:
	@if [ -x "$(command -v yarn)" ]; then \
		printf "${INFO}sudo yarn global add sass${NL}"; \
		sudo yarn global add sass; \
	elif [ -x "$(command -v npm)" ]; then \
		printf "${INFO}sudo npm install -g sass${NL}"; \
		sudo npm install -g sass; \
	else \
		printf "${DANGER}error: yarn and npm missing, skipping...${NL}"; \
	fi;


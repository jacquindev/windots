#!/bin/bash

# Helper functions for bash completion on Git Bash for Windows
# This file contains required functions for bash completions to work on Windows
#
# Original source:
# - https://github.com/GArik/bash-completion/blob/master/bash_completion
#
#
#   bash_completion - programmable completion functions for bash 4.1+
#
#   Copyright © 2006-2008, Ian Macdonald <ian@caliban.org>
#             © 2009-2014, Bash Completion Maintainers
#                     <bash-completion-devel@lists.alioth.debian.org>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2, or (at your option)
#   any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software Foundation,
#   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# Assign variables one scope above the caller
# Usage: local varname [varname ...] &&
#        _upvars [-v varname value] | [-aN varname [value ...]] ...
# Available OPTIONS:
#     -aN  Assign next N values to varname as array
#     -v   Assign single value to varname
# Return: 1 if error occurs
# See: http://fvue.nl/wiki/Bash:_Passing_variables_by_reference
_upvars() {
	if ! (($#)); then
		echo "${FUNCNAME[0]}: usage: ${FUNCNAME[0]} [-v varname" "value] | [-aN varname [value ...]] ..." 1>&2
		return 2
	fi
	while (($#)); do
		case $1 in
		-a*)
			# Error checking
			[[ ${1#-a} ]] || {
				echo "bash: ${FUNCNAME[0]}: \`$1': missing" "number specifier" 1>&2
				return 1
			}
			printf %d "${1#-a}" &>/dev/null || {
				echo "bash:" "${FUNCNAME[0]}: \`$1': invalid number specifier" 1>&2
				return 1
			}
			# Assign array of -aN elements
			[[ "$2" ]] && unset -v "$2" && eval "$2"=\(\"\${@:3:"${1#-a}"}\"\) &&
				shift $((${1#-a} + 2)) || {
				echo "bash: ${FUNCNAME[0]}:" "\`$1${2+ }$2': missing argument(s)" 1>&2
				return 1
			}
			;;
		-v)
			# Assign single value
			[[ "$2" ]] && unset -v "$2" && eval "$2"=\"\$3\" &&
				shift 3 || {
				echo "bash: ${FUNCNAME[0]}: $1: missing" "argument(s)" 1>&2
				return 1
			}
			;;
		*)
			echo "bash: ${FUNCNAME[0]}: $1: invalid option" 1>&2
			return 1
			;;
		esac
	done
}

# Perform tilde (~) completion
# @return  True (0) if completion needs further processing,
#          False (> 0) if tilde is followed by a valid username, completions
#          are put in COMPREPLY and no further processing is necessary.
_tilde() {
	local result=0
	if [[ $1 == \~* && $1 != */* ]]; then
		# Try generate ~username completions
		COMPREPLY=($(compgen -P '~' -u "${1#\~}"))
		result=${#COMPREPLY[@]}
		# 2>/dev/null for direct invocation, e.g. in the _tilde unit test
		[[ $result -gt 0 ]] && compopt -o filenames 2>/dev/null
	fi
	return "$result"
}

# Reassemble command line words, excluding specified characters from the
# list of word completion separators (COMP_WORDBREAKS).
# @param $1 chars  Characters out of $COMP_WORDBREAKS which should
#     NOT be considered word breaks. This is useful for things like scp where
#     we want to return host:path and not only path, so we would pass the
#     colon (:) as $1 here.
# @param $2 words  Name of variable to return words to
# @param $3 cword  Name of variable to return cword to
#
__reassemble_comp_words_by_ref() {
	local exclude i j line ref
	# Exclude word separator characters?
	if [[ $1 ]]; then
		# Yes, exclude word separator characters;
		# Exclude only those characters, which were really included
		exclude="${1//[^$COMP_WORDBREAKS]/}"
	fi

	# Default to cword unchanged
	printf -v "$3" %s "$COMP_CWORD"
	# Are characters excluded which were former included?
	if [[ $exclude ]]; then
		# Yes, list of word completion separators has shrunk;
		line=$COMP_LINE
		# Re-assemble words to complete
		for ((i = 0, j = 0; i < ${#COMP_WORDS[@]}; i++, j++)); do
			# Is current word not word 0 (the command itself) and is word not
			# empty and is word made up of just word separator characters to
			# be excluded and is current word not preceded by whitespace in
			# original line?
			while [[ $i -gt 0 && ${COMP_WORDS[$i]} == +([$exclude]) ]]; do
				# Is word separator not preceded by whitespace in original line
				# and are we not going to append to word 0 (the command
				# itself), then append to current word.
				[[ $line != [$' \t']* ]] && ((j >= 2)) && ((j--))
				# Append word separator to current or new word
				ref="$2[$j]"
				printf -v "$ref" %s "${!ref}${COMP_WORDS[i]}"
				# Indicate new cword
				[[ $i == $COMP_CWORD ]] && printf -v "$3" %s "$j"
				# Remove optional whitespace + word separator from line copy
				line=${line#*"${COMP_WORDS[$i]}"}
				# Start new word if word separator in original line is
				# followed by whitespace.
				[[ $line == [$' \t']* ]] && ((j++))
				# Indicate next word if available, else end *both* while and
				# for loop
				(($i < ${#COMP_WORDS[@]} - 1)) && ((i++)) || break 2
			done
			# Append word to current word
			ref="$2[$j]"
			printf -v "$ref" %s "${!ref}${COMP_WORDS[i]}"
			# Remove optional whitespace + word from line copy
			line=${line#*"${COMP_WORDS[i]}"}
			# Indicate new cword
			[[ $i == $COMP_CWORD ]] && printf -v "$3" %s "$j"
		done
		[[ $i == $COMP_CWORD ]] && printf -v "$3" %s "$j"
	else
		# No, list of word completions separators hasn't changed;
		for i in ${!COMP_WORDS[@]}; do
			printf -v "$2[i]" %s "${COMP_WORDS[i]}"
		done
	fi
} # __reassemble_comp_words_by_ref()

# @param $1 exclude  Characters out of $COMP_WORDBREAKS which should NOT be
#     considered word breaks. This is useful for things like scp where
#     we want to return host:path and not only path, so we would pass the
#     colon (:) as $1 in this case.
# @param $2 words  Name of variable to return words to
# @param $3 cword  Name of variable to return cword to
# @param $4 cur  Name of variable to return current word to complete to
# @see __reassemble_comp_words_by_ref()
__get_cword_at_cursor_by_ref() {
	local cword words=()
	__reassemble_comp_words_by_ref "$1" words cword

	local i cur index=$COMP_POINT lead=${COMP_LINE:0:$COMP_POINT}
	# Cursor not at position 0 and not leaded by just space(s)?
	if [[ $index -gt 0 && ($lead && ${lead//[[:space:]]/}) ]]; then
		cur=$COMP_LINE
		for ((i = 0; i <= cword; ++i)); do
			while [[ 

				${#cur} -ge ${#words[i]} &&

				"${cur:0:${#words[i]}}" != "${words[i]}" ]] \
				; do # Current word fits in $cur?
				# $cur doesn't match cword?
				# Strip first character
				cur="${cur:1}"
				# Decrease cursor position
				((index--))
			done

			# Does found word match cword?
			if [[ $i -lt $cword ]]; then
				# No, cword lies further;
				local old_size=${#cur}
				cur="${cur#"${words[i]}"}"
				local new_size=${#cur}
				index=$((index - old_size + new_size))
			fi
		done
		# Clear $cur if just space(s)
		[[ $cur && ! ${cur//[[:space:]]/} ]] && cur=
		# Zero $index if negative
		[[ $index -lt 0 ]] && index=0
	fi

	local "$2" "$3" "$4" && _upvars -a${#words[@]} "$2" "${words[@]}" \
		-v "$3" "$cword" -v "$4" "${cur:0:$index}"
}

# If the word-to-complete contains a colon (:), left-trim COMPREPLY items with
# word-to-complete.
# With a colon in COMP_WORDBREAKS, words containing
# colons are always completed as entire words if the word to complete contains
# a colon.  This function fixes this, by removing the colon-containing-prefix
# from COMPREPLY items.
# The preferred solution is to remove the colon (:) from COMP_WORDBREAKS in
# your .bashrc:
#
#    # Remove colon (:) from list of word completion separators
#    COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
#
# See also: Bash FAQ - E13) Why does filename completion misbehave if a colon
# appears in the filename? - http://tiswww.case.edu/php/chet/bash/FAQ
# @param $1 current word to complete (cur)
# @modifies global array $COMPREPLY
#
__ltrim_colon_completions() {
	if [[ "$1" == *:* && "$COMP_WORDBREAKS" == *:* ]]; then
		# Remove colon-word prefix from COMPREPLY items
		local colon_word=${1%"${1##*:}"}
		local i=${#COMPREPLY[*]}
		while [[ $((--i)) -ge 0 ]]; do
			COMPREPLY[$i]=${COMPREPLY[$i]#"$colon_word"}
		done
	fi
} # __ltrim_colon_completions()

# This function quotes the argument in a way so that readline dequoting
# results in the original argument.  This is necessary for at least
# `compgen' which requires its arguments quoted/escaped:
#
#     $ ls "a'b/"
#     c
#     $ compgen -f "a'b/"       # Wrong, doesn't return output
#     $ compgen -f "a\'b/"      # Good
#     a\'b/c
#
# See also:
# - http://lists.gnu.org/archive/html/bug-bash/2009-03/msg00155.html
# - http://www.mail-archive.com/bash-completion-devel@lists.alioth.\
#   debian.org/msg01944.html
# @param $1  Argument to quote
# @param $2  Name of variable to return result to
_quote_readline_by_ref() {
	if [[ $1 == \'* ]]; then
		# Leave out first character
		printf -v "$2" %s "${1:1}"
	else
		printf -v "$2" %q "$1"
	fi

	# If result becomes quoted like this: $'string', re-evaluate in order to
	# drop the additional quoting.  See also: http://www.mail-archive.com/
	# bash-completion-devel@lists.alioth.debian.org/msg01942.html
	[[ ${!2} == \$* ]] && eval "$2"="${!2}"
} # _quote_readline_by_ref()

# This function performs file and directory completion. It's better than
# simply using 'compgen -f', because it honours spaces in filenames.
# @param $1  If `-d', complete only on directories.  Otherwise filter/pick only
#            completions with `.$1' and the uppercase version of it as file
#            extension.
#
_filedir() {
	local i IFS=$'\n' xspec

	_tilde "$cur" || return 0

	local -a toks
	local quoted x tmp

	_quote_readline_by_ref "$cur" quoted
	x=$(compgen -d -- "$quoted") &&
		while read -r tmp; do
			toks+=("$tmp")
		done <<<"$x"

	if [[ "$1" != -d ]]; then
		# Munge xspec to contain uppercase version too
		# http://thread.gmane.org/gmane.comp.shells.bash.bugs/15294/focus=15306
		xspec=${1:+"!*.@($1|${1^^})"}
		x=$(compgen -f -X "$xspec" -- "$quoted") &&
			while read -r tmp; do
				toks+=("$tmp")
			done <<<"$x"
	fi

	# If the filter failed to produce anything, try without it if configured to
	[[ -n ${COMP_FILEDIR_FALLBACK:-} &&
		-n "$1" && "$1" != -d && ${#toks[@]} -lt 1 ]] &&
		x=$(compgen -f -- "$quoted") &&
		while read -r tmp; do
			toks+=("$tmp")
		done <<<"$x"

	if [[ ${#toks[@]} -ne 0 ]]; then
		# 2>/dev/null for direct invocation, e.g. in the _filedir unit test
		compopt -o filenames 2>/dev/null
		COMPREPLY+=("${toks[@]}")
	fi
} # _filedir()

# This function splits $cur=--foo=bar into $prev=--foo, $cur=bar, making it
# easier to support both "--foo bar" and "--foo=bar" style completions.
# `=' should have been removed from COMP_WORDBREAKS when setting $cur for
# this to be useful.
# Returns 0 if current option was split, 1 otherwise.
#
_split_longopt() {
	if [[ "$cur" == --?*=* ]]; then
		# Cut also backslash before '=' in case it ended up there
		# for some reason.
		prev="${cur%%?(\\)=*}"
		cur="${cur#*=}"
		return 0
	fi

	return 1
}

# Complete variables.
# @return  True (0) if variables were completed,
#          False (> 0) if not.
_variables() {
	if [[ $cur =~ ^(\$\{?)([A-Za-z0-9_]*)$ ]]; then
		[[ $cur == *{* ]] && local suffix=} || local suffix=
		COMPREPLY+=($(compgen -P "${BASH_REMATCH[1]}" -S "$suffix" -v -- "${BASH_REMATCH[2]}"))
		return 0
	else
		case $prev in
		TZ)
			cur=/usr/share/zoneinfo/$cur
			_filedir
			for i in ${!COMPREPLY[@]}; do
				if [[ ${COMPREPLY[i]} == *.tab ]]; then
					unset 'COMPREPLY[i]'
					continue
				elif [[ -d ${COMPREPLY[i]} ]]; then
					COMPREPLY[i]+=/
					compopt -o nospace
				fi
				COMPREPLY[i]=${COMPREPLY[i]#/usr/share/zoneinfo/}
			done
			return 0
			;;
		esac
	fi
	return 1
}

# Initialize completion and deal with various general things: do file
# and variable completion where appropriate, and adjust prev, words,
# and cword as if no redirections exist so that completions do not
# need to deal with them.  Before calling this function, make sure
# cur, prev, words, and cword are local, ditto split if you use -s.
#
# Options:
#     -n EXCLUDE  Passed to _get_comp_words_by_ref -n with redirection chars
#     -e XSPEC    Passed to _filedir as first arg for stderr redirections
#     -o XSPEC    Passed to _filedir as first arg for other output redirections
#     -i XSPEC    Passed to _filedir as first arg for stdin redirections
#     -s          Split long options with _split_longopt, implies -n =
# @return  True (0) if completion needs further processing,
#          False (> 0) no further processing is necessary.
#
_init_completion() {
	local exclude= flag outx errx inx OPTIND=1

	while getopts "n:e:o:i:s" flag "$@"; do
		case $flag in
		n) exclude+=$OPTARG ;;
		e) errx=$OPTARG ;;
		o) outx=$OPTARG ;;
		i) inx=$OPTARG ;;
		s)
			split=false
			exclude+==
			;;
		*) ;;
		esac
	done

	# For some reason completion functions are not invoked at all by
	# bash (at least as of 4.1.7) after the command line contains an
	# ampersand so we don't get a chance to deal with redirections
	# containing them, but if we did, hopefully the below would also
	# do the right thing with them...

	COMPREPLY=()
	local redir="@(?([0-9])<|?([0-9&])>?(>)|>&)"
	_get_comp_words_by_ref -n "$exclude<>&" cur prev words cword

	# Complete variable names.
	_variables && return 1

	# Complete on files if current is a redirect possibly followed by a
	# filename, e.g. ">foo", or previous is a "bare" redirect, e.g. ">".
	if [[ $cur == $redir* || $prev == $redir ]]; then
		local xspec
		case $cur in
		2'>'*) xspec=$errx ;;
		*'>'*) xspec=$outx ;;
		*'<'*) xspec=$inx ;;
		*)
			case $prev in
			2'>'*) xspec=$errx ;;
			*'>'*) xspec=$outx ;;
			*'<'*) xspec=$inx ;;
			esac
			;;
		esac
		cur="${cur##"$redir"}"
		_filedir "$xspec"
		return 1
	fi

	# Remove all redirections so completions don't have to deal with them.
	local i skip
	for ((i = 1; i < ${#words[@]}; )); do
		if [[ ${words[i]} == $redir* ]]; then
			# If "bare" redirect, remove also the next word (skip=2).
			[[ ${words[i]} == $redir ]] && skip=2 || skip=1
			words=("${words[@]:0:i}" "${words[@]:i+skip}")
			[[ $i -le $cword ]] && cword=$((cword - skip))
		else
			i=$((++i))
		fi
	done

	[[ $cword -eq 0 ]] && return 1
	prev=${words[cword - 1]}

	[[ ${split-} ]] && _split_longopt && split=true

	return 0
}

#!/bin/bash
# emoji - Command line tool for generating Unicode compatible emojis.
# Copyright © 2019 Daniel Ciumberică
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

datadir='../resources/'
datafile=${datadir}'unicode/emoji/emoji-data.txt'
names=${datadir}'basic-emoji-name.txt'
varseq=${datadir}'unicode/emoji/emoji-variation-sequences.txt'
zwjseq=${datadir}'unicode/emoji/emoji-zwj-sequences.txt'
ssq=${datadir}'unicode/emoji/emoji-sequences.txt'

expr=$(echo $1 | sed 's/+/ + /g' | sed 's/:/ : /g')

# Checks if the Unicode codepoint argument is a default emoji presentation
is_emoji_pres () {
	data=$(grep -v "^#" $datafile | grep Emoji_Presentation | cut -d";" -f1)
	found="no"
	for d in $data; do
		if [[ $d == *..* ]]; then
			fval=$(echo $d | cut -d"." -f1)
			lval=$(echo $d | cut -d"." -f3)
			[[ $(( "0x$1" )) -lt $(( "0x$fval" )) ]] && break
			[[ $(( "0x$1" )) -ge $(( "0x$fval" )) && $(( "0x$1" )) -le $(( "0x$lval" )) ]] && { found="yes"; break; }
		elif
			[[ $(( "0x"$1 )) -lt $(( "0x"$d )) ]]; then
				break
			else
				[[ $d == $1 ]] && { found="yes"; break; }
		fi
	done
	case $found in
		"yes") return 0;;
		"no") return 1;;
	esac
}

# Checks if codepoint has text variant
has_text_var () {
	grep -w "^$1" $varseq >/dev/null
}

# Returns the Unicode codepoint of an emoji name
lookup () {
	suf="no"
	if [[ ${1: -1} == "$" ]]; then
		val=${1: : -1}
		suf="yes"
	else
		val=$1
	fi
	sol=$(grep "\s$val$" $names | cut -f1)
	[ -z $sol ] && { echo Name $1 is not a known emoji >&2
			 return 100; }
	if has_text_var $sol; then
		if [[ $suf == yes ]]; then
			echo "${sol} FE0E"
		elif
			is_emoji_pres $sol; then
			echo $sol
		else
			echo "${sol} FE0F"
		fi
	else
		echo "${sol}"
	fi
}

# Parsing the argument
res=""
zwj="no"
joined="no"
for chr in $expr; do
	case $chr in
		":") joined="yes";;
		"+") res+=" 200D "
		     zwj="yes";;
		*) res+="$(lookup $chr) " || exit $?;;
	esac
done

# Hack to remove the trailing whitespaces
res=$(echo $res)

# Test the result for known emoji sequences
if [[ $zwj == "yes" ]]; then
	grep "^$res" $zwjseq >/dev/null ||\
	# Fallback to check if emoji is valid without the emoji presentation char (0xFE0F)
	( grep "^${res/ FE0F/}" $zwjseq >/dev/null && res=${res/ FE0F/} ) ||\
	{ echo Emoji is not a valid zwj sequence >&2; exit 20; }
elif [[ $joined == "yes" ]]; then
	grep "^$res" $ssq >/dev/null ||\
	# Fallback to check if emoji is valid without the emoji presentation char (0xFE0F)
	( grep "^${res/ FE0F/}" $ssq >/dev/null && res=${res/ FE0F/} ) ||\
        { echo Emoji is not a valid sequence >&2; exit 30; }
elif [[ $(echo $res | wc -w) == "2" ]]; then
	grep "^$res" $varseq >/dev/null || { echo Emoji is not a valid text/emoji style sequence >&2; exit 10; }
fi

out=""
for el in $res; do
	out+="\U$el"
done

printf "${out}"
echo

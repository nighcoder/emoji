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
cldrfile=${datadir}'unicode/cldr/common/annotations/en.xml'
cldrseqfile=${datadir}'unicode/cldr/common/annotationsDerived/en.xml'

version="0.0.1"
newline="yes"

# Checks if the Unicode codepoint argument is a default emoji presentation
is_emoji_pres () {
	[[ $1 =~ " " ]] && return 10
	local fval lval
	local data
	data=$(grep -v "^#" $datafile | grep Emoji_Presentation | cut -d";" -f1)
	local found="no"
	for d in $data; do
		if [[ "$d" == *..* ]]; then
			fval=$(echo "$d" | cut -d"." -f1)
			lval=$(echo "$d" | cut -d"." -f3)
			[[ $(( "0x$1" )) -lt $(( "0x$fval" )) ]] && break
			[[ $(( "0x$1" )) -ge $(( "0x$fval" )) && $(( "0x$1" )) -le $(( "0x$lval" )) ]] && { found="yes"; break; }
		elif
			[[ $(( "0x$1" )) -lt $(( "0x$d" )) ]]; then
				break
			else
				[[ "$d" == "$1" ]] && { found="yes"; break; }
		fi
	done
	case "$found" in
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
	local suf="no" val sol
	if [[ ${1: -1} == "$" ]]; then
		val=${1: : -1}
		suf="yes"
	else
		val=$1
	fi
	sol=$(grep "\s$val$" $names | cut -f1)
	[ -z "$sol" ] && { echo "Name $1 is not a known emoji" >&2
			 return 100; }
	if has_text_var "$sol"; then
		if [[ "$suf" == yes ]]; then
			echo "${sol} FE0E"
		elif
			is_emoji_pres "$sol"; then
			echo "$sol"
		else
			echo "${sol} FE0F"
		fi
	else
		echo "${sol}"
	fi
}
# Returns the emoji character for a given Unicode codepoints list
emojify () {
	local out=""
	for el in $1; do
		out+="\U$el"
	done
	
	printf "${out}"
}

# Returns one or more Unicode codepoints for given emoji
U_codepoints () {
	local v res
	while read -N1 c; do
		v=$(printf "%X " \'$c)
       		[[ "$v" != "0 " ]] && res+="$v"
	done <<< "$1"
	echo "$res"
}

helper () {
	echo "Usage: emoji [-n] EXPRESSION
       emoji [-h|--help|-v|--version]
       emoji -i|--info EMOJI
       emoji -s|--search TERM
       
Expression is on or more basic emoji names mixed with with the special
character +, : or $.

Arguments:
	-h, --help		print this help text
	-v, --version		prints version information and exits
	-i, --info EMOJI	shows information about EMOJI
	-s, --search TERM	searches TERM for relevant emoji
	-n			do not append new line after generated emoji

Exit Status:
	0	Everything OK.
	20	Expression contains valid emoji names, but the sequence is not
	  	a valid ZWJ sequence.
	30	Expression contains valid emoji names, but the sequence is not
	  	valid.
	50	An optional flag that requires aditional arguments was set, but
		the argument is missing.
	100	One or more emoji in expression is unknown.
	110	The emoji (or part of) passed with -i option is unknown.
	  "
}

# Returns the expression of a Unicode codepoint list
get_name () {
	local res name
	for code in $1; do
		case "$code" in
			200D) res+="+";;
			FE0E) res+="$";;
			FE0F) continue;;
			*)    name=$(grep -w "^$code" $names | cut -f2)
			      [[ -z "$name" ]] && { echo "Unknown emoji with Unicode: $code" >&2;
			      			  return 110; }
      			      [[ -n $res ]] && [[ ${res: -1} != "+" ]] && res+=":" 
			      res+="$name";;
		esac
	done
	echo "$res"
}

# Parsing the arguments
if [[ ${1:0:1} == "-" ]]; then
	# An option was passed
	case $1 in
		"-h"|"--help") helper; exit 0;;
		"-i"|"--info")  [[ -z $2 ]] && { echo Missing emoji argument to -i option >&2;
						 exit 50; }

				cp=$(U_codepoints "$2")
				name=$(get_name "$cp") 
				# cldrdata file does not hold the full emoji reprezentation. We must check
				# for emoji/text flag and only the for the root emoji character
				arg=$(emojify "$(echo $cp | sed 's/ FE0[FE]//g; s/\s\?\([0-9A-F]\+\)/\\U\1/g')")
				cldrdata=$(grep '<annotation .*$' $cldrfile $cldrseqfile | \
					sed -n "s/^.*cp=\"$arg\".*>\(.\+\)<.*$/\1~/p" )
				tags=$(echo $cldrdata | cut -d~ -f1 | sed 's/ | /,/g')
				cldrname=$(echo $cldrdata | cut -d~ -f2 | xargs)

				echo EXPRESSION:" 		$name"
				echo EMOJI:" 			$2"
				echo UNICODE CODEPOINT:"	$cp"
				echo CLDR NAME:"		$cldrname"
				echo TAGS:"			$tags"
				exit 0;;

		"-s"|"--search") [[ -z $2 ]] && { echo Missing search term to -s option >&2;
						  exit 50; }
				 mexpr=$(grep -i "$2" $names | sed 's/^\([0-9A-F]\+\)\t\([-a-z_.]\+\)/\\U\1\t\2\t/')
				 mexpr=$(printf "$mexpr")
				 mcldr=$(grep -hi "$2" $cldrfile $cldrseqfile | sed 's/\s*<annotation cp="\([^[:alnum:]]\+\)"\s\?\(type="tts"\)\?>\(.*\)<\/annotation>/\1\t\2\t\3/')
				 # First we word match the names
				 em1=$(echo "$mcldr" | grep type=\"tts\" | cat <(echo "$mexpr") | grep -i "[-_:[:space:]]$2[-_:[:space:]]" | cut -f1 | sort)
				 # Next we word match the tags
				 em2=$(echo "$mcldr" | grep -v type=\"tts\" | grep -i "[-_:[:space:]]$2[-_:[:space:]]" | cut -f1 | sort | comm -13 <(echo "$em1") -)
				 # Next we partially match the names
				 em3=$(echo "$mcldr" | grep type=\"tts\" | grep -iv "[-_:[:space:]]$2[-_:[:space:]]" | cut -f1 | sort | comm -13 <(echo -e "$em1\n$em2" | sort) -)
				 # Finally we partially match the tags
				 em4=$(echo "$mcldr" | grep -v type=\"tts\" | grep -iv "[-_:[:space:]]$2[-_:[:space:]]" | cut -f1 | sort | comm -13 <(echo -e "$em1\n$em2\n$em3" | sort) -)
				 
				 for el in $em4 $em3 $em2 $em1; do
					 cp=$(U_codepoints "$el")
					 { echo "$mxepr" | grep "^$el" > /dev/null && \
						 name=$(echo "$mexpr" | grep "^$el" | cut -f2); } || \
						 name=$(get_name "$cp" 2> /dev/null)
					 [[ -z "$name" ]] && continue
				         tags=$(echo "$mcldr" | grep -v type=\"tts\" | grep "^$el\s" | cut -f3 | sed 's/ | /,/g') || \
						 tags=$(sed -n "/\"$el\"/ "'s|<annotation cp=".*">\(.*\)</annotation>|\1| p' $cldrfile $cldrseqfile | sed 's/\s*|\s*/,/g')
					 pict=$el
				 	 is_emoji_pres "$cp" || pict=$(emojify "$cp FE0F")
					 echo -e "$pict\t$name\t$tags"
				 done
				 exit 0;;
		"-v"|"--version") echo $version; exit 0;;
		"-n") newline="no"
		      expr=$(echo "$2" | sed 's/+/ + /g' | sed 's/:/ : /g');;
		*) echo Invalid option;;
	esac
else
	expr=$(echo "$1" | sed 's/+/ + /g' | sed 's/:/ : /g')
fi

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
	{ grep "^${res/ FE0F/}" $zwjseq >/dev/null && res=${res/ FE0F/}; } ||\
	{ echo Emoji is not a valid zwj sequence >&2; exit 20; }
elif [[ $joined == "yes" ]]; then
	grep "^$res" $ssq >/dev/null ||\
	# Fallback to check if emoji is valid without the emoji presentation char (0xFE0F)
	{ grep "^${res/ FE0F/}" $ssq >/dev/null && res=${res/ FE0F/}; } ||\
        { echo Emoji is not a valid sequence >&2; exit 30; }
elif [[ $(echo $res | wc -w) == "2" ]]; then
	grep "^$res" $varseq >/dev/null || { echo Emoji is not a valid text/emoji style sequence >&2; exit 10; }
fi

emojify "$res"
[[ $newline == "yes" ]] && echo
exit 0

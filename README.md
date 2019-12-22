# emoji
Command line tool to generate Unicode compatible emojis.

### Installation
To install the program in the user directory run make install.

To install it system wide, run sudo make install.

### Usage
There are several optional switches that change the program output.

If no switch is present, the program expects an argument representing expression and returns the Unicode emoji character.

    $ emoji [-n] EXPRESSION

An expression is one or more emoji name, that identify a basic emoji, separated by the reserved characters + or :.
+ \+ will substitute to the ligature character U+200D to create a ZWJ sequence.
+ : will not substitute to any character, it is used to separate emoji names in a direct sequence.
+ $ can be add to the end of a emoji and it will force the text representation of the emoji, if the emoji has one.

An _-i_ switch will make the program return the information about the passed emoji.

An _-s_ switch will search the CLDR name and tags database for relevant emojis.

##### Example
Basic emojis can be called directly by their names:

```bash
$ emoji eyes
👀
$ emoji camping
🏕️
$ emoji camping$
🏕︎
```                            

Some emojis support different skin tones:

```bash
$ emoji horse_racing:skin_2
🏇🏼
```

Note that there's nothing special about neither `horse_racing` nor `skin_2` emojis.
They both are basic emojis that can be called just by their names, although it doesn't make much sense to call the skin emojis directly.

```bash
$ emoji horse_racing
🏇
$ emoji skin_2
🏼
```
For a complete list of possible emoji sequences check out [this list](https://www.unicode.org/Public/emoji/12.0/emoji-sequences.txt).

Complex emojis that require a joiner character are introduced with `+`.
To create the astronaut emoji, we combine two basic emojis with a ZWJ character:
`man+rocket`.
```bash
$ emoji man+rocket
👨‍🚀
$ emoji man:skin_3+rocket
👨🏽‍🚀
$ emoji woman:skin_1+white_hair
👩🏻‍🦳
```
A complete list of ZWJ sequence can be found [here](https://www.unicode.org/Public/emoji/12.0/emoji-zwj-sequences.txt).

### Known Limitations
The program doesn't currently support generating flag code sequences, nor emoji tag sequences.

### Licence
Copyright © 2019 Daniel Ciumberică

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

Project includes data from Unicode Emoji data files.

COPYRIGHT AND PERMISSION NOTICE

Copyright © 1991-2019 Unicode, Inc. All rights reserved.
Distributed under the Terms of Use in https://www.unicode.org/copyright.html.

Permission is hereby granted, free of charge, to any person obtaining
a copy of the Unicode data files and any associated documentation
(the "Data Files") or Unicode software and any associated documentation
(the "Software") to deal in the Data Files or Software
without restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, and/or sell copies of
the Data Files or Software, and to permit persons to whom the Data Files
or Software are furnished to do so, provided that either
(a) this copyright and permission notice appear with all copies
of the Data Files or Software, or
(b) this copyright and permission notice appear in associated
Documentation.

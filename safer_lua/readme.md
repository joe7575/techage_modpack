SaferLua [safer_lua]
====================

A subset of the language Lua for safe and secure Lua sandboxes with:
 - limited code length
 - limited execution time
 - limited memory use
 - limited posibilities to call functions

### License
Copyright (C) 2018-2022 Joachim Stolberg
Code: Licensed under the GNU LGPL version 2.1 or later. See LICENSE.txt  
      Functions safe_string_rep and safe_string_find (from mesecons) LGPL version 3

### Dependencies 
none

### History
- 2018-06-24  v0.01  * first draft
- 2020-03-14  v1.00  * extracted from TechPack and released
- 2021-11-28  v1.01  * function `string.split2` added, `unpack` removed
- 2022-12-22  v1.02  * Limit code execution time for recursive function calls (#3 by Thomas--S)
- 2024-06-19  V1.03  * Add safe variants for strin.rep() and string.find()

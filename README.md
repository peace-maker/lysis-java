lysis-java
==========

Lysis - SourceMod .smx decompiler

This is an improved Java port of BAILOPAN's sourcepawn decompiler [Lysis](https://forums.alliedmods.net/showthread.php?t=170898).
Originally written C#, i wasn't comfortable with debugging with VS and since C# and Java are quite similar..

[Original repository](https://hg.alliedmods.net/users/dvander_alliedmods.net/lysis/)

## Changes in this fork
* Support for new opcodes
  * genarray / genarray_z (dynamic arrays)
    * tracker_pop_setheap
    * tracker_push_c
    * stradjust_pri
  * sysreq_c (operations on 2 float constants)
  * dec (decrement global variables)
  * neg (negating variables)
* Fix load_both opcode
* Support conditional returns (|return cond1 && cond2;|)
* Support storing conditions in a variable (|new var = cond1 || cond2;|)
* Printing of Extension: and SharedPlugin: plugin dependency structs
* Correctly show |new| or |decl| when declaring local variables
* Support plugins compiled with old sourcemod 1.0 compiler (codeversion 0x0101)
* Work around malicious alteration of section names table to still load tampered binaries
* Better handling of multidimensional arrays
* Displaying of float constants as floats in lots of cases
* Support switch-cases with multiple values |case 1, 2, 3:|
* Fix not displaying complex logic chains after calculating them (|if(cond1 && !cond2 || cond3)|)
* Support non public functions to return strings
* Handle global variables in call-by-reference parameters and variadic argument lists
* Replace all float operators with inline syntax
* Fix displaying of string arrays
* Replace \x03 etc. chat color codes with readable string in strings
* Fix displaying global string's size in cells instead of bytes
* Try to fetch some type info out of format specifier strings in methods with variadic arguments
* Fix displaying constant array indices as bytes instead of cells
* Fix bad coalescing of stores with an operation
* Fix error with switches without a default case
* Display variables correctly which are only used once

And probably more..

[Try it in your browser!](http://godtony.mooo.com/lysis/)
Applet by GoD-Tony
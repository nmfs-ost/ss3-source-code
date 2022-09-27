# Draft programming style for SS3
SS3 is coded in C++ and ADMB TPL which have different requirements for compilation.
C++ code is contained in 'LOCAL_CALCS' sections.
The following is to enhance clarity while building using ADMB tools. 

## LOCAL_CALCS Sections
These sections are between the statements 'LOCAL_CALCS' and 'END_CALCS'
each of which must be one space from the left.

If using clang-format, make
sure these comments are at the beginning and ending of the section:
// clang-format on, and
// clang-format off.

Example:

    LOCAL_CALCS
     // clang-format on
     . . .
      // clang-format off
     END_CALCS


### Math Expressions
Use spaces on each side of a mathematical operator (+ - * / =), unless
the expression is used as an index for an array, vector, matrix, etc.

Examples:

    n = (maxread-minread) / binwidth2 + 1;
    bins(z) = bins(z-1) + width;

### Control Statements
Use a space before the left parenthesis and after the right
parenthesis in control statements (e.g. for, do while, while, if, else).
Curly braces should always be used for all code blocks and put on their
own line (so that the closing curly brace is obvious).

Example:

    if (a > b)
    {
      b = 2;
    }
    else
    {
      b = 4;
    }

#### Logic Expressions
Use a space on each side of the logical operators (< > <= >= == !=).
Logical expressions used as indices may contain spaces or not
depending on what makes it most clear.

Examples:

    if (this > that)

    for (f = 1; f <= number; f++)


## TPL Sections
TPL sections deserve special consideration.
While the LOCAL_CALCS section is treated as pure C++ code,
the other sections of .tpl files are templates that are
translated to C++ code before compilation, so there are
additional syntax rules that must be taken into account.

### Indices
Items with multiple indices cannot have spaces between them.
In C++, spaces can be inserted, e.g. matrix1 (1, j, 5) while in
TPL, the same item would be matrix1(1,j,5). For the sake of
consistency, this can be done in the C++ sections also.

Examples:

    vector length(1,nlength);
    ivector parmlist(1,2*number);

### Semi-colons
Use semi-colons to end each statement.
Clang-format will join statements together if they are not separated
by semi-colons.

## Indenting
Use 2 spaces to indent each level of code to make it obvious what
code belongs together.

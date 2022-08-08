# Draft programming style for SS3
Please notice that the term C++ section is used as short-hand for code that is in the LOCAL_CALCS sections of the TPL code.

## Math Expressions
Generally, there is a space on each side of a mathematical operator (+ - * / =).
This may be dispensed with when the expression is used as an index for an array, vector, matrix, etc.

Examples:

    n = (maxread-minread) / binwidth2 + 1;
    bins(z) = bins(z-1) + width;

## Control Statements
There can be a space before the left parenthesis and after the right parenthesis. Brackets should always be used and put on their own line (so that the matching brackets are obvious).

#### Logic Expressions
There is a space on each side of the logical operators (< > <= >= == !=).
Math expressions used as indices may contain spaces or not depending on what makes it most clear.

Examples:  

    if (this > that)
    for (f = 1; f <= number; f++)

## TPL
TPL sections deserve special consideration.

### Indices
Items with multiple indices cannot have spaces between them.  
In C++, spaces can be inserted, e.g. matrix1 (1, j, 5).
In TPL, the same item would be matrix1(1,j,5). For the sake of consistency, this can be done in the C++ sections also.

Examples:

    vector length(1,nlength);
    ivector parmlist(1,2*number);

### Semi-colons
Use semi-colons to end each statement especially if this will be
passed through the "pretty_tpl" routine. Clang-format will join
statements together if they are not separated by semi-colons.

CS - CommanderScript
A programming language for the Web using Computercraft Tweaked

---=SYNTAX=---
At the start of each line there is either a ! symbol or a ? symbol
! - An action
? - A question

when typing arbitrary text the first&last character of said text should be " ' "
when typing arbitrary numbers the first&last character of said number should be " | "

{<TEXT>} is replaced by the value of the variable <TEXT>

---=EXPRESSIONS=---
[plus,<Value1>,<Value2>] -- Returns {Value1} plus {Value2}.
[minus,<Value1>,<Value2>] -- Returns {Value1} minus {Value2}.
[multiply,<Value1>,<Value2>] -- Returns {Value1} multiplied by {Value2}.
[divide,<Value1>,<Value2>] -- Returns {Value1} divided by {Value2}
[modulus,<Value1>,<Value2>] -- Returns Modulus Operator and remainder of after an integer division
[exponent,<Value>,<Value2>] -- Exponent Operator takes the exponents
[more,<Value1>,<Value2>] -- Returns true or false depending on is {Value1} more than {Value2}
[less,<Value1>,<Value2>] -- Returns true or false depending on is {Value1} less than {Value2}
[moreequal,<Value1>,<Value2>]  -- Returns true or false depending on is {Value1} more or equal to {Value2}
[lessequal,<Value1>,<Value2>]  -- Returns true or false depending on is {Value1} less or equal to {Value2}
[equals,<Value1>,<Value2>] -- Returns either true or false representing is {Value1} the the same as {Value2}

---=VARIABLES=---
{Second} -- The current time in seconds
{Minute} -- The current time in minutes
{Hour} -- The current time in hours
{Account} -- The username of the account the website viewer is logged into

---=COMMANDS=---
!print <...: TEXT> -- will print everything after the print command
!set <VARNAME: TEXT> <VALUE: ANY> -- sets the variable {VARNAME} to {VALUE}.
!func <NAME: TEXT> -- creates a function, every line further that starts with "-" is part of the function, if theres a line without "-" then thats the end of the function
!call <NAME: TEXT> -- calls function {NAME}
!sequence -- starts a sequence of code, works similar to functions except it doesnt need a name and is automatically called after it is defined
!wait <TIME: NUMBER> -- waits {TIME} seconds before continuing code execution
---=QUESTIONS=---
?if <VALUE1: ANY> : -- if {VALUE1} is true then it will run code that is after the ":" symbol as a new line














---=nerdy stuff=---
Parsing Order:
    Variables
    Expressions
    Commands/Questions

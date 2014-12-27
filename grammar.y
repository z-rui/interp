%token_prefix {TOK_}
%token_type {const char *}

%include {
#include <assert.h>
}

prgm         ::= sub_list block.

sub_list     ::= .
sub_list     ::= sub_list sub_dcl.

sub_dcl      ::= SUB NUMBER block ENDSUB.

block        ::= .
block        ::= block stmt.

stmt         ::= read_stmt.
stmt         ::= write_stmt.
stmt         ::= if_stmt.
stmt         ::= while_stmt.
stmt         ::= for_stmt.
stmt         ::= assign_stmt.
stmt         ::= call_stmt.

read_stmt    ::= READ var.

write_stmt   ::= WRITE LITERAL.
write_stmt   ::= WRITE expr.

if_stmt      ::= IF condition THEN block ENDIF.
if_stmt      ::= IF condition THEN block ELSE block ENDIF.

while_stmt   ::= WHILE condition DO block ENDWHILE.

for_stmt     ::= FOR var EQ expr TO|DOWNTO expr DO block ENDFOR.
for_stmt     ::= FOR var EQ expr TO|DOWNTO expr STEP expr DO block ENDFOR.

assign_stmt  ::= LET var EQ expr.

call_stmt    ::= CALL NUMBER.

%left PLUS MINUS.
%left MULT DIV MOD.

expr         ::= NUMBER.
expr         ::= var.
expr         ::= LPAR expr RPAR.
expr         ::= expr PLUS|MINUS|MULT|DIV|MOD expr.
expr         ::= MINUS expr.

%left OR.
%left AND.
%right NOT.

condition    ::= compare.
condition    ::= logical.
compare      ::= expr LT|GT|EQ expr.
logical      ::= LPAR condition RPAR.
logical      ::= logical AND|OR logical.
logical      ::= NOT logical.

var          ::= ID.
var          ::= LBRAC expr RBRAC.

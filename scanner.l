%{
#include "interp.h"

#define PARSEDUP(tok) Parse(yyextra->parser, tok, GC_strdup(yytext), yyextra)
#define PARSE(tok) Parse(yyextra->parser, tok, 0, yyextra)
%}

%option noyywrap
%option reentrant
%option extra-type="struct parse_context *"

LITERAL \"[^\"]*\"
NUMBER [0-9]+(\.[0-9]*)?([eE]+[0-9]+)?
COMMENT \{[^}]*\}

%%

{NUMBER}	PARSEDUP(TOK_NUMBER);
{LITERAL}	PARSEDUP(TOK_LITERAL);
SUB		PARSE(TOK_SUB);
ENDSUB		PARSE(TOK_ENDSUB);
READ		PARSE(TOK_READ);
WRITE		PARSE(TOK_WRITE);
IF		PARSE(TOK_IF);
THEN		PARSE(TOK_THEN);
ELSE		PARSE(TOK_ELSE);
ENDIF		PARSE(TOK_ENDIF);
WHILE		PARSE(TOK_WHILE);
DO		PARSE(TOK_DO);
ENDWHILE	PARSE(TOK_ENDWHILE);
FOR		PARSE(TOK_FOR);
TO		PARSE(TOK_TO);
DOWNTO		PARSE(TOK_DOWNTO);
STEP		PARSE(TOK_STEP);
ENDFOR		PARSE(TOK_ENDFOR);
LET		PARSE(TOK_LET);
CALL		PARSE(TOK_CALL);
OR		PARSE(TOK_OR);
AND		PARSE(TOK_AND);
NOT		PARSE(TOK_NOT);
"+"		PARSE(TOK_PLUS);
"-"		PARSE(TOK_MINUS);
"*"		PARSE(TOK_MULT);
"/"		PARSE(TOK_DIV);
"%"		PARSE(TOK_MOD);
"<"		PARSE(TOK_LT);
">"		PARSE(TOK_GT);
"("		PARSE(TOK_LPAR);
")"		PARSE(TOK_RPAR);
"["		PARSE(TOK_LBRAC);
"]"		PARSE(TOK_RBRAC);
"="		PARSE(TOK_EQ);
[A-Z]		PARSEDUP(TOK_ID);
<<EOF>>		PARSE(0); yyterminate();
{COMMENT}	|
[[:space:]]	/* ignore */
. {
	fprintf(stderr, "scanner: unexpected '%s'\n", yytext);
	exit(EXIT_FAILURE);
  }

%%

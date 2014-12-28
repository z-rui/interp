%{
#include "interp.h"

#define PARSE(tok) Parse(yyextra->parser, tok, yytext, yyextra)
%}

%option noyywrap
%option reentrant
%option extra-type="struct parse_context *"

LITERAL \"[^\"]*\"
NUMBER [0-9]+(\.[0-9]*)?([eE]+[0-9]+)?
COMMENT \{[^}]*\}

%%

{NUMBER}	PARSE(TOK_NUMBER);
{LITERAL} {
	char *lit = strncpy(malloc(yyleng-1), yytext+1, yyleng-2);
	Parse(yyextra->parser, TOK_LITERAL, lit, yyextra);
}
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
[A-Z]		PARSE(TOK_ID);
{COMMENT}	|
[[:space:]]	/* ignore */
. {
	fprintf(stderr, "scanner: unexpected '%s'\n", yytext);
	exit(EXIT_FAILURE);
  }

%%

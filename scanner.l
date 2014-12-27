%option noyywrap
%option reentrant
%option extra-type="void *"

%{
#include "grammar.h"
#ifndef NDEBUG
extern void ParseTrace(FILE *, char *);
#endif
extern void *ParseAlloc(void *(*)(size_t));
extern void ParseFree(void *, void (*)(void *));
extern void Parse(void *, int, const char *);

%}

LITERAL \"[^"]*\"
NUMBER [0-9]+(\.[0-9]*)?([eE]+[0-9]+)?
COMMENT \{[^}]*\}

%%

{NUMBER}	Parse(yyextra, TOK_NUMBER, yytext);
{LITERAL}	Parse(yyextra, TOK_LITERAL, yytext);
SUB		Parse(yyextra, TOK_SUB, yytext);
ENDSUB		Parse(yyextra, TOK_ENDSUB, yytext);
READ		Parse(yyextra, TOK_READ, yytext);
WRITE		Parse(yyextra, TOK_WRITE, yytext);
IF		Parse(yyextra, TOK_IF, yytext);
THEN		Parse(yyextra, TOK_THEN, yytext);
ELSE		Parse(yyextra, TOK_ELSE, yytext);
ENDIF		Parse(yyextra, TOK_ENDIF, yytext);
WHILE		Parse(yyextra, TOK_WHILE, yytext);
DO		Parse(yyextra, TOK_DO, yytext);
ENDWHILE	Parse(yyextra, TOK_ENDWHILE, yytext);
FOR		Parse(yyextra, TOK_FOR, yytext);
TO		Parse(yyextra, TOK_TO, yytext);
DOWNTO		Parse(yyextra, TOK_DOWNTO, yytext);
STEP		Parse(yyextra, TOK_STEP, yytext);
ENDFOR		Parse(yyextra, TOK_ENDFOR, yytext);
LET		Parse(yyextra, TOK_LET, yytext);
CALL		Parse(yyextra, TOK_CALL, yytext);
OR		Parse(yyextra, TOK_OR, yytext);
AND		Parse(yyextra, TOK_AND, yytext);
NOT		Parse(yyextra, TOK_NOT, yytext);
"+"		Parse(yyextra, TOK_PLUS, yytext);
"-"		Parse(yyextra, TOK_MINUS, yytext);
"*"		Parse(yyextra, TOK_MULT, yytext);
"/"		Parse(yyextra, TOK_DIV, yytext);
"%"		Parse(yyextra, TOK_MOD, yytext);
"<"		Parse(yyextra, TOK_LT, yytext);
">"		Parse(yyextra, TOK_GT, yytext);
"("		Parse(yyextra, TOK_LPAR, yytext);
")"		Parse(yyextra, TOK_RPAR, yytext);
"["		Parse(yyextra, TOK_LBRAC, yytext);
"]"		Parse(yyextra, TOK_RBRAC, yytext);
"="		Parse(yyextra, TOK_EQ, yytext);
[A-Z]		Parse(yyextra, TOK_ID, yytext);
{COMMENT}	|
[[:space:]]	/* ignore */
. {
	fprintf(stderr, "scanner: unexpected '%s'\n", yytext);
	exit(EXIT_FAILURE);
  }

%%

int main()
{
	yyscan_t scanner;
	void *parser;

	parser = ParseAlloc(malloc);
	ParseTrace(stderr, "parser: ");
	yylex_init_extra(parser, &scanner);
	yylex(scanner);
	yylex_destroy(scanner);
	Parse(parser, 0, 0);
	ParseFree(parser, free);

	return 0;
}

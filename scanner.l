%option noyywrap

%{
#include "grammar.h"
#ifndef NDEBUG
extern void ParseTrace(FILE *, char *);
#endif
extern void *ParseAlloc(void *(*)(size_t));
extern void ParseFree(void *, void (*)(void *));
extern void Parse(void *, int, const char *);

#define PARSER interp_global_parser
static void *PARSER;
%}

LITERAL \"[^"]*\"
NUMBER [0-9]+(\.[0-9]*)?([eE]+[0-9]+)?
COMMENT \{[^}]*\}

%%

{NUMBER}	Parse(PARSER, TOK_NUMBER, yytext);
{LITERAL}	Parse(PARSER, TOK_LITERAL, yytext);
SUB		Parse(PARSER, TOK_SUB, yytext);
ENDSUB		Parse(PARSER, TOK_ENDSUB, yytext);
READ		Parse(PARSER, TOK_READ, yytext);
WRITE		Parse(PARSER, TOK_WRITE, yytext);
IF		Parse(PARSER, TOK_IF, yytext);
THEN		Parse(PARSER, TOK_THEN, yytext);
ELSE		Parse(PARSER, TOK_ELSE, yytext);
ENDIF		Parse(PARSER, TOK_ENDIF, yytext);
WHILE		Parse(PARSER, TOK_WHILE, yytext);
DO		Parse(PARSER, TOK_DO, yytext);
ENDWHILE	Parse(PARSER, TOK_ENDWHILE, yytext);
FOR		Parse(PARSER, TOK_FOR, yytext);
TO		Parse(PARSER, TOK_TO, yytext);
DOWNTO		Parse(PARSER, TOK_DOWNTO, yytext);
STEP		Parse(PARSER, TOK_STEP, yytext);
ENDFOR		Parse(PARSER, TOK_ENDFOR, yytext);
LET		Parse(PARSER, TOK_LET, yytext);
CALL 		Parse(PARSER, TOK_CALL, yytext);
OR		Parse(PARSER, TOK_OR, yytext);
AND		Parse(PARSER, TOK_AND, yytext);
NOT		Parse(PARSER, TOK_NOT, yytext);
"+" 		Parse(PARSER, TOK_PLUS, yytext);
"-" 		Parse(PARSER, TOK_MINUS, yytext);
"*" 		Parse(PARSER, TOK_MULT, yytext);
"/" 		Parse(PARSER, TOK_DIV, yytext);
"%" 		Parse(PARSER, TOK_MOD, yytext);
"<" 		Parse(PARSER, TOK_LT, yytext);
">" 		Parse(PARSER, TOK_GT, yytext);
"(" 		Parse(PARSER, TOK_LPAR, yytext);
")" 		Parse(PARSER, TOK_RPAR, yytext);
"[" 		Parse(PARSER, TOK_LBRAC, yytext);
"]" 		Parse(PARSER, TOK_RBRAC, yytext);
"=" 		Parse(PARSER, TOK_EQ, yytext);
[A-Z]		Parse(PARSER, TOK_ID, yytext);
{COMMENT}	|
[[:space:]]	/* ignore */
. {
	fprintf(stderr, "scanner: unexpected '%s'\n", yytext);
	exit(EXIT_FAILURE);
  }

%%

int main()
{
	PARSER = ParseAlloc(malloc);
	ParseTrace(stderr, "parser: ");
	yylex();
	Parse(PARSER, 0, 0);
	ParseFree(PARSER, free);
	return 0;
}

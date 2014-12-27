#ifndef INTERP_H
#define INTERP_H

#define MAXLITERAL 80
#define MAXVAR 100

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

enum tokentype {
	SUB, ENDSUB, READ, WRITE, IF, THEN, ELSE, ENDIF, WHILE, DO, ENDWHILE, NOT, AND, OR, FOR, TO, DOWNTO, STEP, ENDFOR, LET, CALL, NKEYWORDS, /* keywords */
	LT, GT, EQ, PLUS, MINUS, MULT, DIV, MOD, /* operators */
	LPAREN, RPAREN, LBRACK, RBRACK,
	ID, NUMBER, LITERAL, EOF_TOKEN,
};

#include "scanner.h"
#include "parse.h"

extern const char *tokenname[];

extern double numberval;
extern char stringval[];
extern struct astnode *subproc[];
extern enum tokentype token;
extern FILE *infile;

extern void error(const char *);

#endif /* INTERP_H */

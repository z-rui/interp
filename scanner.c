#include "interp.h"

const char *tokenname[] = {
	"SUB", "ENDSUB", "READ", "WRITE", "IF", "THEN", "ELSE", "ENDIF", "WHILE", "DO", "ENDWHILE", "NOT", "AND", "OR", "FOR", "TO", "DOWNTO", "STEP", "ENDFOR", "LET", "CALL", NULL,
	"<", ">", "=", "+", "-", "*", "/", "%",
	"(", ")", "[", "]",
	"ID", "NUMBER", "LITERAL", "EOF",
};

static void getkeyword(void)
{
	int i = 1;
	int ch;

	while ((ch = fgetc(infile)) != EOF && isupper(ch)) {
		stringval[i++] = ch;
		if (i == MAXLITERAL)
			error("KEYWORD string too long");
	}
	ungetc(ch, infile);
	stringval[i] = '\0';
	if (ch == EOF)
		error("EOF when scanning KEYWORD");
	for (i = 0; i < NKEYWORDS; i++)
		if (strcmp(stringval, tokenname[i]) == 0)
			break;
	if (i == NKEYWORDS)
		error("unrecognized KEYWORD");
	token = i;
}

static void getliteral(void)
{
	int i = 0;
	int ch;

	while ((ch = fgetc(infile)) != EOF && ch != '"') {
		stringval[i++] = ch;
		if (i == MAXLITERAL)
			error("LITERAL string too long");
	}
	stringval[i] = '\0';
	if (ch == EOF)
		error("EOF when scanning LITERAL");
}

static enum tokentype getoperator(char ch)
{
	switch (ch) {
		case '+': return PLUS;
		case '-': return MINUS;
		case '*': return MULT;
		case '/': return DIV;
		case '%': return MOD;
		case '<': return LT;
		case '>': return GT;
		case '(': return LPAREN;
		case ')': return RPAREN;
		case '[': return LBRACK;
		case ']': return RBRACK;
		case '=': return EQ;
		default: error("unrecognized token");
	}
	return 0;
}

void gettoken(void)
{
	int ch;

regettoken:
	while ((ch = fgetc(infile)) != EOF && isspace(ch))
		/* skip whitespaces */;
	if (ch == EOF) {
		token = EOF_TOKEN;
	} else if (ch == '{') { /* comment */
		while ((ch = fgetc(infile)) != EOF && ch != '}')
			;
		goto regettoken;
	} else if (isdigit(ch)) {
		ungetc(ch, infile);
		if (fscanf(infile, "%lg", &numberval) != 1)
			error("failed scanning number");
		token = NUMBER;
	} else if (isupper(ch)) {
		int ch1;

		ch1 = fgetc(infile);
		if (ch1 == EOF)
			error("EOF when scanning ID or KEYWORD");
		ungetc(ch1, infile);
		stringval[0] = ch;
		if (isupper(ch1)) {
			/* KEYWORD */
			getkeyword();
		} else {
			/* ID */
			token = ID;
		}
	} else if (ch == '"') {
		token = LITERAL;
		getliteral();
	} else {
		token = getoperator(ch);
	}
}


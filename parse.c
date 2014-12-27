/* grammar:
 *
 * prgm ::= sub-list block
 * sub-list     ::= { sub-dcl }
 * sub-dcl      ::= "SUB" NUMBER block "ENDSUB"
 * block        ::= { stmt }
 * stmt         ::= read-stmt
 *                | write-stmt
 *                | if-stmt
 *                | while-stmt
 *                | for-stmt
 *                | assign-stmt
 *                | call-stmt
 * read-stmt    ::= "READ" var
 * write-stmt   ::= "WRITE" write-arg
 * write-arg    ::= LITERAL | expr
 * if-stmt      ::= "IF" condition "THEN" block [ "ELSE" block ] "ENDIF"
 * while-stmt   ::= "WHILE" condition "DO" block "ENDWHILE"
 * condition    ::= compare-condition
 *                | logical-condition
 * compare-condition
 *              ::= expr compare-op expr
 * compare-op   ::= "<" | ">" | "="
 * logical-condition
 *              ::= bracket-condition logical-op bracket-condition
 *                | "NOT" bracket-condition
 * bracket-condition
 *              ::= "(" condition ")"
 * logical-op   ::= "AND" | "OR"
 * for-stmt     ::= "FOR" var "=" expr to-word expr [ "STEP" expr ] "DO" block "ENDFOR"
 * to-word      ::= "TO" | "DOWNTO"
 * assign-stmt  ::= "LET" var "=" expr
 * call-stmt    ::= "CALL" NUMBER;
 * var          ::= ID | "[" expr "]"
 * expr         ::= add-expr
 * add-expr     ::= mult-expr { add-op mult-expr }
 * add-op       ::= "+" | "-"
 * mult-expr    ::= unary-expr { mult-op unary-expr }
 * mult-op      ::= "*" | "/" | "%"
 * unary-expr   ::= unary-op unary-expr | primary-expr
 * unary-op     ::= "+" | "-"
 * primary-expr ::= "(" expr ")" | var | NUMBER
 *
 */

#include "interp.h"

double numberval;
char stringval[MAXLITERAL];
struct astnode *subproc[MAXVAR];
enum tokentype token;
FILE *infile;

static struct astnode *prgm(void);
static void subdcl(void);
static struct astnode *block(void);
static struct astnode *stmt(void);
static struct astnode *readstmt(void);
static struct astnode *writestmt(void);
static struct astnode *condition(void);
static struct astnode *comparecondition(void);
static struct astnode *logicalcondition(void);
static struct astnode *bracketcondition(void);
static struct astnode *ifstmt(void);
static struct astnode *forstmt(void);
static struct astnode *whilestmt(void);
static struct astnode *assignstmt(void);
static struct astnode *callstmt(void);
static struct astnode *var(void);
static struct astnode *expr(void);
static struct astnode *addexpr(void);
static struct astnode *multexpr(void);
static struct astnode *unaryexpr(void);
static struct astnode *primaryexpr(void);

static void match(enum tokentype tok)
{
	char buf[64];

	if (token != tok) {
		sprintf(buf, "expect %s, got %s instead", tokenname[tok], tokenname[token]);
		error(buf);
	}
	gettoken();
}

static struct astnode *newnode(enum nodetype type)
{
	struct astnode *ast = malloc(sizeof *ast);

	if (!ast)
		error("memory fail");
	ast->firstchild = ast->nextsibling = NULL;
	ast->type = type;
	return ast;
}

static struct astnode *toknode(enum tokentype tok)
{
	struct astnode *ast = newnode(OTHER);

	ast->token = tok;
	return ast;
}

struct astnode *parse(void)
{
	struct astnode *ast;

	gettoken();
	ast = prgm();
	if (token != EOF_TOKEN)
		error("expect EOF");
	return ast;
}

struct astnode *prgm(void)
{
	while (token == SUB)
		subdcl();
	return block();
}

void subdcl(void)
{
	int subno;
	struct astnode *ast;

	match(SUB);
	subno = (int) numberval;
	match(NUMBER);
	if (subno < 0 || subno >= MAXVAR)
		error("invalid subno");
	ast = block();
	match(ENDSUB);
	subproc[subno] = ast;
}

struct astnode *block(void)
{
	struct astnode *ast = newnode(BLOCK);
	struct astnode *child;

	ast->firstchild = child = stmt();
	while (child)
		child = child->nextsibling = stmt();
	return ast;
}

struct astnode *stmt()
{
	switch (token) {
		case READ: return readstmt();
		case WRITE: return writestmt();
		case IF: return ifstmt();
		case WHILE: return whilestmt();
		case FOR: return forstmt();
		case LET: return assignstmt();
		case CALL: return callstmt();
		default: return NULL;
	}
}

struct astnode *readstmt(void)
{
	struct astnode *ast = toknode(READ);

	match(READ);
	ast->firstchild = var();
	return ast;
}

struct astnode *writestmt(void)
{
	struct astnode *ast = toknode(WRITE);
	
	match(WRITE);
	if (token == LITERAL) {
		ast->firstchild = toknode(LITERAL);
		ast->firstchild->attr.str = strdup(stringval);
		match(LITERAL);
	} else {
		ast->firstchild = expr();
	}
	return ast;
}

struct astnode *condition(void)
{
	if (token == LPAREN || token == NOT)
		return logicalcondition();
	return comparecondition();
}

struct astnode *comparecondition(void)
{
	struct astnode *ast = NULL, *lhs, *rhs;

	lhs = expr();
	if (token == LT || token == GT || token == EQ) {
		ast = toknode(token);
		match(token);
		rhs = expr();
		ast->firstchild = lhs;
		lhs->nextsibling = rhs;
	} else {
		error("expect <, > or =");
	}
	return ast;
}

struct astnode *logicalcondition(void)
{
	struct astnode *ast, *lhs, *rhs;

	if (token == NOT) {
		match(NOT);
		ast = toknode(NOT);
		ast->firstchild = bracketcondition();
	} else {
		ast = newnode(OTHER);
		ast->firstchild = lhs = bracketcondition();
		if (token == AND || token == OR) {
			ast->token = token;
			match(token);
		} else {
			error("expect AND or OR");
		}
		lhs->nextsibling = rhs = bracketcondition();
	}
	return ast;
}

struct astnode *bracketcondition(void)
{
	struct astnode *ast;

	match(LPAREN);
	ast = condition();
	match(RPAREN);
	return ast;
}

struct astnode *ifstmt(void)
{
	struct astnode *ast, *child;

	match(IF);
	ast = toknode(IF);
	child = ast->firstchild = condition();
	match(THEN);
	child = child->nextsibling = block();
	if (token == ELSE) {
		match(ELSE);
		child = child->nextsibling = block();
	}
	match(ENDIF);
	return ast;
}

struct astnode *forstmt(void)
{
	struct astnode *ast = toknode(FOR);
	struct astnode *child;
	enum tokentype tomode = 0;

	match(FOR);
	child = ast->firstchild = var();
	match(EQ);
	child = child->nextsibling = expr();
	if (token == TO || token == DOWNTO) {
		tomode = token;
		match(token);
	} else {
		error("expect TO or DOWNTO");
	}
	child = child->nextsibling = expr();
	if (token == STEP) {
		match(STEP);
		child = child->nextsibling = expr();
	} else {
		/* default step */
		child = child->nextsibling = toknode(NUMBER);
		child->attr.num = (tomode == TO) ? 1 : -1;
	}
	match(DO);
	child = child->nextsibling = block();
	match(ENDFOR);

	return ast;
}

struct astnode *whilestmt(void)
{
	struct astnode *ast = toknode(WHILE);
	struct astnode *child;

	match(WHILE);
	child = ast->firstchild = condition();
	match(DO);
	child = child->nextsibling = block();
	match(ENDWHILE);
	return ast;
}

struct astnode *assignstmt(void)
{
	struct astnode *ast = toknode(LET);

	match(LET);
	ast->firstchild = var();
	match(EQ);
	ast->firstchild->nextsibling = expr();
	return ast;
}

struct astnode *callstmt(void)
{
	struct astnode *ast = toknode(CALL);

	match(CALL);
	ast->attr.num = numberval;
	match(NUMBER);
	return ast;
}

struct astnode *var(void)
{
	struct astnode *ast = NULL;

	if (token == ID) {
		ast = toknode(ID);
		ast->attr.id = stringval[0];
		match(ID);
	} else if (token == LBRACK) {
		ast = newnode(MEMREF);
		match(LBRACK);
		ast->firstchild = expr();
		match(RBRACK);
	} else {
		error("expect ID or [");
	}
	return ast;
}

struct astnode *expr(void)
{
	return addexpr();
}

struct astnode *addexpr(void)
{
	struct astnode *ast = multexpr();
	struct astnode *a, *b;

	while (token == PLUS || token == MINUS) {
		a = ast;
		ast = toknode(token);
		match(token);
		b = multexpr();
		ast->firstchild = a;
		a->nextsibling = b;
	}
	return ast;
}

struct astnode *multexpr(void)
{	
	struct astnode *ast = unaryexpr();
	struct astnode *a, *b;

	while (token == MULT || token == DIV || token == MOD) {
		a = ast;
		ast = toknode(token);
		match(token);
		b = unaryexpr();
		ast->firstchild = a;
		a->nextsibling = b;
	}
	return ast;
}

struct astnode *unaryexpr(void)
{
	while (token == PLUS)
		match(PLUS);
	if (token == MINUS) {
		struct astnode *ast = newnode(NEG);
		match(MINUS);
		ast->firstchild = unaryexpr();
		return ast;
	}
	return primaryexpr();
}

struct astnode *primaryexpr(void)
{
	struct astnode *ast = NULL;

	if (token == LPAREN) {
		match(LPAREN);
		ast = expr();
		match(RPAREN);
	} else if (token == NUMBER) {
		ast = toknode(NUMBER);
		ast->attr.num = numberval;
		match(NUMBER);
	} else if (token == ID || token == LBRACK) {
		ast = var();
	} else {
		error("expect (, NUMBER, ID or [");
	}
	return ast;
}


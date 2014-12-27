#include "interp.h"
#include <assert.h>
#include <math.h>

static double mem[MAXVAR];

static void stmt(struct astnode *ast);
static void readstmt(struct astnode *ast);
static void writestmt(struct astnode *ast);
static void assignstmt(struct astnode *ast);
static void forstmt(struct astnode *ast);
static void ifstmt(struct astnode *ast);
static void whilestmt(struct astnode *ast);
static void callstmt(struct astnode *ast);
static int evalbool(struct astnode *ast);
static double eval(struct astnode *ast);

static void setmem(int index, double val)
{
	if (index < 0 || index >= MAXVAR)
		error("runtime index out of bound");
	mem[index] = val;
}

static double getmem(int index)
{
	if (index < 0 || index >= MAXVAR)
		error("runtime index out of bound");
	return mem[index];
}

static int tomemindex(struct astnode *ast)
{
	if (ast->type == OTHER && ast->token == ID)
		return ast->attr.id - 'A';
	if (ast->type == MEMREF)
		return (int) eval(ast->firstchild);
	error("interp bug: invalid reference");
	return 0;
}

void block(struct astnode *ast)
{
	struct astnode *child;

	assert(ast->type == BLOCK);
	for (child = ast->firstchild; child; child = child->nextsibling)
		stmt(child);
}

void stmt(struct astnode *ast)
{
	assert(ast->type == OTHER);
	switch (ast->token) {
		case READ:	return readstmt(ast);
		case WRITE:	return writestmt(ast);
		case LET:	return assignstmt(ast);
		case FOR:	return forstmt(ast);
		case IF:	return ifstmt(ast);
		case WHILE:	return whilestmt(ast);
		case CALL:	return callstmt(ast);
		default:	error("interp bug: unrecognized stmt");
	}
}

void readstmt(struct astnode *ast)
{
	int i;
	double val;

	i = tomemindex(ast->firstchild);
	scanf("%lg", &val);
	setmem(i, val);
}

void writestmt(struct astnode *ast)
{
	if (ast->firstchild->type == OTHER && ast->firstchild->token == LITERAL)
		puts(ast->firstchild->attr.str);
	else
		printf("%.14lg\n", eval(ast->firstchild));
	fflush(stdout);
}

void assignstmt(struct astnode *ast)
{
	int i;
	double val;
	
	i = tomemindex(ast->firstchild);
	val = eval(ast->firstchild->nextsibling);
	setmem(i, val);
}

void forstmt(struct astnode *ast)
{
	double start, stop, step;
	struct astnode *body, *child;
	int var;

	var = tomemindex(child = ast->firstchild);
	start = eval(child = child->nextsibling);
	stop = eval(child = child->nextsibling);
	step = eval(child = child->nextsibling);
	body = child = child->nextsibling;

	if (var < 0 || var >= MAXVAR)
		error("runtime index out of bound");
	for (mem[var] = start; (step > 0) ? mem[var] <= stop : mem[var] >= stop; mem[var] += step) {
		block(body);
	}
}

void ifstmt(struct astnode *ast)
{
	struct astnode *condition, *thenpart, *elsepart, *child;

	condition = child = ast->firstchild;
	thenpart = child = child->nextsibling;
	elsepart = child = child->nextsibling;
	if (evalbool(condition))
		block(thenpart);
	else if (elsepart)
		block(elsepart);
}

void whilestmt(struct astnode *ast)
{
	struct astnode *condition, *body, *child;

	condition = child = ast->firstchild;
	body = child = child->nextsibling;
	while (evalbool(condition))
		block(body);
}

void callstmt(struct astnode *ast)
{
	struct astnode *sub = subproc[(int) ast->attr.num];

	if (!sub)
		error("called subprocedure is not defined");
	block(sub);
}

int evalbool(struct astnode *ast)
{
	struct astnode *lhs, *rhs;

	assert(ast->type == OTHER);
	lhs = ast->firstchild;
	rhs = lhs->nextsibling;
	switch (ast->token) {
		case LT:	return eval(lhs) < eval(rhs);
		case GT:	return eval(lhs) > eval(rhs);
		case EQ:	return eval(lhs) == eval(rhs);
		case AND:	return evalbool(lhs) && evalbool(rhs);
		case OR:	return evalbool(lhs) || evalbool(rhs);
		case NOT:	return !evalbool(lhs);
		default:	error("interp bug: unrecognized compare");
	}
	return 0;
}

double eval(struct astnode *ast)
{
	struct astnode *lhs = ast->firstchild, *rhs = lhs ? lhs->nextsibling : NULL;

	switch (ast->type) {
		case MEMREF:	return getmem(tomemindex(ast));
		case NEG:	return -eval(ast->firstchild);
		default:	assert(ast->type == OTHER);
	}
	switch (ast->token) {
		case PLUS:	return eval(lhs) + eval(rhs);
		case MINUS:	return eval(lhs) - eval(rhs);
		case MULT:	return eval(lhs) * eval(rhs);
		case DIV:	return eval(lhs) / eval(rhs);
		case MOD:	return fmod(eval(lhs), eval(rhs));
		case NUMBER:	return ast->attr.num;
		case ID:	return getmem(tomemindex(ast));
		default:	error("eval bug: unrecognized operation");
	}
	return 0.0;
}

void error(const char *s)
{
	fprintf(stderr, "interp: %s\n", s);
	exit(EXIT_FAILURE);
}

int main(int argc, char *argv[])
{
	struct astnode *ast;

	if (!argv[1]) {
		fprintf(stderr, "usage: %s source\n", argv[0]);
		error("no input specified");
	}
	infile = fopen(argv[1], "r");
	ast = parse();
	fclose(infile);
	block(ast);
	return 0;
}

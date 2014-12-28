#include "interp.h"
#include "scanner.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <math.h>

static struct {
	struct parse_context parse;
	struct ast_stmt *sub[MAXVAR];
	double mem[MAXVAR];
} runtime = { {0, runtime.sub, 0}, {0}, {0} };

static void readstmt(struct ast_var *);
static void writestmt(struct ast_write *);
static void assignstmt(struct ast_assign *);
static void forstmt(struct ast_for *);
static void ifstmt(struct ast_if *);
static void whilestmt(struct ast_while *);
static void callstmt(int);
static double eval(struct ast_expr *);

static double *varref(struct ast_var *var)
{
	int idx;

	idx = (var->indirect) ? (int) eval(var->u.expr) : (var->u.id - 'A');
	if (idx < 0 || idx >= MAXVAR)
		error("runtime index out of bound");
	return &runtime.mem[idx];
}

void block(struct ast_stmt *ast)
{
	while (ast) {
		switch (ast->tok) {
			case TOK_READ:	readstmt(ast->u.var); break;
			case TOK_WRITE:	writestmt(ast->u.write); break;
			case TOK_LET:	assignstmt(ast->u.assign); break;
			case TOK_FOR:	forstmt(ast->u.for_); break;
			case TOK_IF:	ifstmt(ast->u.if_); break;
			case TOK_WHILE:	whilestmt(ast->u.while_); break;
			case TOK_CALL:	callstmt(ast->u.subno); break;
			default:	error("interp bug: unrecognized stmt");
		}
		ast = ast->next;
	}
}

void readstmt(struct ast_var *arg)
{
	scanf("%lg", varref(arg));
}

void writestmt(struct ast_write *arg)
{
	if (arg->isliteral) {
		puts(arg->u.literal);
	} else {
		printf("%.14lg\n", eval(arg->u.expr));
	}
	fflush(stdout);
}

void assignstmt(struct ast_assign *ast)
{
	*varref(ast->l) = eval(ast->r);
}

void forstmt(struct ast_for *ast)
{
	double *var;
	double lower, upper, step;

	var = varref(ast->var);
	lower = eval(ast->lower);
	upper = eval(ast->upper);
	step = (ast->step) ? eval(ast->step) : (ast->tok == TOK_TO) ? 1.0 : -1.0;

	for (*var = lower; (step > 0) ? *var <= upper : *var >= upper; *var += step) {
		block(ast->block);
	}
}

void ifstmt(struct ast_if *ast)
{
	if (eval(ast->cond))
		block(ast->yes);
	else
		block(ast->no);
}

void whilestmt(struct ast_while *ast)
{
	while (eval(ast->cond))
		block(ast->block);
}

void callstmt(int idx)
{
	struct ast_stmt *sub = runtime.sub[idx];

	if (!sub)
		error("called subprocedure is not defined");
	block(sub);
}

double eval(struct ast_expr *ast)
{
#define lhs ast->u.bin.l
#define rhs ast->u.bin.r
	switch (ast->tok) {
		case TOK_ID:	return *varref(ast->u.var); /* means expr ::= var */
		case TOK_NUMBER:return ast->u.val;

		case TOK_PLUS:	return eval(lhs) + eval(rhs);
		case TOK_MINUS:	return ((lhs) ? eval(lhs) : 0.0) - eval(rhs);
		case TOK_MULT:	return eval(lhs) * eval(rhs);
		case TOK_DIV:	return eval(lhs) / eval(rhs);
		case TOK_MOD:	return fmod(eval(lhs), eval(rhs));

		case TOK_LT:	return eval(lhs) < eval(rhs);
		case TOK_GT:	return eval(lhs) > eval(rhs);
		case TOK_EQ:	return eval(lhs) == eval(rhs);
		case TOK_AND:	return eval(lhs) && eval(rhs);
		case TOK_OR:	return eval(lhs) || eval(rhs);
		case TOK_NOT:	return !eval(lhs);
	}
#undef lhs
#undef rhs
	error("eval bug: unrecognized operation");
	return 0.0;
}

void error(const char *s)
{
	fprintf(stderr, "interp: %s\n", s);
	exit(EXIT_FAILURE);
}

int main(int argc, char *argv[])
{
	yyscan_t scanner;
	FILE *infile;

	if (!argv[1]) {
		fprintf(stderr, "usage: %s source\n", argv[0]);
		error("no input specified");
	}
	infile = fopen(argv[1], "r");
	runtime.parse.parser = ParseAlloc(malloc);
#if	0 && !defined(NDEBUG)
	ParseTrace(stderr, "parser: ");
#endif

	yylex_init_extra(&runtime.parse, &scanner);
	yyset_in(infile, scanner);
	yylex(scanner);
	yylex_destroy(scanner);

	ParseFree(runtime.parse.parser, free);

	fclose(infile);

	block(runtime.parse.main);

	return 0;
}

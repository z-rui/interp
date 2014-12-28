%token_prefix {TOK_}
%token_type {char *}

%include {
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "interp.h"
}

%extra_argument {struct parse_context *ctxt}

%syntax_error {
	fprintf(stderr, "parser: unexpected token %s\n", TOKEN);
	exit(EXIT_FAILURE);
}

%type prgm {struct ast_stmt *}
prgm         ::= sub_list block(B).
{
	ctxt->main = B;
}

sub_list     ::= .
sub_list     ::= sub_list sub_dcl.

sub_dcl      ::= SUB number(B) block(C) ENDSUB.
{
	ctxt->sub[(int) B] = C;
}

%type block {struct ast_stmt *}
block(A)     ::= stmt_list(B).
{
	A = B->head;
	*B->tail = 0;
}

%include{
struct ast_stmt_list {
	struct ast_stmt *head, **tail;
};
}

%type stmt_list {struct ast_stmt_list *}
stmt_list(A)     ::= .
{
	A = GC_MALLOC(sizeof *A);
	A->head = 0;
	A->tail = &A->head;
}
stmt_list(A)     ::= stmt_list(B) stmt(C).
{
	A = B;
	*A->tail = C;
	A->tail = &C->next;
}

%type stmt {struct ast_stmt *}
stmt(A)      ::= read_stmt(B).
{
	A = GC_MALLOC(sizeof *A);
	A->tok = TOK_READ;
	A->u.var = B;
}
stmt(A)      ::= write_stmt(B).
{
	A = GC_MALLOC(sizeof *A);
	A->tok = TOK_WRITE;
	A->u.write = B;
}
stmt(A)      ::= if_stmt(B).
{
	A = GC_MALLOC(sizeof *A);
	A->tok = TOK_IF;
	A->u.if_ = B;
}
stmt(A)      ::= while_stmt(B).
{
	A = GC_MALLOC(sizeof *A);
	A->tok = TOK_WHILE;
	A->u.while_ = B;
}
stmt(A)      ::= for_stmt(B).
{
	A = GC_MALLOC(sizeof *A);
	A->tok = TOK_FOR;
	A->u.for_ = B;
}
stmt(A)      ::= assign_stmt(B).
{
	A = GC_MALLOC(sizeof *A);
	A->tok = TOK_LET;
	A->u.assign = B;
}
stmt(A)      ::= call_stmt(B).
{
	A = GC_MALLOC(sizeof *A);
	A->tok = TOK_CALL;
	A->u.subno = B;
}

%type read_stmt {struct ast_var *}
read_stmt(A) ::= READ var(B).
{
	A = B;
}

%type write_stmt {struct ast_write *}
write_stmt(A)::= WRITE literal(B).
{
	A = GC_MALLOC(sizeof *A);
	A->isliteral = 1;
	A->u.literal = B;
}
write_stmt(A)::= WRITE expr(B).
{
	A = GC_MALLOC(sizeof *A);
	A->isliteral = 0;
	A->u.expr = B;
}

%type literal {char *}
literal(A)   ::= LITERAL(B).
{
	A = B+1;
	*strchr(A, '"') = '\0';
}

%type number {double}
number(A)    ::= NUMBER(B).
{
	A = strtod(B, 0);
}

%type if_stmt {struct ast_if *}
if_stmt(A)   ::= IF cond(B) THEN block(C) ENDIF.
{
	A = GC_MALLOC(sizeof *A);
	A->cond = B;
	A->yes = C;
	A->no = 0;
}
if_stmt(A)   ::= IF cond(B) THEN block(C) ELSE block(D) ENDIF.
{
	A = GC_MALLOC(sizeof *A);
	A->cond = B;
	A->yes = C;
	A->no = D;
}

%type while_stmt {struct ast_while *}
while_stmt(A)::= WHILE cond(B) DO block(C) ENDWHILE.
{
	A = GC_MALLOC(sizeof *A);
	A->cond = B;
	A->block = C;
}

%type for_stmt {struct ast_for *}
for_stmt(A)  ::= FOR var(VAR) EQ expr(LOWER) TO|DOWNTO expr(UPPER) DO block(BLOCK) ENDFOR.
{
	A = GC_MALLOC(sizeof *A);
	A->var = VAR;
	A->lower = LOWER;
	A->upper = UPPER;
	A->step = 0;
	A->block = BLOCK;
}
for_stmt(A)  ::= FOR var(VAR) EQ expr(LOWER) TO|DOWNTO expr(UPPER) STEP expr(STEP) DO block(BLOCK) ENDFOR.
{
	A = GC_MALLOC(sizeof *A);
	A->var = VAR;
	A->lower = LOWER;
	A->upper = UPPER;
	A->step = STEP;
	A->block = BLOCK;
}

%type assign_stmt {struct ast_assign *}
assign_stmt(A)
             ::= LET var(B) EQ expr(C).
{
	A = GC_MALLOC(sizeof *A);
	A->l = B;
	A->r = C;
}

%type call_stmt {int}
call_stmt(A) ::= CALL number(B).
{
	A = (int) B;
}

%left PLUS MINUS.
%left MULT DIV MOD.

%type expr {struct ast_expr *}
expr(A)      ::= number(B).
{
	A = GC_MALLOC(sizeof *A);
	A->tok = TOK_NUMBER;
	A->u.val = B;
}
expr(A)      ::= var(B).
{
	A = GC_MALLOC(sizeof *A);
	A->tok = TOK_ID;
	A->u.var = B;
}
expr(A)      ::= LPAR expr(B) RPAR.
{
	A = B;
}
expr(A)      ::= expr(B) PLUS|MINUS(OP) expr(C).
{
	A = GC_MALLOC(sizeof *A);
	A->tok = @OP;
	A->u.bin.l = B;
	A->u.bin.r = C;
}
expr(A)      ::= expr(B) MULT|DIV|MOD(OP) expr(C).
{
	A = GC_MALLOC(sizeof *A);
	A->tok = @OP;
	A->u.bin.l = B;
	A->u.bin.r = C;
}
expr(A)      ::= MINUS expr(B).
{
	A = GC_MALLOC(sizeof *A);
	A->tok = TOK_MINUS;
	A->u.bin.l = 0;
	A->u.bin.r = B;
}

%left OR.
%left AND.
%right NOT.

%type cond {struct ast_expr *}
cond(A)   ::= expr(B) LT|GT|EQ(OP) expr(C).
{
	A = GC_MALLOC(sizeof *A);
	A->tok = @OP;
	A->u.bin.l = B;
	A->u.bin.r = C;
}
cond(A)      ::= logical(B).
{
	A = B;
}

%type logical {struct ast_expr *}
logical(A)   ::= LPAR cond(B) RPAR.
{
	A = B;
}
logical(A)   ::= logical(B) AND|OR(OP) logical(C).
{
	A = GC_MALLOC(sizeof *A);
	A->tok = @OP;
	A->u.bin.l = B;
	A->u.bin.r = C;
}
logical(A)   ::= NOT logical(B).
{
	A = GC_MALLOC(sizeof *A);
	A->tok = TOK_NOT;
	A->u.bin.l = 0;
	A->u.bin.r = B;
}

%type var {struct ast_var *}
var(A)       ::= ID(B).
{
	A = GC_MALLOC(sizeof *A);
	A->indirect = 0;
	A->u.id = B[0];
}
var(A)       ::= LBRAC expr(B) RBRAC.
{
	A = GC_MALLOC(sizeof *A);
	A->indirect = 1;
	A->u.expr = B;
}

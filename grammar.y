%token_prefix {TOK_}
%token_type {const char *}

%include {
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "grammar.h"
}

%syntax_error {
	fprintf(stderr, "parser: unexpected token %s\n", TOKEN);
	exit(EXIT_FAILURE);
}

%type prgm {struct ast_stmt *}
%destructor prgm {free($$);}
prgm(A)         ::= sub_list block(B).
{
	A = B->head;
	free(B);
}

sub_list     ::= .
sub_list     ::= sub_list sub_dcl.

sub_dcl      ::= SUB NUMBER(B) block(C) ENDSUB.
{
	/* TODO:
		register_subroutine((int) strtod(B, 0), C->head);
	*/
	free(C);
}

%type block {struct ast_block *}
%destructor block {free($$);}
block(A)     ::= .
{
	A = malloc(sizeof *A);
	A->head = 0;
	A->tail = &A->head;
}
block(A)     ::= block(B) stmt(C).
{
	A = B;
	*(A->tail) = C;
	A->tail = &C->next;
}

%type stmt {struct ast_stmt *}
%destructor stmt {free($$);}
stmt(A)      ::= read_stmt(B).
{
	A = malloc(sizeof *A);
	A->tok = TOK_READ;
	A->u.var = B;
}
stmt(A)      ::= write_stmt(B).
{
	A = malloc(sizeof *A);
	A->tok = TOK_WRITE;
	A->u.write = B;
}
stmt(A)      ::= if_stmt(B).
{
	A = malloc(sizeof *A);
	A->tok = TOK_IF;
	A->u.if_ = B;
}
stmt(A)      ::= while_stmt(B).
{
	A = malloc(sizeof *A);
	A->tok = TOK_WHILE;
	A->u.while_ = B;
}
stmt(A)      ::= for_stmt(B).
{
	A = malloc(sizeof *A);
	A->tok = TOK_FOR;
	A->u.for_ = B;
}
stmt(A)      ::= assign_stmt(B).
{
	A = malloc(sizeof *A);
	A->tok = TOK_EQ;
	A->u.assign = B;
}
stmt(A)      ::= call_stmt(B).
{
	A = malloc(sizeof *A);
	A->tok = TOK_CALL;
	A->u.subno = B;
}

%type read_stmt {struct ast_var *}
%destructor read_stmt {free($$);}
read_stmt(A) ::= READ var(B).
{
	A = B;
}

%type write_stmt {struct ast_write *}
%destructor write_stmt {free($$);}
write_stmt(A)::= WRITE LITERAL(B).
{
	A = malloc(sizeof *A);
	A->isliteral = 1;
	A->u.literal = strcpy(malloc(strlen(B) + 1), B);
}
write_stmt(A)::= WRITE expr(B).
{
	A = malloc(sizeof *A);
	A->isliteral = 0;
	A->u.expr = B;
}

%type if_stmt {struct ast_if *}
%destructor if_stmt {free($$);}
if_stmt(A)   ::= IF cond(B) THEN block(C) ENDIF.
{
	A = malloc(sizeof *A);
	A->cond = B;
	A->yes = C;
	A->no = 0;
}
if_stmt(A)   ::= IF cond(B) THEN block(C) ELSE block(D) ENDIF.
{
	A = malloc(sizeof *A);
	A->cond = B;
	A->yes = C;
	A->no = D;
}

%type while_stmt {struct ast_while *}
%destructor while_stmt {free($$);}
while_stmt(A)::= WHILE cond(B) DO block(C) ENDWHILE.
{
	A = malloc(sizeof *A);
	A->cond = B;
	A->block = C;
}

%type for_stmt {struct ast_for *}
%destructor for_stmt {free($$);}
for_stmt(A)  ::= FOR var(VAR) EQ expr(LOWER) TO|DOWNTO expr(UPPER) DO block(BLOCK) ENDFOR.
{
	A = malloc(sizeof *A);
	A->var = VAR;
	A->lower = LOWER;
	A->upper = UPPER;
	A->step = 0;
	A->block = BLOCK;
}
for_stmt(A)  ::= FOR var(VAR) EQ expr(LOWER) TO|DOWNTO expr(UPPER) STEP expr(STEP) DO block(BLOCK) ENDFOR.
{
	A = malloc(sizeof *A);
	A->var = VAR;
	A->lower = LOWER;
	A->upper = UPPER;
	A->step = STEP;
	A->block = BLOCK;
}

%type assign_stmt {struct ast_assign *}
%destructor assign_stmt {free($$);}
assign_stmt(A)
             ::= LET var(B) EQ expr(C).
{
	A = malloc(sizeof *A);
	A->l = B;
	A->r = C;
}

%type call_stmt {int}
call_stmt(A) ::= CALL NUMBER(B).
{
	A = (int) strtod(B, 0);
}

%left PLUS MINUS.
%left MULT DIV MOD.

%type expr {struct ast_expr *}
%destructor expr {free($$);}
expr(A)      ::= NUMBER(B).
{
	A = malloc(sizeof *A);
	A->tok = TOK_NUMBER;
	A->u.val = strtod(B, 0);
}
expr(A)      ::= var(B).
{
	A = malloc(sizeof *A);
	A->tok = TOK_ID;
	A->u.var = B;
}
expr(A)      ::= LPAR expr(B) RPAR.
{
	A = B;
}
expr(A)      ::= expr(B) PLUS|MINUS|MULT|DIV|MOD(OP) expr(C).
{
	A = malloc(sizeof *A);
	A->tok = @OP;
	A->u.l = B;
	A->u.r = C;
}
expr(A)      ::= MINUS expr(B).
{
	A = malloc(sizeof *A);
	A->tok = TOK_MINUS;
	A->u.l = 0;
	A->u.r = B;
}

%left OR.
%left AND.
%right NOT.

%type cond {struct ast_expr *}
%destructor cond {free($$);}
cond(A)   ::= expr(B) LT|GT|EQ(OP) expr(C).
{
	A = malloc(sizeof *A);
	A->tok = @OP;
	A->u.l = B;
	A->u.r = C;
}
cond(A)      ::= logical(B).
{
	A = B;
}

%type logical {struct ast_expr *}
%destructor logical {free($$);}
logical(A)   ::= LPAR cond(B) RPAR.
{
	A = B;
}
logical(A)   ::= logical(B) AND|OR(OP) logical(C).
{
	A = malloc(sizeof *A);
	A->tok = @OP;
	A->u.l = B;
	A->u.r = C;
}
logical(A)   ::= NOT logical(B).
{
	A = malloc(sizeof *A);
	A->tok = TOK_NOT;
	A->u.l = 0;
	A->u.r = B;
}

%type var {struct ast_var *}
%destructor var {free($$);}
var(A)       ::= ID(B).
{
	A = malloc(sizeof *A);
	A->indirect = 0;
	A->u.id = B[0];
}
var(A)       ::= LBRAC expr(B) RBRAC.
{
	A = malloc(sizeof *A);
	A->indirect = 1;
	A->u.expr = B;
}

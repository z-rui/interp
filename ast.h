struct ast_var {
	int indirect;
	union {
		char id;
		struct ast_expr *expr;
	} u;
};

struct ast_expr {
	int tok;
	union {
		double val;
		struct ast_expr *l, *r;
		struct ast_var *var;
	} u;
};

struct ast_assign {
	struct ast_var *l;
	struct ast_expr *r;
};

struct ast_for {
	struct ast_var *var;
	struct ast_expr *lower, *upper, *step;
	struct ast_block *block;
};

struct ast_while {
	struct ast_expr *cond;
	struct ast_block *block;
};

struct ast_if {
	struct ast_expr *cond;
	struct ast_block *yes, *no;
};

struct ast_write {
	int isliteral;
	union {
		const char *literal;
		struct ast_expr *expr;
	} u;
};

struct ast_stmt {
	int tok;
	union {
		struct ast_var *var; /* READ */
		struct ast_write *write;
		struct ast_if *if_;
		struct ast_while *while_;
		struct ast_for *for_;
		struct ast_assign *assign;
		int subno; /* CALL */
	} u;
	struct ast_stmt *next;
};

struct ast_block {
	struct ast_stmt *head, **tail;
};

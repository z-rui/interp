#ifndef INTERP_H
#define INTERP_H

#define MAXLITERAL 80
#define MAXVAR 100

#include "grammar.h"
#include "ast.h"

struct parse_context {
	void *parser;
	struct ast_stmt *sub[MAXVAR];
	struct ast_stmt *main;
};

#ifndef NDEBUG
extern void ParseTrace(FILE *, char *);
#endif
extern void *ParseAlloc(void *(*)(size_t));
extern void ParseFree(void *, void (*)(void *));
extern void Parse(void *, int, const char *, struct parse_context *);

#endif /* INTERP_H */

#ifndef INTERP_H
#define INTERP_H

#define MAXLITERAL 80
#define MAXVAR 100

#include "ast.h"
#include "grammar.h"
#include <stdio.h>

struct parse_context {
	void *parser;
	struct ast_stmt **sub;
	struct ast_stmt *main;
};

extern void error(const char *s);

#ifndef NDEBUG
extern void ParseTrace(FILE *, char *);
#endif
extern void *ParseAlloc(void *(*)(size_t));
extern void ParseFree(void *, void (*)(void *));
extern void Parse(void *, int, char *, struct parse_context *);

#endif /* INTERP_H */

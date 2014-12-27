#ifndef PARSE_H
#define PARSE_H

enum nodetype {
	BLOCK, MEMREF, NEG, OTHER,
};

struct astnode {
	enum nodetype type;
	enum tokentype token;
	struct astnode *firstchild;
	struct astnode *nextsibling;
	union {
		double num;
		char *str;
		char id;
	} attr;
};

extern struct astnode *parse(void);

#endif

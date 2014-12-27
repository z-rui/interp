CC=gcc
CFLAGS=-Wall -g
LDFLAGS=-lm

a: scanner.o grammar.o

scanner.o: scanner.c scanner.h grammar.h
grammar.o: grammar.c grammar.h 

scanner.c scanner.h: scanner.l
	flex -o scanner.c --header-file=scanner.h scanner.l

grammar.c grammar.h: grammar.y
	./lemon grammar.y

clean:
	rm *.o

.PHONY: clean

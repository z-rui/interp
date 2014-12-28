CC=gcc
CFLAGS=-Wall -g
LDFLAGS=

a: scanner.o grammar.o interp.o
	$(CC) $(LDFLAGS) -o $@ scanner.o grammar.o interp.o -lgc -lm

scanner.o: scanner.c interp.h
grammar.o: grammar.c interp.h 

scanner.c scanner.h: scanner.l
	flex -o scanner.c --header-file=scanner.h scanner.l

grammar.c grammar.h: grammar.y
	lemon grammar.y

interp.o: interp.c interp.h

interp.h: grammar.h scanner.h
	touch $@

clean:
	rm *.o grammar.{c,h,out} scanner.[ch]

.PHONY: clean

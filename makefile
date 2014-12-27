CC=gcc
CFLAGS=-Wall -g
LDFLAGS=-lm -g

a: scanner.o parse.o interp.o
	$(CC) scanner.o parse.o interp.o $(LDFLAGS)

scanner.o: scanner.c scanner.h interp.h

parse.o: parse.c parse.h interp.h

interp.o: interp.c interp.h

clean:
	rm *.o

.PHONY: clean

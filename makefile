.PHONY: all compile clean run
compile: main.o
	@gcc -o main main.o -lm
main.o: main.c main.h
	@gcc -c main.c
clean:
	@rm -rf *.o main
run:
	@./main $(ARGS)

all: compile run

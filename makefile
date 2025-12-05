.PHONY: all compile clean run
compile: main.o
	@gcc -o main main.o
main.o: main.c main.h
	@gcc -c main.c -o main.o
clean:
	@rm -rf *.o main
run:
	@./main $(ARGS)

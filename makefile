.PHONY: all compile clean run
compile: structrw.o
	@gcc -o structrw structrw.o
structrw.o: structrw.c
	@gcc -c structrw.c -o structrw.o
clean:
	@rm -rf *.o structrw
run:
	@./structrw $(ARGS)

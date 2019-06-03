all: root

root: newton.o
	gcc -m64 newton.o -o root

newton.o: newton.s
	nasm  -g -f elf64 -w+all -o newton.o newton.s

.PHONY: clean
clean:
	rm -f *.o root
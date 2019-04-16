a.out: main.o
	ld -m elf_x86_64 main.o
main.o: main.asm
	nasm -f elf64 main.asm


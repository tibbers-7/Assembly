.section .text

poruka1: .ascii "Unesite broj: \0"
a= . - poruka1
ispis1: .ascii "Izmenjeni string: \0"   
b= . - ispis1
ispis2: .ascii "Uneti string je prazan \0"
c= . - ispis2

max= 20
string: 011100101010

.globl main
main:

	movl $4, %eax
	movl $1, %ebx
	movl $poruka1, %ecx
	movl $a, %edx
	int $0x80

	xorl %edi, %edi
	movl $'A', %ebx
	movl $'a', %ecx
	movl $string, %esi

	cmpl $'', %esi
	je ispisdrugi

petlja:
	cmpl $0, %esi
	je nula
	jne keca
	
nula:
	addl %ebx, %eax		
	incl %ebx
	incl %esi
	jmp petlja

keca:
	cmpl $'', %esi
	je ispisprvi
	addl %ecx, %eax
	incl %ecx
	incl %esi
	incl %edi
	jmp petlja


ispisprvi:
	movl $ispis1, %ebx
	movl $b, %ecx
	movl (%ebx, %ecx, 4), %edx
	addl %edx, %eax

	movl $4, %eax
	movl $1, %ebx
	movl %edx, %ecx
	movl $b, %edx
	int $0x80


	jmp kraj

ispisdrugi:
	movl $4, %eax
	movl $1, %ebx
	movl $ispis2, %ecx
	movl $c, %edx

kraj:
	movl $1, %eax
	movl %edi, %ebx
	int $0x80
	
	

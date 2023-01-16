#autor: Anja Dmitrović INDEX ra41-2019
.section .data
prompt_1: .ascii "Unesite string: \0"
prompt_1_len= . - prompt_1
prompt_2: .ascii "Enkodovan string: \0"
prompt_2_len=  . - prompt_2

max=50
unos: .fill max, 1, 0
izlaz: .fill max, 1 ,0


.section .text
.globl main

main:

	movl $4, %eax
	movl $1, %ebx
	movl $prompt_1, %ecx
	movl $prompt_1_len, %edx
	int $0x80

	movl $3, %eax
	movl $0, %ebx
	movl $unos, %ecx	#sistemski poziv za unos
	movl $max, %edx
	int $0x80

	xorl %eax, %eax		#cisti registar eax za dalju upotrebu

	leal unos, %esi		#smesta adresu unesenog stringa i izmenjenog u registre
	leal izlaz, %edi

proveraveliko:
	cmpb $0, (%esi)		#proverava da li smo dosli do kraja ulaznog stringa
	je kraj
	cmpb $'A', (%esi)
	jb nemenjaj		#menjaju se samo slova, ostalo ostaje isto
	cmpb $'Z', (%esi)
	ja proveramalo		#ascii kod a-z je iznad A-Z
	jmp promeniveliko

proveramalo:
	cmpb $'a', (%esi)	#ako je petlja stigla do ove labele, menjaju se samo znakovi a-z
	jb nemenjaj
	cmpb $'z', (%esi)
	ja nemenjaj
	jmp promenimalo

promeniveliko:
	cmpb $'C', (%esi)	#za znakove ABC i abc postoji dodatak korak
	jbe abc
	movb (%esi), %al	#menjamo velika slova i upisujemo ih na izlazni string
	subb $3, %al
	movb %al, (%edi)
	incl %esi		#uvecava adrese da bi ponovo prolazio kroz petlju
	incl %edi
	jmp proveraveliko

promenimalo:
	cmpb $'c', (%esi)
	jbe abc
	movb (%esi), %al	#menjamo mala slova, upisujemo na izlazni
	subb $3, %al
	movb %al, (%edi)
	incl %esi		#uvecava adrese
	incl %edi
	jmp proveraveliko

abc:
	movb (%esi), %al
	subb $3, %al		#na oduzetu ascii vrednost moramo dodati i 26 da bi nastavio da menja u slova
	addb $26, %al
	movb %al, (%edi)
	incl %esi
	incl %edi
	jmp proveraveliko

nemenjaj:
	movb (%esi), %al	#ako znak nije u opsegu A-Z i a-z on ostaje isti pa ga moramo zapisati u izlazni string
	movb %al, (%edi)
	incl %esi		#uvecava adrese
	incl %edi
	jmp proveraveliko

kraj:
	movl $4, %eax
	movl $1, %ebx
	movl $prompt_2, %ecx	#ispisujemo prompt2
	movl $prompt_2_len, %edx
	int $0x80

	movl $4, %eax
	movl $1, %ebx		#ispisujemo izlazni string
	movl $izlaz, %ecx
	movl $max, %edx
	int $0x80

	movl $1, %eax		#sistemski poziv za kraj programa
	movl $0, %ebx
	int $0x80

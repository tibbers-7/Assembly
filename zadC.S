#autor: Imenko Prezimić INDEX ra1234-2015

string1:	.ascii "Unesite tekst:\t\0"
str1_len: . - string1
string2:	.ascii "Resenje je: \0"
string3:	.ascii "Greska: Prekoracenje\n\0"
string4:	.ascii "Greska: Pogresan operand\n\0"
string5:	.ascii "Greska: Ima vise od 2 heks broja\n\0"
string6:	.ascii "Greska: Drugi broj veci od prvog\n\0"

strmax=50
ceo_str: .fill strmax,1,0

section .text
.globl main

main:
	movl $4, %eax
	movl $1, %ebx
	movl $poruka1, %ecx
	movl $str1_len, %edx
	int $0x80

	movl $3, %eax
	movl $0, %ebx
	movl $ceo_str, %ecx
	movl $strmax, %edx
	int $0x80

	leal ceo_str, %esi
	movl (%esi), %edx
	incl %esi
	xorl %eax, %eax
	xorl %ebx, %ebx

petlja:
	movb (%esi), %bl 
	andb %bl, %bl
	jz racunaj
	cmpl $0x2F, %bl
	ja dalje1
	jbe separator

dalje1:
	cmpl $0x3A, %bl
	jb koji
	jae dalje2

dalje: 
	cmpl $0x40, %bl
	ja dalje3
	jbe separator

dalje3:
	cmpl $0x47
	jae separator
	jb koji

koji: 
	jnc prvi
	jc drugi

separator:
	incl %esi
	stc
	jmp petlja

prvi:
	addl %ebx, %eax	
	incl %esi
	jmp petlja

drugi:
	addl %ebx, %eax
	incl %esi
	jmp petlja
	
racunaj:
	addl %eax, %eax
	addl %ecx, %ecx
	cmpl $0x2B, %edx
	je saberi
	cmpl $0x2D, %edx
	je oduzmi
	jne greskica

saberi: 
	addl %eax, %ecx
	jmp decimalni
oduzmi:
	subl %eax, %ebx
	jmp decimalni

greskica1:
	movl $1, %eax
	movl $1, %ebx
	int $0x80

decimalni:
	

	
	

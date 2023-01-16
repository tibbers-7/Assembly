#autor: Anja Dmitrovic INDEX ra41-2019

.section .text
.globl kodiraj 
kodiraj:

# Povezivanje sa C kodom po CDECL konvenciji
	pushl %ebp
	movl %esp, %ebp
	movl 8(%ebp), %eax	
	pushl %ebx		    	
	pushl %esi		
	pushl %edi
	movl $0, %esi
	movl $0, %edi
# Rotiranje broja sa leve i sa desne strane
	movl %eax, %edx
	rorl %eax
	movl %eax, %ebx
	roll %eax
	roll %eax
	movl %eax, %ecx
# Pravljenje univerzalne maske 
racunaj:
	orl %ecx, %ebx
	notl %ebx
	andl %edx, %ebx
	xorl %ebx, %edx
	movl %edx, %eax
	movl $0, %esi
	movl $0, %edi
	movl %eax, %ebx
# Prebrojavanje jedinica u bajtovima nize vrednosti
donji:
	cmpw $0, %bx
	je gornji1
	shrw %bx
	jc broji1
	jmp donji
broji1:
	incl %esi
	jmp donji
# Prebrojavanje jedinica u bajtovima vise vrednosti podeljeno u dva osmobitna registra
gornji1:
	cmpb $0, %bh
	je gornji2
	shrb %bh
	jc broji2
	jmp gornji1
broji2:
	incl %edi
	jmp gornji1
gornji2:
	cmpb $0, %bl
	je poredi
	shrb %bl
	jc broji3
	jmp gornji2
broji3:
	incl %edi
	jmp gornji2
# Poredjenje broja jedinica u bajtovima vise i nize vrednosti
poredi:
	cmpl %esi, %edi
	jge kodiraj_kraj
	rorl $16, %eax
# Restauracija registara i vracanje iz funkcije
kodiraj_kraj:
	popl %edi		
	popl %esi		
	popl %ebx		
	movl %ebp, %esp
	popl %ebp
	ret


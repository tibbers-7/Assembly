#autor: Anja Dmitrović INDEX ra41-2019

.section .text
.globl encode
encode:
	#CDECL konvencija, cuvamo stare vrednosti registara na steku
	pushl %ebp
	movl %esp, %ebp
	pushl %esi
	pushl %edi
	pushl %ebx

	movl 16(%ebp), %esi		#encode
							#stavljam adrese parametara u registre
	movl 8(%ebp), %edi		#izvorni
	movl 12(%ebp), %edx		#ciljni

	xorl %ebx, %ebx
	xorl %eax, %eax		#cistim registre zbog dalje upotrebe
	xorl %ecx, %ecx

poredi:
	cmpb $0, (%edi)
	je naredni		#da li je stiglo do kraja izvornog? Da li smo isproveravali sve znakove iz izvorog?
	cmpb $0, (%esi)		#da li smo stigli do kraja encode? Da li smo isproveravali svaki znak iz originalnog stringa?
	je kraj
	movb (%esi), %cl	#poredi vrednost trenutnog clana niza enkodiraj i izvornog	
	cmpb %cl, (%edi)	#ako su isti treba menjati enkodiraj
	je promeni
	incl %edi		#prelazi na sledeci znak izvornog
	incl %edx		#ciljni se menja uporedo sa izvornim
	jmp poredi

naredni:
	incl %esi		#prelazi na sledeci znak enkodiraj jer smo isproveravali sve izvorne
	movl 8(%ebp), %edi	#vraca izvorni i ciljni na pocetak
	movl 12(%ebp), %edx
	jmp poredi

promeni:
	incl %eax		#uvecava brojac koji ce nam posluziti kao izlazni kod
	movb (%edx), %cl	#menja znak iz enkodiraj u trenutni znak iz ciljnog
	movb %cl, (%esi)
	incl %esi
	movl 8(%ebp), %edi	#vraca izvorni i ciljni na pocetak
	movl 12(%ebp), %edx
	jmp poredi

kraj:
	#CDECL konvencija, vracamo stare vrednosti registara na stek
	#izmenjen string se nalazi u enkodiraj varijabli
	#izlazni kod se nalazi u %eax
	popl %ebx	
	popl %edi
	popl %esi
	movl %ebp, %esi
	popl %ebp 
	ret

#autor: Anja Dmitrović INDEX ra41-2019
.section .data
prompt1: .ascii "Unesite logicki izraz: \0"
prompt1_len = . - prompt1
prompt2: .ascii "Rezultat: \0"
prompt2_len= . - prompt2
err1: .ascii "Greska kod operanda.\n\0"
err1_len= . - err1
err2: .ascii "Greska kod operacije.\n\0"
err2_len= . - err2
newline: .ascii "\n\0"

operacija: .byte 0
greska: .byte 0


sistem_prvog: .ascii "d\0"
sistem_drugog: .ascii "d\0"

max=100

string: .fill max, 1,0
operand1: .fill 8,1,0		#izlazni se nalazi u operand1 a posle operacija on moze da ima 32 bita (u oktalnom je to 8 cifara)
operand2: .fill 4,1,0

znakokt: .fill 4,1,0


.section .text
.globl main
main:

	movl $4, %eax
	movl $1, %ebx
	movl $prompt1, %ecx
	movl $prompt1_len, %edx
	int $0x80

	movl $3, %eax
	movl $0, %ebx
	movl $string, %ecx
	movl $max, %edx
	int $0x80

	leal string, %esi	#stavljam adrese stringova u brojac registre
	leal operand1, %eax	
	leal operand2, %ebx	

	xorl %ecx, %ecx
	xorl %edx, %edx


###################################
	
prvi:
	cmpb $' ', (%esi)	#Ako smo dosli do praznog mesta proveravamo validnost drugog operanda
	je operacija_provera
	

	cmpb $'0', (%esi)	#ako operand pocinje sa 0x onda ga proveravamo heksadecimalno, ako nije onda decimalno
	jne decimalni_prvi
	incl %esi
	cmpb $'x', (%esi)	
	je heksa_prvi
	jne decimalni_prvi


drugi:				#ista procedura kao i za prvi operand
	incl %esi
	cmpb $' ', (%esi)	
	je operacija_provera


	cmpb $10, (%esi)		#dosli smo do kraja provere i krecemo u konverzije
	je priprema_konv2
	
	cmpb $'0', (%esi)
	jne decimalni_drugi
	incl %esi
	cmpb $'x', (%esi)
	je heksa_drugi
	jne decimalni_drugi


#################################
#OPERANDI SU DECIMALNI

	
decimalni_prvi:			#utvrdili smo da se prvi operand posmatra decimalno pa proveravamo da li je validan
	cmpl $10, (%esi)
	je drugi
	cmpl $'0', (%esi)
	jb greskaoperand
	cmpl $'9', (%esi)
	ja greskaoperand
	
	movb (%esi), %cl	#upisuje prvi znakovni decimalni u eax
	movb %cl, (%eax)
	
	incl %eax
	incl %esi
	jmp decimalni_prvi

decimalni_drugi:		#isto kao i za prvi
	cmpl $10, (%esi)
	je priprema_konv1
	cmpl $'0', (%esi)
	jb greskaoperand
	cmpl $'9', (%esi)
	ja greskaoperand
	
	movb (%esi), %cl
	movb %cl, (%ebx)
	
	incl %ebx
	incl %esi
	jmp decimalni_prvi

#######################################
#OPERANDI SU HEKSA

##############
heksa_prvi:			#utvrdili smo da se prvi operand posmatra heksadecimalno pa proveravamo validnost
	incl %esi
	cmpl $10, (%esi)
	je sigurno_heksa_prvi
	cmpl $'0', (%esi)
	jb greskaoperand
	cmpl $'9', (%esi)
	ja heksa1_prvi		#prelazimo na drugu heksa proveru od A do F
	
	movb (%esi), %cl
	movb %cl, (%eax)
	
	incl %eax
	incl %esi
	jmp heksa1_prvi

heksa_drugi:			
	cmpl $10, (%esi)
	je sigurno_heksa_drugi
	cmpl $'0', (%esi)
	jb greskaoperand
	cmpl $'9', (%esi)
	ja heksa1_drugi
	
	movb (%esi), %cl
	movb %cl, (%ebx)
	
	incl %ebx
	incl %esi
	jmp heksa1_drugi
#############

heksa1_prvi:
	cmpl $'A', (%esi)
	jb greskaoperand
	cmpl $'F', (%esi)
	ja heksa2_prvi		#prelazimo na trecu heksa proveru a-f

	movb (%esi), %cl
	movb %cl, (%eax)
	
	incl %eax
	incl %esi
	jmp heksa_prvi

heksa1_drugi:
	cmpl $'A', (%esi)
	jb greskaoperand
	cmpl $'F', (%esi)
	ja heksa2_drugi

	movb (%esi), %cl
	movb %cl, (%ebx)
	
	incl %ebx
	incl %esi
	jmp heksa_drugi

################

heksa2_prvi:			#poslednja heksa provera za prvi
	cmpl $'a', (%esi)
	jb greskaoperand
	cmpl $'f', (%esi)
	ja greskaoperand

	movb (%esi), %cl	#ako je znak validan upisujemo ga
	movb %cl, (%eax)
	
	incl %eax
	incl %esi
	jmp heksa_prvi

heksa2_drugi:
	cmpl $'a', (%esi)
	jb greskaoperand
	cmpl $'f', (%esi)
	ja greskaoperand

	movb (%esi), %cl
	movb %cl, (%ebx)
	
	incl %ebx
	incl %esi
	jmp heksa_drugi

#############

sigurno_heksa_prvi:		#Utvrdili smo da prvi operand posmatramo kao heksadecimalni i zabelezavamo to zbog konverzija
	movb $'x', sistem_prvog
	jmp prvi

sigurno_heksa_drugi:		#Isto kao i za prvi 
	movb $'x', sistem_drugog
	jmp priprema_konv1

##################################
#PROVERA OPERACIJE

operacija_provera:		#proveravamo da li je operacija validna
	xorl %edx, %edx
	incl %esi
	movb (%esi), %dl
	movb %dl, operacija

	incl %esi
	
	cmpl $'<', operacija
	je drugi
	cmpl $'>', operacija
	je drugi
	cmpl $'^', operacija
	jne greskaoperacija

###################################
#KONVERZIJA PRVOG OPERANDA


priprema_konv1:			#gledamo da li se prvi operand posmatra kao decimalni ili heksa
	cmpb $'d', sistem_prvog
	je konv_1d
	jne konv_1x


#########
#KONVERZIJA DECI PRVOG
konv_1d:			#pripremamo registre za konverziju znakovnog prvog u decimalni prvi koji ce se naci u eax
	leal operand1, %esi
	xorl %ebx, %ebx
	movl $10, %ecx		#baza nam je decimalna
	xorl %eax, %eax


petlja_konv_1d:			#petlja za konverziju
	movb (%esi), %bl
	cmpb $0x00, %bl
	je priprema_konv2	#ako smo stigli do kraja znakovnog operanda idemo na drugu konverziju
	subb $'0', %bl
	mull %ecx
	addl %ebx, %ebx		
	incl %esi
	jmp petlja_konv_1d
###########
#KONVERZIJA HEXA PRVOG

konv_1x:			#priprema za konverziju prvog operanda u heksa
	leal operand1, %esi
	xorl %eax, %eax
	xorl %ebx, %ebx
	movl $16, %ecx

petlja1_konv_1x:		#petlja za konverziju u heksa, ima ih ukupno 3 zbog 3 intervala (0-9; a-f; A-F)
	movb (%esi), %bl
	cmpb $0x00, %bl
	je priprema_konv2
	cmpb $'1', (%esi)
	jb petlja2_konv_1x
	cmpb $'9', (%esi)
	ja petlja2_konv_1x
	mull %ecx
	subb $'0', %bl	
	addl %ebx, %eax
	incl %esi
	cmpb $' ', (%esi)
	jne petlja1_konv_1x

petlja2_konv_1x:			
	movb (%esi), %bl
	mull %ecx
	subb $87, %bl	
	addl %ebx, %eax
	incl %esi
	cmpb $' ', (%esi)
	jne priprema_konv2
	xorl %ebx, %ebx
	movl $16, %ecx

petlja3_konv_1x:
	movb (%esi), %bl
	mull %ecx
	subb $87, %bl	
	addl %ebx, %eax
	incl %esi
	cmpb $' ', (%esi)
	jne petlja1_konv_1x


###################################
#KONVERZIJA DRUGOG OPERANDA


priprema_konv2:		#spremi registre za drugu konv
	movl %eax, operand1
	leal operand2, %esi

	xorl %eax, %eax

	cmpl $'d', sistem_drugog
	je konv_2d
	jne konv_2x
##########
#KONVERZIJA DECI DRUGOG
konv_2d:		#konvertuj drugi u decimalni
	xorl %ebx, %ebx
	movl $10, %ecx
	xorl %eax, %eax


petlja_konv_2d:
	movb (%esi), %bl
	cmpb $0x00, %bl
	je provera
	subb $'0', %bl
	mull %ecx
	addl %ebx, %ebx		
	incl %esi
	jmp petlja_konv_2d
############
#KONVERZIJA HEXA DRUGOG

konv_2x:		#konvertuj drugi u heksa
	leal operand2, %esi
	xorl %eax, %eax
	xorl %ebx, %ebx
	movl $16, %ecx

petlja1_konv_2x:		#petlja za konverziju u heksa, ima ih ukupno 3 zbog 3 intervala (0-9; a-f; A-F)
	movb (%esi), %bl
	cmpb $0x00, %bl
	je provera
	cmpb $'1', (%esi)
	jb petlja2_konv_1x
	cmpb $'9', (%esi)
	ja petlja2_konv_1x
	mull %ecx
	subb $'0', %bl	
	addl %ebx, %eax
	incl %esi
	cmpb $' ', (%esi)
	jne petlja1_konv_1x

petlja2_konv_2x:
	movb (%esi), %bl
	cmpb $'F', (%esi)
	ja petlja3_konv_1x
	mull %ecx
	subb $55, %bl	
	addl %ebx, %eax
	incl %esi
	cmpb $' ', (%esi)
	jne provera

petlja3_konv_2x:
	movb (%esi), %bl
	mull %ecx
	subb $87, %bl	
	addl %ebx, %eax
	incl %esi
	cmpb $' ', (%esi)
	jne petlja1_konv_2x

################################
#PROVERA OPERANDA

provera:			#proveri da li su operandi izasli iz opsega 8 bita
	movl %eax, operand2

	cmpl $255, operand1
	jg greskaoperand

	cmpl $255, operand2
	jg greskaoperand



################################
#OPERACIJE

izvrsi_op:

	movl operand1, %eax
	movl operand2, %ebx

	cmpl $'<', operacija
	je roluj
	cmpl $'>', operacija
	je roruj
	
xoruj:
	xorl %ebx, %eax
	movl %eax, operand1
	incl %esi
	jmp drugi
	
roluj:
	movb operand2, %cl
	roll %cl, operand1
	xorl %ecx, %ecx
	incl %esi
	jmp drugi

roruj:
	movb operand2, %cl
	rorl %cl, operand2
	xorl %ecx, %ecx
	incl %esi
	jmp drugi

##########################################
#OKTALNA KONVERZIJA KRAJNJA

oktalna_konv:			#rezultat koji se nalazi u eax konvertujemo u oktalni znakovni
	movl operand1, %eax
	leal operand1, %edi
	movl $8, %ebx

okt_petlja:			#petlja u oktalni znakovni
	xorl %edx, %edx
	divl %ebx
	addb $'0', %dl
	movb %dl, (%edi)
	incl %edi
	andl %eax, %eax
	jnz okt_petlja
	movb $0, (%edi)
	decl %edi
	leal znakokt, %esi
	xorl %eax, %eax

obrniokt:			#string je napisan naopako pa ga moramo okrenuti
	cmpl %edi, %esi
	jae ispispravi
	movb (%esi), %ah
	movb (%edi), %al
	movb %al, (%esi)
	movb %ah, (%edi)
	decl %edi
	incl %esi
	jmp obrniokt
#######################################
#ISPISI	

ispispravi:
	movl $4, %eax
	movl $1, %ebx
	movl $znakokt, %ecx
	movl $4, %edx
	int $0x80

	jmp kraj

greskaoperand:
	movl $4, %eax
	movl $1, %ebx
	movl $err1, %ecx
	movl $err1_len, %edx
	int $0x80

	movb $1, greska

	jmp kraj

greskaoperacija:
	movl $4, %eax
	movl $1, %ebx
	movl $err2, %ecx
	movl $err2_len, %edx
	int $0x80

	movb $1, greska

	jmp kraj

kraj:
	movl $1, %eax
	movl greska, %ebx
	int $0x80
########################################################3

	
	

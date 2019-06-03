
;;Macros to add/mul/div/sub floats using s[0] and s[1]. Puts the answer in [ans].
%macro mulFloats 2
	fld %1
	fld %2
	fmulp
	fstp qword [ans]
	%endmacro

%macro divFloats 2
	fld %1
	fld %2
	fdivp
	fstp qword [ans]
%endmacro

%macro subFloats 2
	fld %1
	fld %2
	fsubp
	fstp qword [ans]
%endmacro

%macro addFloats 2
	fld %1
	fld %2
	faddp
	fstp qword [ans]
%endmacro

;;Macro to add two complex numbers. Put the ans in [ansReal],[ansIm].
%macro addIm 4
	mov qword[ansReal], 0 			 ;Reset variables.
	mov qword[ansIm], 0
	addFloats %1,%3
	movsd xmm7,qword[ans]
	movsd [ansReal], xmm7
	addFloats %2,%4
	movsd xmm7,qword[ans]
	movsd qword[ansIm], xmm7

%endmacro

;;Macro to subtract two complex numbers. Put the ans in [ansReal],[ansIm].
%macro subIm 4
	mov qword[ansReal], 0 			 ;Reset variables.
	mov qword[ansIm], 0
	subFloats %1,%3
	movsd xmm7,qword[ans]
	movsd [ansReal], xmm7
	subFloats %2,%4
	movsd xmm7,qword[ans]
	movsd qword[ansIm], xmm7
%endmacro

;;Macro to multiply two complex numbers. Put the ans in [ansReal],[ansIm].
%macro mulIm 4
	mov qword[ansReal], 0 			 ;Reset variables.
	mov qword[ansIm], 0
	mulFloats %1,%3
	movsd xmm7,qword[ans]
	movsd [ansReal], xmm7
	mulFloats %2,%4
	subFloats qword[ansReal],qword[ans]
	movsd xmm7,qword[ans]
	movsd qword[ansReal], xmm7

	mulFloats %1,%4
	movsd xmm7,qword[ans]
	movsd qword[ansIm], xmm7
	mulFloats %2,%3
	addFloats qword[ansIm],qword[ans]
	movsd xmm7,qword[ans]
	movsd qword[ansIm], xmm7
%endmacro

	;;Macro to divide two complex numbers. Put the ans in [ansReal],[ansIm].
%macro divIm 4
	mov qword[ansReal], 0 			 ;Reset variables.
	mov qword[ansIm], 0
	mulFloats %1,%3							;ans= a*c
	movsd xmm7,qword[ans]					;xmm= a*c
	movsd qword[ansReal], xmm7				;ansReal= a*c
	mulFloats %2,%4							;ans=b*d
	addFloats qword[ansReal],qword[ans]		;ans=a*c+b*d
	movsd xmm7,qword[ans]					;xmm7= a*c+b*d
	movsd qword[ansReal],xmm7				;ansReal= a*c+b*d
	mulFloats %3,%3							;ans= c*c
	movsd xmm7,qword[ans]					;xmm7 = c*c
	movsd qword[temp],xmm7					;temp = c*c
	mulFloats %4,%4							;ans = d*d
	addFloats qword[temp],qword[ans]		;ans= c*c+d*d
	divFloats qword[ansReal],qword[ans]		;ans= (a*c+b*d)/(c*c+d*d)
	movsd xmm7,qword[ans]					;xmm7 = (a*c+b*d)/(c*c+d*d)
	movsd qword[ansReal], xmm7				;ansReal = (a*c+b*d)/(c*c+d*d)

	mulFloats %2,%3							;ans= b*c
	movsd xmm7,qword[ans]					;xmm7= b*c
	movsd qword[ansIm], xmm7				;ansIm = b*c
	mulFloats %1,%4							;ans = a*d
	subFloats qword[ansIm],qword[ans]		;ans= b*c-a*d
	movsd xmm7,qword[ans]					;xmm7 = b*c-a*d
	movsd qword[ansIm],xmm7					;ansIm = b*c-a*d
	mulFloats %3,%3							;ans= c*c
	movsd xmm7,qword[ans]					;xmm7 = c*c
	movsd qword[temp],xmm7					;temp = c*c
	mulFloats %4,%4							;ans = d*d
	addFloats qword[temp],qword[ans]		;ans= c*c+d*d
	divFloats qword[ansIm],qword[ans]		;ans= b*c-a*d / c*c+d*d
	movsd xmm7,qword[ans]					;xmm7= b*c-a*d / c*c+d*d
	movsd qword[ansIm], xmm7				;ansIm = b*c-a*d / c*c+d*d

%endmacro

;Macro to get the next iterator on a newton raphson iteration.
;After the macro. asnReal,ansIm should hold the answer.

%macro getNextNumber 0
	mov r12,qword[coefficantsArray]
	mov r13,qword[derCoefficantsArray]

	solvePolynom r12,qword[guessReal],qword[guessImaginary],r10
	movsd xmm2,qword[ansReal] 				;Put the real part of the solving into xmm2.
	movsd xmm3,qword[ansIm] 				;Put the imaginary part of the solving into xmm3.
	movsd qword[tempRealForNewton],xmm2		;and now move them to tempRealForNewton
	movsd qword[tempImForNewton],xmm3

	solvePolynom r13,qword[guessReal],qword[guessImaginary],r11
	movsd xmm4,qword[ansReal] 				;Put the real part of the solving into xmm4.
	movsd xmm5,qword[ansIm] 				;Put the imaginary part of the solving into xmm5.
	movsd qword[tempRealForNewton2],xmm4		;and now move them to tempRealForNewton
	movsd qword[tempImForNewton2],xmm5

	divIm qword[tempRealForNewton],qword[tempImForNewton],qword[tempRealForNewton2],qword[tempImForNewton2]
	movsd xmm2,qword[ansReal] 				;Put the real part of the div into xmm2.
	movsd xmm3,qword[ansIm] 				;Put the imaginary part of the div into xmm3.
	movsd qword[tempRealForNewton],xmm2		;and now move them to tempRealForNewton
	movsd qword[tempImForNewton],xmm3

	subIm qword[guessReal],qword[guessImaginary], qword[tempRealForNewton],qword[tempImForNewton]
	movsd xmm2,qword[ansReal] 				;Put the real part of the subtraction into xmm2.
	movsd xmm3,qword[ansIm] 				;Put the imaginary part of the subtraction into xmm3.
	movsd qword[guessReal],xmm2				;and now move them to guessReal and guessImaginary
	movsd qword[guessImaginary],xmm3


%endmacro



;Macro to derive a polynom. Address#1,address#2,int order
;After the macro, address#2 should hold the derived coefficants array.

%macro derivePolynom 3
	mov r13,%1 															;r13=Address of the polynom to be derives
	mov r14,%2															;r14=address of the derivative.
	mov r15,%3															;r15= order
	
	cmp r15,0
	JE %%caseOrder0Derive

	%%deriveLoop:
		mov dword[tempInt],r15d
		cvtsi2sd xmm6,dword[tempInt]									;xmm6=order converted to double.
		movsd qword[temp],xmm6											;put the order real part into temp.
		mulIm qword[r13],qword[r13+8],qword[temp],qword[zeroDouble] 	;multiply the coefficnats with thier order.		
		
		movsd xmm7,qword[ansReal] 										;Put the real part of the multiplication into xmm7.
		movsd qword[r14],xmm7											;and then assign it to r14.
		movsd xmm7,qword[ansIm] 										;Put the imaginary part of the multiplication into xmm7.
		movsd qword[r14+8],xmm7											;and then assign it to accIm.		

		add r14,16
		add r13,16
		dec r15
		cmp r15,0
		JNE %%deriveLoop
	JMP %%deriveEndLabel

	%%caseOrder0Derive:
	movsd xmm7,qword[zeroDouble] 										;Put the 0.0 value into xmm7.
	movsd qword[r14],xmm7												;and then assign it to r14Real.
	movsd qword[r14+8],xmm7	

	%%deriveEndLabel:
%endmacro

;Macro to solve a polynom, address,numberReal,numberIm,order -> accReal hold
; the real part. accIm holds the imaginary part. uses r14,r15.

%macro solvePolynom 4 	; (Address, zReal,zIm,Order) => solved polynom in ,.
	
	mov qword[accReal], 0 			 ;Reset variables.
	mov qword[accIm], 0	 
	mov r15,%4									 ;r15 = order
	mov r14,%1 									 ;r14 = Polynom address

	cmp r15,0									 ;Check if the order is 0.
	JE %%endLabelForCaseOrder0					 ;If so jump to the endLabelForCaseOrder0.
	%%solvePolynomLoop:


		addIm qword[accReal],qword[accIm],qword[r14],qword[r14+8]	;Add the accumlators to the new coefficant.
		
		movsd xmm7,qword[ansReal] 				;Put the real part of the addition into xmm7.
		movsd qword[accReal],xmm7				;and then assign it to accReal.
		movsd xmm7,qword[ansIm] 				;Put the imaginary part of the addition into xmm7.
		movsd qword[accIm],xmm7					;and then assign it to accIm.

		mulIm qword[accReal],qword[accIm],%2,%3 ;Multiply the accumlated values by Zreal,Zim.
		movsd xmm7,qword[ansReal] 				;Put the real part of the addition into xmm7.
		movsd qword[accReal],xmm7				;and then assign it to accReal.
		movsd xmm7,qword[ansIm] 				;Put the imaginary part of the addition into xmm7.
		movsd qword[accIm],xmm7					;and then assign it to accIm.


		add r14,16			;Advance the pointer the the next coeff.
		dec r15             ;Advance the loop.
    	cmp r15,0           ;Compare to 0.
    	JNE %%solvePolynomLoop     ;Jump if not yet 0. 

	%%endLabelForCaseOrder0:

	addIm qword[accReal],qword[accIm],qword[r14],qword[r14+8]	;
	movsd xmm7,qword[ansReal] 				;Put the real part of the addition into xmm7.
	movsd qword[accReal],xmm7				;and then assign it to accReal.
	movsd xmm7,qword[ansIm] 				;Put the imaginary part of the addition into xmm7.
	movsd qword[accIm],xmm7					;and then assign it to accIm.
		
%endmacro

%macro getInput 0
	mov r14d,16
	mov rdi, epsilonString
	mov rsi, epsilon
	mov rax, 0
	call scanf
	
	mov rdi, orderString
	mov rsi, order
	mov rax, 0
	call scanf

	mov r10d,dword[order]
	mov r11d,dword[order]
	sub r11d,1
	mov r15d,dword[order]

	mov rax,r10
	inc rax
	mul r14d
	mov rdi,rax

	call malloc
	mov qword[coefficantsArray],rax

	mov r14d,16						;reassign registers instead of push and pop.
	mov r10d,dword[order]
	mov r11d,dword[order]
	sub r11d,1
	mov r15d,dword[order]

	mov rax,r11
	inc rax
	mul r14d
	mov rdi,rax

	call malloc
	mov qword[derCoefficantsArray],rax

	mov r14d,16						;reassign registers instead of push and pop.
	mov r10d,dword[order]
	mov r11d,dword[order]
	sub r11d,1
	mov r15d,dword[order]



	%%coefficantsLoop:

	push r15 							;push the loop counter

	mov rdi, coeffString
	mov rsi, tempInt
	mov rdx, guessReal
	mov rcx, guessImaginary
	mov rax, 0
	call scanf


	pop r15 							;pop the loop counter.

	mov r14d,16						;reassign registers instead of push and pop.
	mov r10d,dword[order]
	mov r11d,dword[order]
	sub r11d,1
	mov dword[deriveOrder],r11d

	mov r9,qword[coefficantsArray]		;Set r9 to the start of the coefficantsArray
	mov r12,r10							;r12=order
	mov r8d,dword[tempInt]				;r8=current coefficant order
	sub r12,r8							;r12= order-current {if n=3 current =1 r12 =2}
	
	mov rax,r12							;eax= r12 {2}
	mul r14d							;eax= eax*16 {32}
	add r9,rax							;r9= r9+eax {32, which is 2 numbers past 3 which is 1.}
	
	movsd xmm7,qword[guessReal]
	movsd qword[r9],xmm7				;put the coefficants into place.
	movsd xmm7,qword[guessImaginary]
	movsd qword[r9+8],xmm7

	dec r15
	cmp r15,0							;Compare the loop counter to 0
	JGE %%coefficantsLoop				;If there hasn't been order+1 steps repeat.

	mov rdi, initialString
	mov rsi, guessReal
	mov rdx, guessImaginary
	mov rax, 0
	call scanf

	mov r14d,16						;reassign registers instead of push and pop.
	mov r10d,dword[order]
	mov r11d,dword[order]
	sub r11d,1
	mov r15d,dword[order]

	mov r10d,dword[order]
	mov r11d,dword[deriveOrder]

	derivePolynom qword[coefficantsArray],qword[derCoefficantsArray],r10

	mov r10d,dword[order]
	mov r11d,dword[deriveOrder]


%endmacro


%macro getDistance 2
	mulFloats %1,%1
	movsd xmm7, qword[ans]
	mulFloats %2,%2
	movsd qword[tempForDistance],xmm7
	addFloats qword[tempForDistance],qword[ans]
	fld qword[ans]
	fsqrt
	fstp qword [ans]
%endmacro

section .data

epsilonString: DB "epsilon = %lf",10,0 			;A \n null terminated string formatted for scanf to get the epsilon.
orderString: DB "order = %d",10,0				;A \n null terminated string formatted for scanf to get the order.
coeffString: DB "coeff %d = %lf %lf",10,0		;A \n null terminated string formatted for scanf to get the coefficants.
initialString: DB "initial = %lf %lf",10,0		;A \n null terminated string formatted for scanf to get the initial guess.
resultPrintString: DB "root = %.17lf %.17lf",10,0 			;A \n null terminated string formatted for scanf to get the epsilon.
result2PrintString: DB "The coefficant is %lf + %lf",10,0 			;A \n null terminated string formatted for scanf to get the epsilon.
zeroDouble: DQ 0.0

section .bss
	order: resb 4		;;Gonna be held at r10
	deriveOrder: resb 4			;;Gonna be held at r11.
	epsilon: resb 8
	tempInt: resb 4
	coefficantsArray: resb 8
	derCoefficantsArray: resb 8
	guessReal: resb 8
	guessImaginary: resb 8
	ans: resb 8
	ansReal: resb 8
	ansIm: resb 8
	accReal: resb 8
	accIm: resb 8
	temp: resb 8
	tempRealForNewton: resb 8
	tempImForNewton: resb 8
	tempRealForNewton2: resb 8
	tempImForNewton2: resb 8
	tempForDistance: resb 8

section .text
	extern exit
	extern scanf
	extern printf
	extern malloc
	extern free
	global main

main:
	finit

	getInput

	mainloop:

		getNextNumber

		push r8
		push r9
		push r10
		push r11
		push r12
		push r13
		push r14
		push r15

		mov r12,qword[coefficantsArray]
		solvePolynom r12,qword[guessReal],qword[guessImaginary],r10
		getDistance qword[ansReal],qword[ansIm]
		
		pop r15
		pop r14
		pop r13
		pop r12
		pop r11
		pop r10
		pop r9
		pop r8

		fld qword[ans]
		fld qword[epsilon]
		fcomip st1
		fstp
		ja endLabel
		jmp mainloop

	endLabel:

	push rax
 	mov rax,2
 	mov rdi,resultPrintString
 	movsd xmm0,qword[guessReal]
 	movsd xmm1,qword[guessImaginary]
 	call printf

 	mov rax,0
 	mov rdi,qword[coefficantsArray]
 	call free

 	mov rax,0
 	mov rdi,qword[derCoefficantsArray]
 	call free

 	mov rax,0
 	mov rdi,0
 	call exit
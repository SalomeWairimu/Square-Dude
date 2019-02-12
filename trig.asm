; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2 -> 0001921F
PI =  205887	                ;;  PI -> 0003243F
TWO_PI	= 411774                ;;  2 * PI ->0006487E
PI_INC_RECIP =  5340353        	;;  00517CC1 Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)


	;; If you need to, you can place global variables here
	
.CODE

FixedSin PROC USES edx ebx angle:FXPT
	local is_negative_sin:DWORD
	mov is_negative_sin, 0
	mov eax, angle
	cmp eax, 0
	jl make_angle_positive
	jmp make_angle_less_than_twoPI

make_angle_positive:
	cmp eax, 0
	jge make_less_than_pi
	add eax, TWO_PI
	jmp make_angle_positive

make_angle_less_than_twoPI:
	cmp eax, TWO_PI
	jl make_less_than_pi
	sub eax, TWO_PI
	jmp make_angle_less_than_twoPI

make_less_than_pi:
	cmp eax, PI
	jge reduce_by_pi
	jmp compare_pi_half

reduce_by_pi:
	sub eax, PI
	mov is_negative_sin, 1

compare_pi_half:
	cmp eax, PI_HALF
	jg pi_less_angle
	jmp get_sin

pi_less_angle:
	mov ebx, PI
	sub ebx, eax
	mov eax, ebx

get_sin:
	cmp eax, PI_HALF
	je special_case
	mov edx, PI_INC_RECIP
	imul edx
	movzx eax, WORD PTR[SINTAB+edx*2]
	jmp negative_sin

special_case:
	mov eax, 1
	shl eax, 16

negative_sin:
	cmp is_negative_sin, 0
	je exit
	neg eax
exit:
	ret			; Don't delete this line!!!
FixedSin ENDP 
	
FixedCos PROC USES edx angle:FXPT
	mov edx, angle
	add edx, PI_HALF
	invoke FixedSin, edx
	ret			; Don't delete this line!!!	
FixedCos ENDP	
END

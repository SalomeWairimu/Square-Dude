; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here
	
.CODE
	

;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved
	
;;   For example, if your procedure uses only the eax and ebx registers
;;      DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
DrawLine PROC USES ebx ecx edi esi edx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	;; Feel free to use local variables...declare them here
	;; For example:
	LOCAL delta_x:SDWORD, delta_y:SDWORD, inc_x:SDWORD,inc_y:SDWORD, error:SDWORD, two:SDWORD
	;; Place your code here
	
initialize:
	mov ebx, x1
	mov ecx, y1
	sub ebx, x0
	sub ecx, y0
	mov delta_x, ebx
	mov delta_y, ecx
	mov inc_x, 1
	mov inc_y, 1
	mov error, 0
	mov edi, x0
	mov esi, y0
	mov two, 2
	mov edx, 0
    jmp make_absolute_dx
	
make_absolute_dx:
	cmp delta_x, 0
	jge make_absolute_dy
	neg delta_x
	neg inc_x
      jmp make_absolute_dy

make_absolute_dy:
	cmp delta_y, 0
	jge set_error_dx
	neg delta_y
	neg inc_y
      jmp set_error_dx
set_error_dx:
	mov ebx, delta_x
	mov ecx, delta_y
	cmp ebx, ecx
	jle set_error_dy
	mov eax, ebx
	idiv two
	mov error, eax
	jmp while_condition
set_error_dy:
	mov eax, ecx
	idiv two
	neg eax
	mov error, eax
	jmp while_condition
while_loop:
	invoke DrawPixel, edi,esi,color
	mov eax, error
	mov edx, ebx
	neg edx
	cmp eax, edx
	jle section_2
	sub error, ecx
	add edi, inc_x
	jmp section_2
section_2:
	cmp eax, ecx
	jge while_condition
	add error, ebx
	add esi, inc_y
      jmp while_condition
while_condition:
	cmp edi, x1
	jne while_loop
	cmp esi, y1
	jne while_loop
	ret        	;;  Don't delete this line...you need it
DrawLine ENDP




END

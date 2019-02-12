; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc


.DATA

	;; If you need to, you can place global variables here
	
.CODE

DrawPixel PROC USES ebx edx x:DWORD, y:DWORD, color:DWORD
	cmp x, 640
	jge exit
	cmp x, 0
	jl exit
	cmp y, 480
	jge exit
	cmp y, 0
	jl exit
	mov eax, y
	mov edx, 640
	mul edx
	add eax, x
	add eax, ScreenBitsPtr
	mov ebx, color
	mov BYTE PTR[eax], bl
exit:
	ret 			; Don't delete this line!!!
DrawPixel ENDP

BasicBlit PROC USES ebx ecx edx esi edi ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
	
	LOCAL curr_x:DWORD, mapwidth:DWORD, end_x:DWORD, curr_y:DWORD, end_y:DWORD, index:DWORD, transparent:BYTE

set_variables:
	mov index, 0										; used to index bitmap
	mov eax, ptrBitmap									;;address of bitmap
	xor ebx, ebx
	mov bl, (EECS205BITMAP PTR[eax]).bTransparent		;; transparent color
	mov transparent, bl
	mov esi, (EECS205BITMAP PTR[eax]).dwWidth			;;width of bitmap
	mov mapwidth, esi									;;width of bitmap
	sar esi, 1											;;divide width by 2
	mov edi, xcenter
	mov curr_x, edi
	mov end_x, edi
	sub curr_x, esi										;;set left most point
	add end_x, esi										;;set right most point
	mov esi, (EECS205BITMAP PTR[eax]).dwHeight			;;height of bitmap
	sar esi, 1											;;divide height by 2
	mov edi, ycenter
	mov curr_y, edi
	mov end_y, edi
	sub curr_y, esi										;;set top most point
	add end_y, esi										;;set bottom most point
	mov edi, (EECS205BITMAP PTR[eax]).lpBytes			;; start of colors


inner_loop:
	mov ecx, end_x
	cmp curr_x, ecx										;; check for x bounds
	jge outer_loop										;; inc y if at right most point
	mov edx, index
	xor ecx, ecx
	mov cl, BYTE PTR[edi+edx]							;; get color
	cmp cl, bl											;; confirm it is not transparent
	je inc_var
	invoke DrawPixel, curr_x, curr_y, [edi+edx]			;; draw pixel

inc_var:
	inc curr_x											;; inc x value
	inc index											;; inc bitmap index
	jmp inner_loop

outer_loop:
	inc curr_y	
	mov ecx, curr_y
	cmp ecx, end_y										;; check for y bounds
	je exit												;; exit if done drawing pixels
	mov ecx, mapwidth
	sub curr_x, ecx										;; reset x to the left most point
	jmp inner_loop

exit:
	ret 			; Don't delete this line!!!	
BasicBlit ENDP


RotateBlit PROC lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT

	ret 			; Don't delete this line!!!		
RotateBlit ENDP



END

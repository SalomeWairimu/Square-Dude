; #########################################################################
;
;   game.asm - Assembly file for;
;	EECS205 Assignment 4/5
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
include game.inc

;; Has keycodes
include keys.inc

include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib
	
.DATA

GAMEOBJECT STRUCT
	posX DWORD ?
	posY DWORD ?
	direction DWORD ?
	velocity DWORD ?
	acceleration DWORD ?
	angle DWORD ?
	alive DWORD ?
	bmap DWORD ?
GAMEOBJECT ENDS

food GAMEOBJECT<100, 150, 0, 0, 0, 0, 0, OFFSET jelly>
player GAMEOBJECT<70, 80, 0, 0, 0, 0, 1, OFFSET minion>
enemy GAMEOBJECT<400, 250, 0, 0, 0, 0, 1, OFFSET dragon>
rock GAMEOBJECT<250, 250, 0, 0, 0, 102943, 0, OFFSET asteroid_000>


.CODE
CheckIntersect PROC USES ebx ecx edx oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
	xor eax, eax

check_top:											;; check if the top of one intersects with the bottom of two
	mov edx, oneY									;; edx contains y center of one
	mov ebx, oneBitmap
	mov ecx, (EECS205BITMAP PTR[ebx]).dwHeight		;; ecx contains height of one
	sar ecx, 1
	sub edx, ecx									;; edx contains top of one

	mov eax, twoY									;; eax contains y center of two
	mov ebx, twoBitmap
	mov ecx, (EECS205BITMAP PTR[ebx]).dwHeight		;; ecx contains height of two
	sar ecx, 1
	add eax, ecx									;; eax contains bottom of two

	cmp edx, eax									;; compare top of one and bottom of two
	jg okay											;; not intersecting if top of one is greater than the bottom of two

check_bottom:										;; check if the bottom of one intersects with the top of two
	mov edx, oneY									;; edx contains y center of one
	mov ebx, oneBitmap
	mov ecx, (EECS205BITMAP PTR[ebx]).dwHeight		;; ecx contains height of one
	sar ecx, 1
	add edx, ecx									;; edx contains bottom of one

	mov eax, twoY									;; eax contains y center of two
	mov ebx, twoBitmap
	mov ecx, (EECS205BITMAP PTR[ebx]).dwHeight		;; ecx contains height of two
	sar ecx, 1
	sub eax, ecx									;; eax contains top of two
	
	cmp edx, eax									;; compare top of two and bottom of one
	jl okay											;; not intersecting if bottom of one is lesser than top of two

check_right:										;; check if the right of one intersects with the left of two
	mov edx, oneX									;; edx contains x center of one
	mov ebx, oneBitmap
	mov ecx, (EECS205BITMAP PTR[ebx]).dwWidth		;; ecx contains width of one
	sar ecx, 1
	add edx, ecx									;; edx contains right of one

	mov eax, twoX									;; eax contains x center of two
	mov ebx, twoBitmap
	mov ecx, (EECS205BITMAP PTR[ebx]).dwWidth		;; ecx contains width of two
	sar ecx, 1
	sub eax, ecx									;; eax contains left of two
	
	cmp edx, eax									;; compare right of one and left of two
	jl okay											;; not intersecting if right of one is lesser than the left of two

check_left:											;; check if the left of one intersects with the right of two
	mov edx, oneX									;; edx contains x center of one
	mov ebx, oneBitmap
	mov ecx, (EECS205BITMAP PTR[ebx]).dwWidth		;; ecx contains width of one
	sar ecx, 1
	sub edx, ecx									;; edx contains left of one

	mov eax, twoX									;; eax contains x center of two
	mov ebx, twoBitmap
	mov ecx, (EECS205BITMAP PTR[ebx]).dwWidth		;; ecx contains width of two
	sar ecx, 1
	add eax, ecx									;; eax contains right of two
	
	cmp edx, eax									;; compare left of one and right of two
	jg okay											;; not intersecting if left of one is greater than the right of two

intersecting:
	mov eax, 1
	jmp exit
	
okay:
	mov eax, 0

exit:
	ret												;; Do not delete this line!!!
CheckIntersect ENDP


UserInput PROC USES ebx ecx
keyboard:
	mov ecx, OFFSET player
	mov ebx, KeyPress
	cmp ebx, VK_UP
	je up
	cmp ebx, VK_DOWN
	je down
	cmp ebx, VK_LEFT
	je left
	cmp ebx, VK_RIGHT
	je right
	jmp exit
up:
	sub (GAMEOBJECT PTR[ecx]).posY, 5
	jmp exit
down:
	add (GAMEOBJECT PTR[ecx]).posY, 5
	jmp exit
left:
	sub (GAMEOBJECT PTR[ecx]).posX, 5
	jmp exit
right:
	add (GAMEOBJECT PTR[ecx]).posX, 5
exit:
	ret												;; Do not delete this line!!!
UserInput ENDP


CreateFood PROC
	invoke nrandom, 400
	ret
CreateFood ENDP


ClearScreen PROC USES ebx
	mov ebx, ScreenBitsPtr
	mov eax, 0
	jmp cond
mainloop:
	mov (BYTE PTR[ebx]), 000h
	inc ebx
	inc eax
cond:
	cmp eax, 307200
	jl mainloop
exit:
	ret
ClearScreen ENDP


GameInit PROC uses ebx ecx edx
	invoke DrawStarField
	lea ebx, player
	invoke BasicBlit, OFFSET minion, (GAMEOBJECT PTR[ebx]).posX, (GAMEOBJECT PTR[ebx]).posY
	;;lea ecx, enemy
	;;invoke BasicBlit, OFFSET dragon, (GAMEOBJECT PTR[ecx]).posX, (GAMEOBJECT PTR[ecx]).posY
	lea edx, food
	invoke BasicBlit, OFFSET jelly, (GAMEOBJECT PTR[edx]).posX, (GAMEOBJECT PTR[edx]).posY
	rdtsc
	invoke nseed, eax
	ret         ;; Do not delete this line!!!
GameInit ENDP


GamePlay PROC uses ebx ecx edx
	invoke ClearScreen
	invoke DrawStarField
	lea ebx, player
	invoke BasicBlit, OFFSET minion, (GAMEOBJECT PTR[ebx]).posX, (GAMEOBJECT PTR[ebx]).posY
	;;lea ecx, enemy
	;;invoke BasicBlit, OFFSET dragon, (GAMEOBJECT PTR[ecx]).posX, (GAMEOBJECT PTR[ecx]).posY
	lea edx, food
	invoke BasicBlit, OFFSET jelly, (GAMEOBJECT PTR[edx]).posX, (GAMEOBJECT PTR[edx]).posY
	invoke UserInput

	
	ret         ;; Do not delete this line!!!
GamePlay ENDP

END

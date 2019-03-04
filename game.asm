; #########################################################################
;
;   game.asm - Assembly file for;
;	EECS205 Assignment 4/5
;	Salome Kariuki swk6525
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

	
.DATA

GAMEOBJECT STRUCT
	posX DWORD ?
	posY DWORD ?
	velx DWORD ?
	vely DWORD ?
	acceleration DWORD ?
	angle FXPT ?
	alive DWORD ?
	bmap DWORD ?
GAMEOBJECT ENDS

food GAMEOBJECT<100, 150, 0, 0, 0, 0, 0, patty>
player GAMEOBJECT<500, 80, 0, 0, 0, 0, 1, OFFSET spongebob>
enemy GAMEOBJECT<400, 250, 0, 0, 0, 0, 1, OFFSET plankton>
enemy2 GAMEOBJECT<500, 250, 0, 0, 0, 0, 1, OFFSET plankton>
shop GAMEOBJECT<240, 50, 0, 0, 0, 102943, 0, OFFSET krustykrab>
GameOverStr BYTE "Game Over", 0
PlayerScore DWORD 0
ShownScore BYTE "0000", 0

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

Playermove PROC USES ebx ecx
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
	sub (GAMEOBJECT PTR[ecx]).posY, 4
	jmp exit
down:
	add (GAMEOBJECT PTR[ecx]).posY, 4
	jmp exit
left:
	sub (GAMEOBJECT PTR[ecx]).posX, 4
	jmp exit
right:
	add (GAMEOBJECT PTR[ecx]).posX, 4
exit:
	ret												;; Do not delete this line!!!
Playermove ENDP
	
Enemymove PROC USES ebx ecx edx esi edi
	LOCAL playerX: DWORD, playerY: DWORD, enemyX: DWORD, enemyY: DWORD
	lea ebx, player
	lea ecx, enemy
	xor esi, esi
	xor edi, edi
set_x:
	mov edx, (GAMEOBJECT PTR[ebx]).posX
	mov playerX, edx
	mov edx, (GAMEOBJECT PTR[ecx]).posX
	mov enemyX, edx
	cmp playerX, edx
	jl dec_x
inc_x:
	add (GAMEOBJECT PTR[ecx]).posX, 1
	mov esi, 1
	jmp set_y
dec_x:
	sub (GAMEOBJECT PTR[ecx]).posX, 1
set_y:
	mov edx, (GAMEOBJECT PTR[ebx]).posY
	mov playerY, edx
	mov edx, (GAMEOBJECT PTR[ecx]).posY
	mov enemyY, edx
	cmp playerY, edx
	jl dec_y
inc_y:
	add (GAMEOBJECT PTR[ecx]).posY, 1
	mov edi, 1
	jmp set_angle
dec_y:
	sub (GAMEOBJECT PTR[ecx]).posY, 1
set_angle:
	cmp esi, edi
	jl add_5pi_quarter
	cmp esi, edi
	jg add_pi_quarter
	cmp esi, 0
	je add_3pi_quarter

add_7pi_quarter:
	mov (GAMEOBJECT PTR[ecx]).angle, 51471
	jmp done
add_pi_quarter:
	mov (GAMEOBJECT PTR[ecx]).angle, 360297
	jmp done

add_5pi_quarter:
	mov (GAMEOBJECT PTR[ecx]).angle, 154413 
	jmp done
add_3pi_quarter:
	mov (GAMEOBJECT PTR[ecx]).angle, 257355

done:
	ret
Enemymove ENDP

ask_for_food PROC USES ebx edx ecx esi
	mov ebx, OFFSET MouseStatus
	mov edx, (MouseInfo PTR[ebx]).buttons
	mov eax, (MouseInfo PTR[ebx]).horiz
	mov esi, (MouseInfo PTR[ebx]).vert
	cmp edx, MK_LBUTTON
	jne done
	lea ecx, food
	mov (GAMEOBJECT PTR[ecx]).posX, eax
	mov (GAMEOBJECT PTR[ecx]).posY, esi

done:
	ret
ask_for_food ENDP


CreateFood PROC USES edx
	lea edx, food
	invoke BasicBlit, OFFSET patty, (GAMEOBJECT PTR[edx]).posX, (GAMEOBJECT PTR[edx]).posY
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
	lea ebx, player
	invoke BasicBlit, OFFSET spongebob, (GAMEOBJECT PTR[ebx]).posX, (GAMEOBJECT PTR[ebx]).posY
	lea ecx, enemy
	invoke BasicBlit, OFFSET plankton, (GAMEOBJECT PTR[ecx]).posX, (GAMEOBJECT PTR[ecx]).posY
	lea ebx, shop
	invoke BasicBlit, OFFSET krustykrab, (GAMEOBJECT PTR[ebx]).posX, (GAMEOBJECT PTR[ebx]).posY
	invoke CreateFood
	ret         ;; Do not delete this line!!!
GameInit ENDP


GamePlay PROC uses ebx ecx edx esi edi
	invoke ClearScreen
	invoke CreateFood
create_player:
	lea ebx, player
	invoke BasicBlit, OFFSET spongebob, (GAMEOBJECT PTR[ebx]).posX, (GAMEOBJECT PTR[ebx]).posY
create_enemy:
	lea ecx, enemy
	invoke RotateBlit, OFFSET plankton, (GAMEOBJECT PTR[ecx]).posX, (GAMEOBJECT PTR[ecx]).posY, (GAMEOBJECT PTR[ecx]).angle
	lea ecx, enemy2
	invoke RotateBlit, OFFSET plankton, (GAMEOBJECT PTR[ecx]).posX, (GAMEOBJECT PTR[ecx]).posY, (GAMEOBJECT PTR[ecx]).angle
create_shop:
	lea esi, shop
	invoke BasicBlit, OFFSET krustykrab, (GAMEOBJECT PTR[esi]).posX, (GAMEOBJECT PTR[esi]).posY
check:
	cmp (GAMEOBJECT PTR[ebx]).alive, 0
	je game_over

move:
	invoke Playermove
	invoke Enemymove
	invoke ask_for_food
eating:
	lea esi, food
	invoke CheckIntersect, (GAMEOBJECT PTR[ebx]).posX, (GAMEOBJECT PTR[ebx]).posY, OFFSET spongebob, (GAMEOBJECT PTR[esi]).posX, (GAMEOBJECT PTR[esi]).posY, OFFSET patty
	cmp eax, 0
	je keep_playing
add_score:
	mov edx, offset PlayerScore
	add DWORD PTR [edx], 2
	add edx, 2
	mov edi, offset ShownScore
	add DWORD PTR [edi], 2
	invoke DrawStr, offset ShownScore, 20, 40, 0ffh

keep_playing:
	lea ecx, enemy
	invoke CheckIntersect, (GAMEOBJECT PTR[ebx]).posX, (GAMEOBJECT PTR[ebx]).posY, OFFSET spongebob, (GAMEOBJECT PTR[ecx]).posX, (GAMEOBJECT PTR[ecx]).posY, OFFSET plankton
	cmp eax, 0
	je done

game_over:
	mov (GAMEOBJECT PTR[ebx]).alive, 0
	invoke DrawStr, offset GameOverStr, 320, 240, 0ffh

done:
	ret         ;; Do not delete this line!!!
GamePlay ENDP

END

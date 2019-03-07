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
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib


	
.DATA

GAMEOBJECT STRUCT
	posX DWORD ?
	posY DWORD ?
	velX DWORD ?
	velY DWORD ?
	missiles DWORD ?
	angle FXPT ?
	lives DWORD ?
	score DWORD ?
	foodpoints DWORD ?
	bmap DWORD ?
GAMEOBJECT ENDS

food GAMEOBJECT<100, 150, 0, 0, 0, 0, 0, 0, 0, OFFSET patty>
player GAMEOBJECT<500, 80, 0, 0, 0, 0, 3, 0, 0, OFFSET spongebob>
enemies GAMEOBJECT 3 DUP <400, 250, 0, 0, 0, 0, 1, 0, 0, OFFSET plankton>
; enemy2 GAMEOBJECT<500, 250, 0, 0, 0, 0, 1, 0, 0, OFFSET plankton>
; enemy3 GAMEOBJECT<300, 250, 0, 0, 0, 0, 1, 0, 0, OFFSET plankton>
shop GAMEOBJECT<240, 50, 0, 0, 0, 0, 0, 0, 0, OFFSET krustykrab>
missile GAMEOBJECT<0, 0, 0, 0, 0, 0, 0, 0, 0, OFFSET missile>
GameOverStr BYTE "Game Over", 0
fmtScoreStr BYTE "Score: %d", 0
fmtFoodStr BYTE "Food Points: %d", 0
fmtLivesStr BYTE "Lives: %d", 0
fmtMissilesStr BYTE "Missiles: %d", 0
outScoreStr BYTE 40 DUP(0)
outFoodStr BYTE 40 DUP(0)
outLivesStr BYTE 40 DUP(0)
outMissilesStr BYTE 40 DUP(0)
SelectStr BYTE "Do you want to purchase 1 extra life or a gun? Press L for life and M for missile", 0
BrokeStr BYTE "You're broke, You need at least 10 patties to buy anything", 0

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


CheckBounds PROC USES ecx edx obj:DWORD newvelx:DWORD newvely:DWORD
	LOCAL xpos:DWORD, ypos:DWORD, xvel:DWORD, yvel:DWORD
	mov ecx, obj
	mov edx, (GAMEOBJECT PTR[ecx]).posX
	mov xpos, edx
	mov edx, (GAMEOBJECT PTR[ecx]).posY
	mov ypos, edx
	mov edx, (GAMEOBJECT PTR[ecx]).velX
	mov xvel, edx
	mov edx, (GAMEOBJECT PTR[ecx]).velY
	mov yvel, edx

check_x_dir:
	cmp xvel, 0
	jl check_left_wall
check_right_wall:
	cmp xpos, 590
	jl check_y_dir
	neg newvelx
	mov (GAMEOBJECT PTR[ecx]).velX, newvelx
	jmp check_y_dir
check_left_wall:
	cmp xpos, 50
	jg check_y_dir
	mov (GAMEOBJECT PTR[ecx]).velX, newvelx

check_y_dir:
	cmp yvel, 0
	jl check_north_wall
check_south_wall:
	cmp ypos, 420
	jl done
	neg newvely
	mov (GAMEOBJECT PTR[ecx]).velY, newvely
	jmp done
check_north_wall:
	cmp ypos, 60
	jg done
	mov (GAMEOBJECT PTR[ecx]).velY, newvely

done:
	ret
CheckBounds ENDP

;;;;;;;;;;;;;   SHOP FUNCTIONS

CreateShop PROC USES esi
	lea esi, shop
	invoke BasicBlit, (GAMEOBJECT PTR[esi]).bmap, (GAMEOBJECT PTR[esi]).posX, (GAMEOBJECT PTR[esi]).posY
	ret
CreateShop ENDP


Shopping PROC USES ebx esi
	lea ebx, player
	lea esi, shop
	invoke CheckIntersect, (GAMEOBJECT PTR[ebx]).posX, (GAMEOBJECT PTR[ebx]).posY, OFFSET spongebob, (GAMEOBJECT PTR[esi]).posX, (GAMEOBJECT PTR[esi]).posY, OFFSET krustykrab
	cmp eax, 0
	je done
	cmp (GAMEOBJECT PTR[ebx]).foodpoints, 10
	jl broke
shopnow:
	invoke DrawStr, offset SelectStr, 180, 200, 0ffh
	mov ecx, KeyPress
	cmp ecx, VK_L
	je buy_life
	cmp ecx, VK_M
	je buy_missile
	jmp done
buy_life:
	add (GAMEOBJECT PTR[ebx]).lives, 1
	sub (GAMEOBJECT PTR[ebx]).foodpoints, 10
	jmp done
buy_missile:
	add (GAMEOBJECT PTR[ebx]).missiles, 1
	sub (GAMEOBJECT PTR[ebx]).foodpoints, 10
	jmp done
broke:
	invoke DrawStr, offset BrokeStr, 180, 200, 0ffh
done:
	ret
Shopping ENDP


;;;;;;;;;;;;;   PLAYER FUNCTIONS
CreatePlayer PROC USES ebx
	lea ebx, player
	invoke BasicBlit, (GAMEOBJECT PTR[ebx]).bmap, (GAMEOBJECT PTR[ebx]).posX, (GAMEOBJECT PTR[ebx]).posY
	ret
CreatePlayer ENDP


UpdatePlayer PROC USES ebx ecx
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
	jmp done
up:
	mov (GAMEOBJECT PTR[ecx]).velY, -5
	jmp moveplayer
down:
	mov (GAMEOBJECT PTR[ecx]).velY, 5
	jmp moveplayer
left:
	mov (GAMEOBJECT PTR[ecx]).velX, -5
	jmp moveplayer
right:
	mov (GAMEOBJECT PTR[ecx]).velX, 5
moveplayer:
	invoke PlayerMove
done:
	ret												;; Do not delete this line!!!
UpdatePlayer ENDP


PlayerMove PROC USES ecx edx
	lea ecx, OFFSET player
	invoke CheckBounds, ecx, 0, 0
	mov edx, (GAMEOBJECT PTR[ecx]).velX
	add (GAMEOBJECT PTR[ecx]).posX, edx
	mov edx, (GAMEOBJECT PTR[ecx]).velY
	add (GAMEOBJECT PTR[ecx]).posY, edx
done:
	ret
PlayerMove ENDP



;;;;;;;;;;;;;   ENEMY FUNCTIONS 
CreateEnemies PROC USES ecx edi edx
	lea ecx, enemies
	mov edi, 0
	mov edx, TYPE enemies
mainloop:
	push ecx
	push edx
	push edi
	invoke nrandom, 590
	pop edi
	pop edx
	pop ecx
	add eax, 25
	mov (GAMEOBJECT PTR[ecx]).posX, eax
	push ecx
	push edx
	push edi
	invoke nrandom, 430
	pop edi
	pop edx
	pop ecx
	add eax, 25
	mov (GAMEOBJECT PTR[ecx]).posY, eax
	invoke BasicBlit, (GAMEOBJECT PTR[ecx]).bmap, (GAMEOBJECT PTR[ecx]).posX, (GAMEOBJECT PTR[ecx]).posY
inc_:
	inc edi
	add ecx, edx
cond:
	cmp edi, LENGTHOF enemies
	jl mainloop
done:
	ret
CreateEnemies ENDP


UpdateEnemies PROC USES ecx edi edx
	lea ecx, enemies
	mov edi, 0
	mov edx, TYPE enemies
mainloop:
	cmp (GAMEOBJECT PTR[ecx]).lives, 0
	je deadenemy
	invoke Enemymove, ecx
	jmp inc_
deadenemy:
	invoke DeadEnemymove, ecx
inc_:
	inc edi
	add ecx, edx
cond:
	cmp edi, LENGTHOF enemies
	jl mainloop
done:
	ret
UpdateEnemies ENDP


Enemymove PROC USES ecx edx obj:DWORD
	mov ecx, obj
	invoke CheckBounds, ecx, 1, 1
	mov edx, (GAMEOBJECT PTR[ecx]).velX
	add (GAMEOBJECT PTR[ecx]).posX, edx
	mov edx, (GAMEOBJECT PTR[ecx]).velY
	add (GAMEOBJECT PTR[ecx]).posY, edx
done:
	ret
Enemymove ENDP


DeadEnemymove PROC obj:DWORD
	mov ecx, obj
	cmp (GAMEOBJECT PTR[ecx]).posY, 420
	jge done
dec_y:
	sub (GAMEOBJECT PTR[ecx]).posY, 1
done:
	ret
DeadEnemymove ENDP


PlayerEnemyCollision PROC USES ecx ebx edx edi
	lea ebx, player
	lea ecx, enemies
	mov edi, 0
	mov edx, TYPE enemies
mainloop:
	invoke CheckIntersect, (GAMEOBJECT PTR[ebx]).posX, (GAMEOBJECT PTR[ebx]).posY, (GAMEOBJECT PTR[ebx]).bmap, (GAMEOBJECT PTR[ecx]).posX, (GAMEOBJECT PTR[ecx]).posY, (GAMEOBJECT PTR[ecx]).bmap
	cmp eax, 0
	jne reduce_lives
	jmp inc_
reduce_lives:
	sub (GAMEOBJECT PTR[ebx]).lives, 1
inc_:
	inc edi
	add ecx, edx
cond:
	cmp edi, LENGTHOF enemies
	jl mainloop
done:
	ret
PlayerEnemyCollision ENDP



;;;;;;;;;;;;;   MISSILE FUNCTIONS 
ShootMissile PROC
ShootMissile ENDP
MissileEnemyCollision PROC USES ecx ebx edx edi
	lea ebx, missile
	lea ecx, enemies
	mov edi, 0
	mov edx, TYPE enemies
mainloop:
	invoke CheckIntersect, (GAMEOBJECT PTR[ebx]).posX, (GAMEOBJECT PTR[ebx]).posY, (GAMEOBJECT PTR[ebx]).bmap, (GAMEOBJECT PTR[ecx]).posX, (GAMEOBJECT PTR[ecx]).posY, (GAMEOBJECT PTR[ecx]).bmap
	cmp eax, 0
	jne reduce_lives
	jmp inc_
reduce_lives:
	mov (GAMEOBJECT PTR[ecx]).bmap, OFFSET skeleton
	sub (GAMEOBJECT PTR[ecx]).lives, 1
inc_:
	inc edi
	add ecx, edx
cond:
	cmp edi, LENGTHOF enemies
	jl mainloop
done:
	ret
done:
	ret
MissileEnemyCollision ENDP

	; mov ebx, OFFSET MouseStatus
	; mov edx, (MouseInfo PTR[ebx]).buttons
	; mov eax, (MouseInfo PTR[ebx]).horiz
	; mov esi, (MouseInfo PTR[ebx]).vert
	; cmp edx, MK_LBUTTON
	

;;;;;;;;;;;;;   FOOD FUNCTIONS 
OrigFood PROC USES edx
	lea edx, food
	invoke BasicBlit, (GAMEOBJECT PTR[edx]).bmap, (GAMEOBJECT PTR[edx]).posX, (GAMEOBJECT PTR[edx]).posY
	ret
OrigFood ENDP


PlayerAte PROC USES ebx esi
	lea ebx, player
	lea esi, food
	invoke CheckIntersect, (GAMEOBJECT PTR[ebx]).posX, (GAMEOBJECT PTR[ebx]).posY, OFFSET spongebob, (GAMEOBJECT PTR[esi]).posX, (GAMEOBJECT PTR[esi]).posY, OFFSET patty
	cmp eax, 0
	je done
add_foodpoints:
	add (GAMEOBJECT PTR[ebx]).foodpoints, 1
createfood:
	invoke CreateFood
done:
	ret
PlayerAte ENDP


CreateFood PROC USES edx ecx
	lea edx, food
	push ecx
	push edx
	invoke nrandom, 590
	pop edx
	pop ecx
	add eax, 24
	mov (GAMEOBJECT PTR[edx]).posX, eax
	push ecx
	push edx
	invoke nrandom, 430
	pop edx
	pop ecx
	add eax, 20
	mov (GAMEOBJECT PTR[edx]).posY, eax
	ret
CreateFood ENDP



;;;;;;;;;;;;;   SCREEN FUNCTIONS 
StatusBoard PROC USES ebx
	lea ebx, player
score:
	push (GAMEOBJECT PTR[ebx]).score
	push offset fmtScoreStr
	push offset outScoreStr
	call wsprintf
	add esp, 12
	invoke DrawStr, offset outScoreStr, 300, 10, 0ffh
lives:
	push (GAMEOBJECT PTR[ebx]).lives
	push offset fmtLivesStr
	push offset outLivesStr
	call wsprintf
	add esp, 12
	invoke DrawStr, offset outLivesStr, 500, 10, 0ffh
foodpoints:
	push (GAMEOBJECT PTR[ebx]).foodpoints
	push offset fmtFoodStr
	push offset outFoodStr
	call wsprintf
	add esp, 12
	invoke DrawStr, offset outFoodStr, 10, 10, 0ffh
missiles:
	push (GAMEOBJECT PTR[ebx]).missiles
	push offset fmtMissilesStr
	push offset outMissilesStr
	call wsprintf
	add esp, 12
	invoke DrawStr, offset outMissilesStr, 30, 10, 0ffh
done:
	ret
StatusBoard ENDP


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



;;;;;;;;;;;;;   MAIN FUNCTIONS 
GameInit PROC
	invoke OrigFood
	invoke CreateShop
	invoke CreatePlayer
	invoke CreateEnemies
	invoke StatusBoard
	rdtsc
	invoke nseed, eax
	ret         ;; Do not delete this line!!!
GameInit ENDP



GamePlay PROC uses ebx
	invoke ClearScreen
	invoke OrigFood
	invoke CreateShop
	;invoke CreatePlayer
	;invoke CreateEnemies
	invoke StatusBoard
player_alive:
	lea ebx, player
	cmp (GAMEOBJECT PTR[ebx]).lives, 0
	je game_over
move:
	add (GAMEOBJECT PTR[ebx]).score, 1
	invoke UpdatePlayer
	invoke UpdateEnemies
	invoke Shopping
	invoke PlayerAte
keep_playing:
	invoke PlayerEnemyCollision
	jmp done
game_over:
	invoke DrawStr, offset GameOverStr, 320, 240, 0ffh

done:
	ret         ;; Do not delete this line!!!
GamePlay ENDP

END

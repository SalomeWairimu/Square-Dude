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
	dstX DWORD ?
	dstY DWORD ?
	missiles DWORD ?
	angle FXPT ?
	lives DWORD ?
	score DWORD ?
	foodpoints DWORD ?
	bmap DWORD ?
GAMEOBJECT ENDS


food GAMEOBJECT<100, 150, 0, 0, 0, 0, 0, 0, 0, 0, 0, OFFSET patty>
player GAMEOBJECT<500, 80, 0, 0, 0, 0, 1, 0, 3, 0, 0, OFFSET spongebob>
enemies GAMEOBJECT 5 DUP (<400, 250, 1, -1, 0, 0, 0, 0, 1, 0, 0, OFFSET plankton>)
; enemy2 GAMEOBJECT<500, 250, 0, 0, 0, 0, 1, 0, 0, OFFSET plankton>
; enemy3 GAMEOBJECT<300, 250, 0, 0, 0, 0, 1, 0, 0, OFFSET plankton>
shop GAMEOBJECT<240, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, OFFSET krustykrab>
rocket GAMEOBJECT<500, 300, 0, 0, 502, 304, 0, 0, 0, 0, 0, OFFSET missile>
GameOverStr BYTE "Game Over", 0
fmtScoreStr BYTE "Score: %d", 0
fmtFoodStr BYTE "Food Points: %d", 0
fmtLivesStr BYTE "Lives: %d", 0
fmtMissilesStr BYTE "Missiles: %d", 0
outScoreStr BYTE 40 DUP(0)
outFoodStr BYTE 40 DUP(0)
outLivesStr BYTE 40 DUP(0)
outMissilesStr BYTE 40 DUP(0)
SelectStr BYTE "Press L to purchase 1 life or M to purchase 1 missile", 0
BrokeStr BYTE "You're broke, You need at least 10 patties to buy anything", 0

missile_mission DWORD 0

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


CheckBounds PROC USES ecx edx edi esi newvelx:DWORD , newvely:DWORD , myobj:DWORD
	LOCAL xpos:DWORD, ypos:DWORD, xvel:DWORD, yvel:DWORD

	mov ecx, myobj
	mov edx, (GAMEOBJECT PTR[ecx]).posX
	mov xpos, edx
	mov edx, (GAMEOBJECT PTR[ecx]).posY
	mov ypos, edx
	mov edx, (GAMEOBJECT PTR[ecx]).velX
	mov xvel, edx
	mov edx, (GAMEOBJECT PTR[ecx]).velY
	mov yvel, edx
	mov edi, newvelx
	mov esi, newvely
check_x_dir:
	cmp xvel, 0
	jl check_left_wall
check_right_wall:
	cmp xpos, 590
	jl check_y_dir
	neg edi
	mov (GAMEOBJECT PTR[ecx]).velX, edi
	jmp check_y_dir
check_left_wall:
	cmp xpos, 50
	jg check_y_dir
	mov (GAMEOBJECT PTR[ecx]).velX, edi

check_y_dir:
	cmp yvel, 0
	jl check_north_wall
check_south_wall:
	cmp ypos, 420
	jl done
	neg esi
	mov (GAMEOBJECT PTR[ecx]).velY, esi
	jmp done
check_north_wall:
	cmp ypos, 60
	jg done
	mov (GAMEOBJECT PTR[ecx]).velY, esi
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

PlayerAppear PROC USES edx
	lea edx, player
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
PlayerAppear ENDP

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
	invoke PlayerMove, ebx
done:
	ret												;; Do not delete this line!!!
UpdatePlayer ENDP


PlayerMove PROC USES ecx edx ebx esi mykey:DWORD
	lea ecx, OFFSET player
	mov ebx, 0
	mov esi, mykey
	invoke CheckBounds, ebx, ebx, ecx
	cmp esi, VK_LEFT
	je x_dir
	cmp esi, VK_RIGHT
	je x_dir
	jmp y_dir

x_dir:
	mov edx, (GAMEOBJECT PTR[ecx]).velX
	add (GAMEOBJECT PTR[ecx]).posX, edx
	jmp done
y_dir:
	mov edx, (GAMEOBJECT PTR[ecx]).velY
	add (GAMEOBJECT PTR[ecx]).posY, edx
done:
	ret
PlayerMove ENDP



;;;;;;;;;;;;;   ENEMY FUNCTIONS 
InitEnemies PROC USES ecx edi edx
	lea ecx, enemies
	mov edi, 0
	mov edx, TYPE enemies
mainloop:
	invoke BasicBlit, (GAMEOBJECT PTR[ecx]).bmap, (GAMEOBJECT PTR[ecx]).posX, (GAMEOBJECT PTR[ecx]).posY
inc_:
	inc edi
	add ecx, edx
cond:
	cmp edi, LENGTHOF enemies
	jl mainloop
done:
	ret
InitEnemies ENDP

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


Enemymove PROC USES ebx ecx edx myobj:DWORD
	mov ecx, myobj
	mov ebx, 1
	invoke CheckBounds, ebx, ebx, ecx
	mov edx, (GAMEOBJECT PTR[ecx]).velX
	add (GAMEOBJECT PTR[ecx]).posX, edx
	mov edx, (GAMEOBJECT PTR[ecx]).velY
	add (GAMEOBJECT PTR[ecx]).posY, edx
done:
	ret
Enemymove ENDP


DeadEnemymove PROC USES ecx myobj:DWORD
	mov ecx, myobj
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
	invoke PlayerAppear
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
ShootMissile PROC USES ecx ebx edx esi edi
	lea ecx, player
	lea edi, rocket
	mov ebx, OFFSET MouseStatus
	mov edx, (MouseInfo PTR[ebx]).buttons
	cmp edx, MK_LBUTTON
	jne done
	cmp (GAMEOBJECT PTR[ecx]).missiles, 1
	jl no_missiles
	mov eax, (GAMEOBJECT PTR[ecx]).posX
	mov esi, (GAMEOBJECT PTR[ecx]).posY
	mov (GAMEOBJECT PTR[edi]).posX, eax
	mov (GAMEOBJECT PTR[edi]).posY, esi
	mov eax, (MouseInfo PTR[ebx]).horiz
	mov esi, (MouseInfo PTR[ebx]).vert
	mov (GAMEOBJECT PTR[edi]).dstX, eax
	mov (GAMEOBJECT PTR[edi]).dstY, esi
reduce_missiles:
	sub (GAMEOBJECT PTR[ecx]).missiles, 1
	mov missile_mission, 0
no_missiles:
	jmp done
done:
	ret
ShootMissile ENDP

MissileEnemyCollision PROC USES ecx ebx edx edi
	lea ebx, rocket
	lea ecx, enemies
	mov edi, 0
	mov edx, TYPE enemies
mainloop:
	invoke CheckIntersect, (GAMEOBJECT PTR[ebx]).posX, (GAMEOBJECT PTR[ebx]).posY, (GAMEOBJECT PTR[ebx]).bmap, (GAMEOBJECT PTR[ecx]).posX, (GAMEOBJECT PTR[ecx]).posY, (GAMEOBJECT PTR[ecx]).bmap
	cmp eax, 0
	jne reduce_lives
	jmp inc_
reduce_lives:
	;mov (GAMEOBJECT PTR[ecx]).bmap, OFFSET skeleton
	sub (GAMEOBJECT PTR[ecx]).lives, 1
inc_:
	inc edi
	add ecx, edx
cond:
	cmp edi, LENGTHOF enemies
	jl mainloop
done:
	ret
MissileEnemyCollision ENDP

MissileMove PROC USES ebx ecx edi esi edx
	;; Feel free to use local variables...declare them here
	;; For example:
	LOCAL delta_x:SDWORD, delta_y:SDWORD
	;; Place your code here

;;initializes delta_x,delta_y,inc_x,inc_y,error,two,curr_x in edi, and curr_y in esi
	lea edi, rocket
	cmp missile_mission, 0
	jne drop
initialize:
	mov ebx, (GAMEOBJECT PTR[edi]).dstX
	mov ecx, (GAMEOBJECT PTR[edi]).dstY
	sub ebx, (GAMEOBJECT PTR[edi]).posX
	sub ecx, (GAMEOBJECT PTR[edi]).posY
	mov delta_x, ebx
	mov delta_y, ecx
	cmp delta_x, 0
	jne x_dir
	cmp delta_y, 0
	jne x_dir
	mov missile_mission, 1
	jmp drop

x_dir:
	cmp delta_x, 0
	jg inc_x
	cmp delta_x, 0
	jl dec_x
	mov (GAMEOBJECT PTR[edi]).velX, 0
	jmp y_dir
dec_x:
	mov (GAMEOBJECT PTR[edi]).velX, -2
	jmp y_dir
inc_x:
	mov (GAMEOBJECT PTR[edi]).velX, 2

y_dir:
	cmp delta_y, 0
	jg inc_y
	cmp delta_y, 0
	jl dec_y
	mov (GAMEOBJECT PTR[edi]).velY, 0
	jmp move
dec_y:
	mov (GAMEOBJECT PTR[edi]).velY, -2
	jmp move
inc_y:
	mov (GAMEOBJECT PTR[edi]).velY, 2

move:
	mov ebx, (GAMEOBJECT PTR[edi]).posX
	mov edx, (GAMEOBJECT PTR[edi]).posY
	mov ebx, (GAMEOBJECT PTR[edi]).velX
	mov edx, (GAMEOBJECT PTR[edi]).velY
	add (GAMEOBJECT PTR[edi]).posX, ebx
	add (GAMEOBJECT PTR[edi]).posY, edx
	jmp done
drop:
	mov ebx, (GAMEOBJECT PTR[edi]).posY
	cmp (GAMEOBJECT PTR[edi]).posY, 420
	jge done
	add (GAMEOBJECT PTR[edi]).posY, 40
	
done:
	;invoke BasicBlit, (GAMEOBJECT PTR[edi]).bmap, (GAMEOBJECT PTR[edi]).posX, (GAMEOBJECT PTR[edi]).posY
	ret        													;;  Don't delete this line...you need it
MissileMove ENDP

ShowMissile PROC
	lea edx, rocket
	invoke BasicBlit, (GAMEOBJECT PTR[edx]).bmap, (GAMEOBJECT PTR[edx]).posX, (GAMEOBJECT PTR[edx]).posY
	ret
done:
	ret
ShowMissile ENDP

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
	invoke DrawStr, offset outMissilesStr, 150, 10, 0ffh
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
	invoke ShowMissile
	rdtsc
	invoke nseed, eax
	ret         ;; Do not delete this line!!!
GameInit ENDP



GamePlay PROC uses ebx
	invoke ClearScreen
	invoke OrigFood
	invoke CreateShop
	invoke CreatePlayer
	invoke InitEnemies
	invoke StatusBoard
	invoke ShowMissile
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
	invoke ShootMissile
	invoke MissileMove
	jmp done
game_over:
	invoke DrawStr, offset GameOverStr, 320, 240, 0ffh

done:
	ret         ;; Do not delete this line!!!
GamePlay ENDP

END

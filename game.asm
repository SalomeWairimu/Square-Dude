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
include \masm32\include\windows.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib




.DATA

game_state DWORD 0
currlevel DWORD 1
falling DWORD 0
themesong BYTE "themesong.wav", 0
mainsong BYTE "backgroundsong.wav", 0
atepatty BYTE "spongebob_laugh.wav", 0
hitenemy BYTE "spongebob_stinks.wav", 0
playeatingsound DWORD 0
eatingsoundcount DWORD 0
playfallingsound DWORD 0
fallingsoundcount DWORD 0
playmainsong DWORD 1
level1enemies DWORD 5
Level1patties DWORD 5
level2enemies DWORD 7
level2patties DWORD 10

GAMEOBJECT STRUCT
	posX FXPT ?
	posY FXPT ?
	velX FXPT ?
	velY FXPT ?
	angle FXPT ?
	lives DWORD ?
	score DWORD ?
	foodpoints DWORD ?
	bmap DWORD ?
GAMEOBJECT ENDS


food GAMEOBJECT<6553600, 9830400, 0, 0, 0, 0, 0, 0, OFFSET patty>
player GAMEOBJECT<33554432, 5242880, 0, 0, 0, 3, 0, 0, OFFSET spongebob>
;enemies GAMEOBJECT 10 DUP (<26214400, 16384000, 65536, -65536, 0, 1, 0, 0, OFFSET plankton>)
enemies GAMEOBJECT 10 DUP (<42598400, 32112640, 0, 0, 0, 1, 0, 0, OFFSET plankton>)
shop GAMEOBJECT<20971520, 28180480, 0, 0, 0, 0, 0, 0, OFFSET krustykrab>
background GAMEOBJECT<20971520, 15728640, 0, 0, 0, 0, 0, 0, OFFSET bikinibottom>
fmtScoreStr BYTE "Score: %d", 0
fmtFoodStr BYTE "Food Points: %d", 0
fmtLivesStr BYTE "Lives: %d", 0
outScoreStr BYTE 40 DUP(0)
outFoodStr BYTE 40 DUP(0)
outLivesStr BYTE 40 DUP(0)
SelectStr BYTE "Press L to purchase 1 life", 0
BrokeStr BYTE "You're broke, You need at least 5 patties to buy a life", 0

StartStr1 BYTE "Hi, welcome to Bikini Bottom", 0
StartStr3 BYTE "Beware, plankton will try to kill you", 0
StartStr4 BYTE "You can trade in 3 patties for a life by pressing L at the Krusty Krab", 0
StartStr11 BYTE "To pass level one, you need to collect 5 patties", 0
StartStr12 BYTE "To pass level two, you need to collect 10 patties", 0
StartStr5 BYTE "Game rules are: ", 0
StartStr6 BYTE "To start, press ENTER", 0
StartStr7 BYTE "To move, press the respective ARROW KEYS", 0
StartStr8 BYTE "To pause, press SPACE BAR", 0
StartStr2 BYTE "To unpause, press ENTER", 0
StartStr9 BYTE "To Quit, press Q", 0
StartStr10 BYTE "Enjoy :)", 0

NextLevel1 BYTE "Congratulations! You advanced to the next level", 0
NextLevel2 BYTE "Press Enter to proceed", 0
NextLevel3 BYTE "Press Q to quit", 0

PausedStr BYTE "Game is paused, press SPACE BAR to play", 0

GameOverStr BYTE "Game Over", 0
GameOverStr2 BYTE "Press Enter to restart", 0

.CODE

;;;;; UNUSED
DeadEnemymove PROC USES ecx edx myobj:DWORD
	LOCAL y:DWORD
	mov ecx, myobj
	mov edx, (GAMEOBJECT PTR[ecx]).posY
	sar edx, 16
	mov y, edx
	cmp y, 420
	jge done
dec_y:
	sub (GAMEOBJECT PTR[ecx]).posY, 65536
done:
	ret
DeadEnemymove ENDP


;;;;;;;;;;;;;   GameState Pages

ShowStartStr PROC
	invoke DrawStr, offset StartStr1, 210, 220, 000h
	invoke DrawStr, offset StartStr11, 140, 250, 000h
	invoke DrawStr, offset StartStr12, 140, 260, 000h
	invoke DrawStr, offset StartStr3, 210, 280, 000h
	invoke DrawStr, offset StartStr4, 50, 290, 000h

	invoke DrawStr, offset StartStr5, 150, 330, 000h
	invoke DrawStr, offset StartStr6, 210, 340, 000h
	invoke DrawStr, offset StartStr7, 210, 350, 000h
	invoke DrawStr, offset StartStr8, 210, 360, 000h
	invoke DrawStr, offset StartStr2, 210, 370, 000h
	invoke DrawStr, offset StartStr9, 210, 380, 000h
	invoke DrawStr, offset StartStr10, 210, 390, 000h

	ret
ShowStartStr ENDP

ShowPausedStr PROC
	invoke DrawStr, offset PausedStr, 210, 240, 000h
	ret
ShowPausedStr ENDP

ShowOverStr PROC
	invoke DrawStr, offset GameOverStr, 210, 240, 000h
	invoke DrawStr, offset GameOverStr2, 210, 250, 000h
	ret
ShowOverStr ENDP

ShowLevelStr PROC
	invoke DrawStr, offset NextLevel1, 210, 240, 000h
	invoke DrawStr, offset NextLevel2, 210, 250, 000h
	invoke DrawStr, offset NextLevel3, 210, 260, 000h
	ret
ShowLevelStr ENDP


PlayAudio PROC USES ecx audio:DWORD
  xor ecx, ecx
  invoke PlaySound, audio, 0,  SND_ASYNC
mainloop:
  inc ecx
cond:
  cmp ecx, 5
  jl mainloop
  ret
PlayAudio ENDP


HandleInput PROC uses ebx edx ecx esi
	LOCAL newstate:DWORD
	lea ecx, player
	mov ebx, KeyPress
	mov esi, KeyDown
	mov edx, game_state
	mov newstate, edx
	cmp game_state, 0
	je startpage
	cmp game_state, 1
	je playing
	cmp game_state, 2
	je paused
	cmp game_state, 3
	je overpage
	cmp game_state, 4
	je switchlevel
	jmp done

startpage:
	invoke ShowStartStr
	cmp ebx, VK_RETURN
	jne done
	mov newstate, 1
	Invoke BackgroundSong
	jmp done

playing:
	cmp ebx, VK_SPACE
	je pause_game
	cmp ebx, VK_Q
	jne done
	mov newstate, 3
	jmp done
pause_game:
	mov newstate, 2
	jmp done

paused:
	invoke ShowPausedStr
	cmp ebx, VK_RETURN
	jne done
	mov newstate, 1
	jmp done

overpage:
	invoke ShowOverStr
	cmp ebx, VK_RETURN
	jne done
	invoke ResetGame
	mov newstate, 0
	jmp done

switchlevel:
	invoke ShowLevelStr
	cmp ebx, VK_RETURN
	je newlevel
	cmp ebx, VK_Q
	jne done
	mov newstate, 3
	jmp done
newlevel:
	invoke LevelUp
	invoke ResetGame
	mov newstate, 1

done:
	mov edx, newstate
	mov game_state, edx
	ret
HandleInput ENDP

PlayerLevel PROC USES ebx
	lea ebx, player
	cmp currlevel, 1
	je level1
level2:
	cmp (GAMEOBJECT PTR[ebx]).foodpoints, 10
	jl done
	mov game_state, 4
	jmp done
level1:
	cmp (GAMEOBJECT PTR[ebx]).foodpoints, 5
	jl done
	mov game_state, 4
done:
	ret
PlayerLevel ENDP

LevelUp PROC
	mov currlevel, 2
	ret
LevelUp ENDP
;;;;;;;;;;;;;   SHOP FUNCTIONS


CreateShop PROC USES esi
	lea esi, shop
	mov (GAMEOBJECT PTR[esi]).posX, 20971520
	mov (GAMEOBJECT PTR[esi]).posY, 22937600
done:
	ret
CreateShop ENDP

InitShop PROC USES esi ebx
	LOCAL x:DWORD, y:DWORD
	lea esi, shop
	mov ebx, (GAMEOBJECT PTR[esi]).posX
	sar ebx, 16
	mov x, ebx
	mov ebx, (GAMEOBJECT PTR[esi]).posY
	sar ebx, 16
	mov y, ebx
	invoke BasicBlit, (GAMEOBJECT PTR[esi]).bmap, x, y
	ret
InitShop ENDP

Shopping PROC USES ebx esi edx
	LOCAL x1:DWORD, y1:DWORD, x2:DWORD, y2:DWORD
	lea ebx, player
	lea esi, shop
	mov edx, (GAMEOBJECT PTR[ebx]).posX
	sar edx, 16
	mov x1, edx
	mov edx, (GAMEOBJECT PTR[ebx]).posY
	sar edx, 16
	mov y1, edx
	mov edx, (GAMEOBJECT PTR[esi]).posX
	sar edx, 16
	mov x2, edx
	mov edx, (GAMEOBJECT PTR[esi]).posY
	sar edx, 16
	mov y2, edx
	invoke CheckIntersect, x1, y1, (GAMEOBJECT PTR[ebx]).bmap, x2, y2, (GAMEOBJECT PTR[esi]).bmap
	cmp eax, 0
	je done
	cmp (GAMEOBJECT PTR[ebx]).foodpoints, 3
	jl broke
shopnow:
	invoke DrawStr, offset SelectStr, 180, 200, 000h
	mov ecx, KeyPress
	cmp ecx, VK_L
	je buy_life
	jmp done
buy_life:
	add (GAMEOBJECT PTR[ebx]).lives, 1
	sub (GAMEOBJECT PTR[ebx]).foodpoints, 3
	jmp done
broke:
	invoke DrawStr, offset BrokeStr,20, 200, 000h
done:
	ret
Shopping ENDP


;;;;;;;;;;;;;   PLAYER FUNCTIONS
SetPlayerPos PROC USES edx ecx edi
	lea edx, player
	push ecx
	push edx
	invoke nrandom, 38666240
	pop edx
	pop ecx
	add eax, 1572864
	mov (GAMEOBJECT PTR[edx]).posX, eax
	push ecx
	push edx
	invoke nrandom, 28180480
	pop edx
	pop ecx
	add eax, 1310720
	mov (GAMEOBJECT PTR[edx]).posY, eax
	ret
SetPlayerPos ENDP

CreatePlayer PROC USES ecx
	invoke SetPlayerPos
	lea ecx, player
	mov (GAMEOBJECT PTR[ecx]).lives, 3
	mov (GAMEOBJECT PTR[ecx]).foodpoints, 0
	mov (GAMEOBJECT PTR[ecx]).score, 0
	mov (GAMEOBJECT PTR[ecx]).bmap, OFFSET spongebob
done:
	ret
CreatePlayer ENDP

InitPlayer PROC USES ebx edx
	LOCAL x:DWORD, y:DWORD
	lea ebx, player
	mov edx, (GAMEOBJECT PTR[ebx]).posX
	sar edx, 16
	mov x, edx
	mov edx, (GAMEOBJECT PTR[ebx]).posY
	sar edx, 16
	mov y, edx
	invoke BasicBlit, (GAMEOBJECT PTR[ebx]).bmap, x, y
	ret
InitPlayer ENDP


UpdatePlayer PROC USES ebx ecx
  mov ecx, OFFSET player
  mov ebx, KeyPress
  cmp falling, 0
  jne playerfalling
keyboard:
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
	mov (GAMEOBJECT PTR[ecx]).velY, -327680
	jmp moveplayer
down:
	mov (GAMEOBJECT PTR[ecx]).velY, 327680
	jmp moveplayer
left:
	mov (GAMEOBJECT PTR[ecx]).velX, -327680
	jmp moveplayer
right:
	mov (GAMEOBJECT PTR[ecx]).velX, 327680
  jmp moveplayer

playerfalling:
  mov (GAMEOBJECT PTR[ecx]).velY, 327680
  mov (GAMEOBJECT PTR[ecx]).velX, 0

moveplayer:
	invoke PlayerMove, ebx
  jmp done


done:
	ret												;; Do not delete this line!!!
UpdatePlayer ENDP


PlayerMove PROC USES ecx edx ebx esi mykey:DWORD
	lea ecx, OFFSET player
  cmp falling, 0
  jne playerfalling
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
  jmp done
playerfalling:
  mov edx, (GAMEOBJECT PTR[ecx]).velY
  add (GAMEOBJECT PTR[ecx]).posY, edx
  cmp (GAMEOBJECT PTR[ecx]).posY, 29491200
  jl done
  mov falling, 0
  mov (GAMEOBJECT PTR[ecx]).bmap, OFFSET spongebob
  invoke SetPlayerPos

done:
	ret
PlayerMove ENDP



;;;;;;;;;;;;;   ENEMY FUNCTIONS
CreateEnemies PROC USES ecx edi edx esi
	lea ecx, enemies
	mov edi, 0
	mov edx, TYPE enemies
	mov esi, 5
	cmp currlevel, 1
	je cond
	mov esi, 7
mainloop:
	push ecx
	push edx
	push edi
	invoke nrandom, 38666240
	pop edi
	pop edx
	pop ecx
	add eax, 1638400
	mov (GAMEOBJECT PTR[ecx]).posX, eax
	push ecx
	push edx
	push edi
	invoke nrandom, 28180480
	pop edi
	pop edx
	pop ecx
	add eax, 1638400
	mov (GAMEOBJECT PTR[ecx]).posY, eax
set_vel_x:
	push ecx
	push edx
	push edi
	invoke nrandom, 20
	pop edi
	pop edx
	pop ecx
	cmp eax, 10
	jl vel_x_neg
vel_x_pos:
	mov (GAMEOBJECT PTR[ecx]).velX, 65536
	jmp set_vel_y
vel_x_neg:
	mov (GAMEOBJECT PTR[ecx]).velX, -65536
set_vel_y:
	push ecx
	push edx
	push edi
	invoke nrandom, 20
	pop edi
	pop edx
	pop ecx
	cmp eax, 10
	jl vel_y_neg
vel_y_pos:
	mov (GAMEOBJECT PTR[ecx]).velY, 65536
	jmp set_vel_y
vel_y_neg:
	mov (GAMEOBJECT PTR[ecx]).velY, -65536


inc_:
	inc edi
	add ecx, edx
cond:
	cmp edi, esi
	jl mainloop
done:
	ret
CreateEnemies ENDP

InitEnemies PROC USES ecx edi edx ebx
	LOCAL x:DWORD, y:DWORD
	lea ecx, enemies
	mov edi, 0
	mov edx, TYPE enemies
mainloop:
	mov ebx, (GAMEOBJECT PTR[ecx]).posX
	sar ebx, 16
	mov x, ebx
	mov ebx, (GAMEOBJECT PTR[ecx]).posY
	sar ebx, 16
	mov y, ebx
	invoke BasicBlit, (GAMEOBJECT PTR[ecx]).bmap, x, y
inc_:
	inc edi
	add ecx, edx
cond:
	cmp edi, LENGTHOF enemies
	jl mainloop
done:
	ret
InitEnemies ENDP


UpdateEnemies PROC USES ecx edi edx esi
	lea ecx, enemies
	mov edi, 0
	mov edx, TYPE enemies
	mov esi, 5
	cmp currlevel, 1
	je cond
	mov esi, 7
mainloop:
	invoke Enemymove, ecx
	jmp inc_
inc_:
	inc edi
	add ecx, edx
cond:
	cmp edi, esi
	jl mainloop
done:
	ret
UpdateEnemies ENDP


Enemymove PROC USES ebx ecx edx myobj:DWORD
	mov ecx, myobj
	mov ebx, 65536
	invoke CheckBounds, ebx, ebx, ecx
	mov edx, (GAMEOBJECT PTR[ecx]).velX
	add (GAMEOBJECT PTR[ecx]).posX, edx
	mov edx, (GAMEOBJECT PTR[ecx]).velY
	add (GAMEOBJECT PTR[ecx]).posY, edx
done:
	ret
Enemymove ENDP


;;;;;;;;;;;;;   FOOD FUNCTIONS
SetFoodPos PROC USES edx ecx edi
	lea edx, food
	push ecx
	push edx
	invoke nrandom, 38666240
	pop edx
	pop ecx
	add eax, 1638400
	mov (GAMEOBJECT PTR[edx]).posX, eax
	push ecx
	push edx
	invoke nrandom, 28180480
	pop edx
	pop ecx
	add eax, 1638400
	mov (GAMEOBJECT PTR[edx]).posY, eax
	ret
SetFoodPos ENDP

InitFood PROC USES edx ebx
	LOCAL x:DWORD, y:DWORD
	lea edx, food
	mov ebx, (GAMEOBJECT PTR[edx]).posX
	sar ebx, 16
	mov x, ebx
	mov ebx, (GAMEOBJECT PTR[edx]).posY
	sar ebx, 16
	mov y, ebx
	invoke BasicBlit, (GAMEOBJECT PTR[edx]).bmap, x, y
	ret
InitFood ENDP



;;;;;;;;;;;;    Collision functions
PlayerEnemyCollision PROC USES ecx ebx edx edi esi
	LOCAL x1:DWORD, y1:DWORD, x2:DWORD, y2:DWORD
	cmp falling, 0
	jne done
	lea ebx, player
	lea ecx, enemies
	mov esi, (GAMEOBJECT PTR[ebx]).posX
	sar esi, 16
	mov x1, esi
	mov esi, (GAMEOBJECT PTR[ebx]).posY
	sar esi, 16
	mov y1, esi
	mov edi, 0
	mov edx, TYPE enemies
mainloop:
	mov esi, (GAMEOBJECT PTR[ecx]).posX
	sar esi, 16
	mov x2, esi
	mov esi, (GAMEOBJECT PTR[ecx]).posY
	sar esi, 16
	mov y2, esi
	invoke CheckIntersect, x1, y1, (GAMEOBJECT PTR[ebx]).bmap, x2, y2, (GAMEOBJECT PTR[ecx]).bmap
	cmp eax, 0
	jne reduce_lives
	jmp inc_
reduce_lives:
	sub (GAMEOBJECT PTR[ebx]).lives, 1
	mov falling, 1
	mov (GAMEOBJECT PTR[ebx]).bmap, OFFSET deadspongebob
inc_:
	inc edi
	add ecx, edx
cond:
	cmp edi, LENGTHOF enemies
	jl mainloop

done:
	ret
PlayerEnemyCollision ENDP

PlayerAte PROC USES ebx esi edx
	LOCAL x1:DWORD, y1:DWORD, x2:DWORD, y2:DWORD
	lea ebx, player
	lea esi, food
	mov edx, (GAMEOBJECT PTR[ebx]).posX
	sar edx, 16
	mov x1, edx
	mov edx, (GAMEOBJECT PTR[ebx]).posY
	sar edx, 16
	mov y1, edx
	mov edx, (GAMEOBJECT PTR[esi]).posX
	sar edx, 16
	mov x2, edx
	mov edx, (GAMEOBJECT PTR[esi]).posY
	sar edx, 16
	mov y2, edx
	invoke CheckIntersect, x1, y1, (GAMEOBJECT PTR[ebx]).bmap, x2, y2, (GAMEOBJECT PTR[esi]).bmap
	cmp eax, 0
	je done
add_foodpoints:
	mov playmainsong, 0
	mov playeatingsound, 1
  	invoke FedSong
	add (GAMEOBJECT PTR[ebx]).foodpoints, 1
newfoodpos:
	invoke SetFoodPos
done:
	ret
PlayerAte ENDP


;;;;;;;;;;;;;   SCREEN FUNCTIONS
StatusBoard PROC USES ebx ecx edx
	lea ebx, player
score:
	mov ecx, (GAMEOBJECT PTR[ebx]).score
	sar ecx, 16
	push ecx
	push offset fmtScoreStr
	push offset outScoreStr
	call wsprintf
	add esp, 12
	invoke DrawStr, offset outScoreStr, 300, 10, 000h
lives:
	push (GAMEOBJECT PTR[ebx]).lives
	push offset fmtLivesStr
	push offset outLivesStr
	call wsprintf
	add esp, 12
	invoke DrawStr, offset outLivesStr, 500, 10, 000h
foodpoints:
	push (GAMEOBJECT PTR[ebx]).foodpoints
	push offset fmtFoodStr
	push offset outFoodStr
	call wsprintf
	add esp, 12
	invoke DrawStr, offset outFoodStr, 10, 10, 000h
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

AddBackground PROC USES esi ebx
	LOCAL x:DWORD, y:DWORD
	lea esi, background
	mov ebx, (GAMEOBJECT PTR[esi]).posX
	sar ebx, 16
	mov x, ebx
	mov ebx, (GAMEOBJECT PTR[esi]).posY
	sar ebx, 16
	mov y, ebx
	invoke BasicBlit, (GAMEOBJECT PTR[esi]).bmap, x, y
	ret
AddBackground ENDP

ThemeSong PROC
    INVOKE PlaySound, NULL, 0, SND_ASYNC
    INVOKE PlaySound, offset themesong, 0, SND_FILENAME OR SND_ASYNC
    ret
ThemeSong ENDP

BackgroundSong PROC
    INVOKE PlaySound, NULL, 0, SND_ASYNC
    INVOKE PlaySound, offset mainsong, 0, SND_FILENAME OR SND_ASYNC OR SND_LOOP
    ret
BackgroundSong ENDP

FedSong PROC
    INVOKE PlaySound, NULL, 0, SND_ASYNC
    INVOKE PlaySound, offset atepatty, 0, SND_ASYNC
    ret
FedSong ENDP

HitEnemy PROC
    INVOKE PlaySound, NULL, 0, SND_ASYNC
    INVOKE PlaySound, offset atepatty, 0, SND_ASYNC
    ret
HitEnemy ENDP
;;;;;;;;;;;;;   MAIN FUNCTIONS
ResetGame PROC
	invoke ClearScreen
	invoke AddBackground
	invoke SetFoodPos
	invoke CreateShop
	invoke CreateEnemies
	invoke CreatePlayer
  	mov falling, 0
	ret
ResetGame ENDP
GameInit PROC
	invoke ClearScreen
	invoke AddBackground
	invoke SetFoodPos
	invoke CreateShop
	invoke CreateEnemies
	invoke CreatePlayer
	invoke StatusBoard
	invoke ThemeSong
	;mov game_state, 0
  	mov falling, 0
	rdtsc
	invoke nseed, eax
	ret         ;; Do not delete this line!!!
GameInit ENDP



GamePlay PROC uses ebx
	invoke ClearScreen
	invoke AddBackground
	;invoke PlayAudio
	invoke HandleInput
	cmp game_state, 0
	je done
	cmp game_state, 3
	je done
	cmp game_state, 4
	je done

main:
	invoke InitFood
	invoke InitShop
	invoke InitPlayer
	invoke InitEnemies
	invoke StatusBoard


	cmp game_state, 2
	je done
sounds:
	cmp playmainsong, 1
	je move
	cmp playeatingsound, 1
	je eatingsong
	jmp move

eatingsong:
	add eatingsoundcount, 1
	cmp eatingsoundcount, 20
	jl move
	mov playeatingsound, 0
	mov playmainsong, 1
	mov eatingsoundcount, 0
	invoke BackgroundSong
	jmp move

move:
	lea ebx, player
	add (GAMEOBJECT PTR[ebx]).score, 8192
	invoke UpdatePlayer
	invoke UpdateEnemies
	invoke Shopping
	invoke PlayerAte
keep_playing:
	invoke PlayerEnemyCollision

player_alive:
	lea ebx, player
	cmp (GAMEOBJECT PTR[ebx]).lives, 0
	jne levelcheck

game_over:
	mov game_state, 3
	jmp done
	; invoke ShowOverStr
	; invoke DrawStr, offset GameOverStr, 320, 240, 000h
levelcheck:
	invoke PlayerLevel
done:
	ret         ;; Do not delete this line!!!
GamePlay ENDP

;;; INTERSECT FUNCTIONS
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


CheckBounds PROC USES ecx edx edi esi newvelx:FXPT , newvely:FXPT , myobj:DWORD
	LOCAL xpos:DWORD, ypos:DWORD, xvel:DWORD, yvel:DWORD

	mov ecx, myobj
	mov edx, (GAMEOBJECT PTR[ecx]).posX
	sar edx, 16
	mov xpos, edx
	mov edx, (GAMEOBJECT PTR[ecx]).posY
	sar edx, 16
	mov ypos, edx
	mov edx, (GAMEOBJECT PTR[ecx]).velX
	sar edx, 16
	mov xvel, edx
	mov edx, (GAMEOBJECT PTR[ecx]).velY
	sar edx, 16
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


END

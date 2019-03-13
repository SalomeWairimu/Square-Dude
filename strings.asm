; #########################################################################
;
;   strings.asm - Assembly file for;
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
include strings.inc

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

fmtScoreStr BYTE "Score: %d", 0
fmtFoodStr BYTE "Food Points: %d", 0
fmtLivesStr BYTE "Lives: %d", 0
fmtLevelStr BYTE "Level: %d", 0
fmtPurchaseStr BYTE "You need %d more foodpoints to make a purchase", 0
outScoreStr BYTE 40 DUP(0)
outFoodStr BYTE 40 DUP(0)
outLivesStr BYTE 40 DUP(0)
outLevelStr BYTE 40 DUP(0)
outPurchaseStr BYTE 70 DUP(0)
SelectStr BYTE "Press L to purchase 1 life", 0
BrokeStr BYTE "You broke af", 0
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

PausedStr BYTE "Game is paused, press ENTER to resume", 0

GameOverStr BYTE "Game Over", 0
GameOverStr2 BYTE "Press Enter to restart", 0

.code

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
	invoke DrawStr, offset outFoodStr, 150, 10, 000h
level:
	push currlevel
	push offset fmtLevelStr
	push offset outLevelStr
	call wsprintf
	add esp, 12
	invoke DrawStr, offset outLevelStr, 10, 10, 000h
done:
	ret
StatusBoard ENDP

END
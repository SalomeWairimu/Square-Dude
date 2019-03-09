; #########################################################################
;
;   game.inc - Includes for EECS205 Assignment 4/5
;
;
; #########################################################################

;; Library Definitions
MouseInfo STRUCT
 horiz DWORD ?
 vert  DWORD ?
 buttons DWORD ?
MouseInfo ENDS

MK_CONTROL  = 0008h  ;; The CTRL key is down.
MK_LBUTTON  = 0001h  ;; The left mouse button is down.
MK_MBUTTON  = 0010h  ;; The middle mouse button is down.
MK_RBUTTON  = 0002h  ;; The right mouse button is down.
MK_SHIFT    = 0004h  ;; The SHIFT key is down.
MK_XBUTTON1 = 0020h  ;; The first X button is down.
MK_XBUTTON2 = 0040h  ;; The second X button is down.

;; Library Functions
BlackStarField	PROTO
DrawStr PROTO myStr:PTR BYTE, x:DWORD, y:DWORD, color:DWORD

;; Library Data
EXTERNDEF StarBitmap:EECS205BITMAP
EXTERNDEF MouseStatus:MouseInfo
EXTERNDEF KeyUp:DWORD
EXTERNDEF KeyDown:DWORD
EXTERNDEF KeyPress:DWORD
EXTERNDEF spongebob:EECS205BITMAP
EXTERNDEF spongebobInvert:EECS205BITMAP
EXTERNDEF krustykrab:EECS205BITMAP
EXTERNDEF plankton:EECS205BITMAP
EXTERNDEF patty:EECS205BITMAP
EXTERNDEF missile:EECS205BITMAP
EXTERNDEF skeleton:EECS205BITMAP

;; User Defined Functions
GameInit PROTO
GamePlay PROTO
StatusBoard PROTO
ClearScreen PROTO
CreateFood PROTO
OrigFood PROTO
MissileEnemyCollision PROTO
ShootMissile PROTO
MissileMove PROTO
PlayerEnemyCollision PROTO
DeadEnemymove PROTO obj:DWORD
Enemymove PROTO obj:DWORD
UpdateEnemies PROTO
CreateEnemies PROTO
InitEnemies PROTO
PlayerMove PROTO mykey:DWORD
UpdatePlayer PROTO
CreatePlayer PROTO
PlayerAppear PROTO
Shopping PROTO
CreateShop PROTO
CheckBounds PROTO newvelx:FXPT , newvely:FXPT , myobj:DWORD
CheckIntersect PROTO oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP




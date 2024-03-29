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
EXTERNDEF deadspongebob:EECS205BITMAP
EXTERNDEF bikinibottom:EECS205BITMAP
EXTERNDEF krustykrab:EECS205BITMAP
EXTERNDEF plankton:EECS205BITMAP
EXTERNDEF patty:EECS205BITMAP
EXTERNDEF SelectStr:BYTE
EXTERNDEF fmtPurchaseStr:BYTE
EXTERNDEF outPurchaseStr:BYTE

;; User Defined Functions

;;;;;;;;;;;;; user input functions
HandleInput PROTO

;;;;;;;;;;;;; LEVEL Functions
PlayerLevel PROTO
LevelUp PROTO

;;;;;;;;;;;;;   SHOP FUNCTIONS
CreateShop PROTO
InitShop PROTO
Shopping PROTO

;;;;;;;;;;;;;   PLAYER FUNCTIONS
SetPlayerPos PROTO
SafeZone PROTO
CreatePlayer PROTO
InitPlayer PROTO
UpdatePlayer PROTO
PlayerMove PROTO mykey:DWORD

;;;;;;;;;;;;;   ENEMY FUNCTIONS
SetEnemyPos PROTO myaddr:DWORD
SetEnemyVel PROTO myaddr:DWORD
SafeEnemyZone PROTO myaddr:DWORD
CreateEnemies PROTO
RestoreEnemies PROTO
InitEnemies PROTO
UpdateEnemies PROTO
Enemymove PROTO obj:DWORD

;;;;;;;;;;;;;   FOOD FUNCTIONS
SetFoodPos PROTO
SafeFoodZone PROTO
InitFood PROTO

;;;;;;;;;;;;    Collision functions
PlayerEnemyCollision PROTO
PlayerAte PROTO
EnemyCollisions PROTO
CheckIntersect PROTO oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
CheckBounds PROTO newvelx:FXPT , newvely:FXPT , myobj:DWORD


;;;;;;;;;;;;;   SCREEN FUNCTIONS
ClearScreen PROTO
AddBackground PROTO


;;;;;;;;;;;;;   GameState Sounds
BackgroundSong PROTO
ThemeSong PROTO
FedSong PROTO
Passed PROTO
MadePurchase PROTO
LostGame PROTO

;;;;;;;;;;;;   MAIN FUNCTIONS
ResetGame PROTO
GameInit PROTO
GamePlay PROTO






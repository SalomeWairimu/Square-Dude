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
skeleton EECS205BITMAP <18, 50, 255,, offset skeleton + sizeof skeleton>
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,06dh,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b6h,000h,000h,000h,092h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h,000h,000h,06dh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,06dh,000h,000h,000h,000h
	BYTE 000h,000h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,0b6h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,024h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b6h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,000h,000h,000h,000h,000h,000h,000h,092h,0ffh,0ffh,024h,000h,0dbh,0ffh,0ffh
	BYTE 0ffh,0ffh,0b6h,000h,000h,000h,000h,000h,000h,000h,0dbh,0ffh,0ffh,06dh,000h,06dh
	BYTE 0ffh,0ffh,0ffh,0ffh,000h,000h,000h,000h,000h,000h,000h,000h,06dh,0ffh,0dbh,000h
	BYTE 000h,000h,0dbh,0ffh,0ffh,0b6h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,092h,0ffh,0ffh,049h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,0ffh,0dbh,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,0dbh,0b6h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,092h,06dh,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,049h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 024h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,024h,092h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,092h,0ffh,092h,049h,06dh,092h,0b6h,0dbh,0b6h,000h,000h,0b6h,0dbh
	BYTE 0b6h,092h,06dh,049h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,000h,000h
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,092h,000h,000h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0b6h,06dh,0dbh,000h,000h,0ffh,06dh,0b6h,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0dbh,06dh,0dbh,0ffh,0ffh,000h,000h,0ffh,0ffh,0dbh,06dh,0dbh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,06dh,0b6h,0ffh,0ffh,0ffh,0ffh,024h,024h,0ffh,0ffh,0ffh,0ffh
	BYTE 0b6h,06dh,0ffh,0ffh,0ffh,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,024h,024h,0dbh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b6h,06dh,049h,06dh
	BYTE 092h,0b6h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,0b6h,0ffh
	BYTE 06dh,06dh,0ffh,0b6h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,06dh,0dbh
	BYTE 0ffh,0ffh,06dh,06dh,0ffh,0ffh,0dbh,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,06dh
	BYTE 0ffh,0ffh,0ffh,0ffh,06dh,06dh,0ffh,0ffh,0ffh,0ffh,06dh,0dbh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0b6h,024h,024h,0b6h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b6h,0b6h,092h,092h,0b6h,0b6h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b6h,0b6h,0ffh,0b6h,0b6h,0ffh,0b6h,0b6h,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,092h,0ffh,0ffh,0b6h,0b6h,0ffh,0ffh
	BYTE 092h,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,0ffh,0ffh,0ffh,092h,092h
	BYTE 0ffh,0ffh,0ffh,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh
	BYTE 000h,000h,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,06dh,092h,092h,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0dbh,0b6h,0dbh,0dbh,0b6h,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0b6h,0ffh,0dbh,0dbh,0ffh,0b6h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b6h,0b6h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b6h,000h,000h,0b6h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b6h,000h,000h,000h,000h,0b6h
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b6h,000h,000h,000h,000h
	BYTE 000h,000h,0b6h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,049h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b6h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0b6h,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,049h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,049h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,000h,000h,000h,049h,092h,0dbh,0dbh,092h,049h,000h,000h,000h,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,06dh,092h,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,092h
	BYTE 06dh,0ffh,0ffh,0ffh
END
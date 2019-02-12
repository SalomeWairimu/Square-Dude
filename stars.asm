; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;   Name: Salome Kariuki
;   netID: SWK6525
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawStarField proc

	;; Place your code here
      ;; using the invoke directive call DrawStar and pass in two parameters, the x coordinate and the y coordinate in that order
      ;; the x coordinate should be in range [0,639]
      ;; the y coordinate should be in range [0,479]
      invoke DrawStar, 248, 435
      invoke DrawStar, 84, 411
      invoke DrawStar, 607, 355
      invoke DrawStar, 119, 108
      invoke DrawStar, 116, 323
      invoke DrawStar, 153, 96
      invoke DrawStar, 184, 95
      invoke DrawStar, 536, 320
      invoke DrawStar, 139, 300
      invoke DrawStar, 299, 310
      invoke DrawStar, 138, 268
      invoke DrawStar, 612, 328
      invoke DrawStar, 600, 306
      invoke DrawStar, 448, 171
      invoke DrawStar, 601, 292
      invoke DrawStar, 50, 273

	ret  			; Careful! Don't remove this line
DrawStarField endp



END

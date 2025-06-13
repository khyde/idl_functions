; $ID:	PSHM.PRO,	2016-01-21,	USER-JOR	$
; 
PRO PSHM,NAMES=NAMES
; #########################################################################; 
;+
; PURPOSE: PRINTS THE SHARED MEMORY  
;
; CATEGORY: PRINT;
;
; CALLING SEQUENCE: 
;
; INPUTS: NONE

; OUTPUTS:  PRINTS THE SHARED MEMORY
;
;; EXAMPLES:  
;           PSHM
;           PSHM,/NAMES
;           
;
; MODIFICATION HISTORY:
;     JAN 20,2016  WRITTEN BY: J.E. O'REILLY
;     JAN 21,2016,JOR ADDED KEY NAMES
;-
; #########################################################################

;*********************
ROUTINE_NAME  = 'PSHM'
;*********************
PLIST,GET_SHM(NAMES=NAMES)
END; #####################  END OF ROUTINE ################################

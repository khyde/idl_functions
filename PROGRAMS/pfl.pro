; $ID:	PFL.PRO,	2017-06-28-16,	USER-KJWH	$
;+
;#############################################################################################################
	PRO PFL, ARR
;
; PURPOSE:  PRINT THE FIRST AND LAST OF THE INPUT ARR 
;
; CATEGORY:	PRINT
;
; CALLING SEQUENCE: PFL,ARR
;
; INPUTS: ARR.....  DATA 
;         
;		
; OPTIONAL INPUTS: NONE
;			
;		
; KEYWORD PARAMETERS: NONE 
;		

; OUTPUTS: PRINTS THE MINMAX OF THE INPUT ARR
;		
; EXAMPLES: 
;   PFL,1
;   PFL,INDGEN(9)
;   PFL,[FINDGEN(9),MISSINGS(10.)]
;
; MODIFICATION HISTORY:
;			JUN 29, 2017  Kimberly J. W. Hyde, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;			
;			
;#################################################################################
;-
;********************
  ROUTINE_NAME  = 'PFL'
;********************
  IF NONE(ARR) THEN BEGIN
    PRINT,'ERROR: MUST PROVIDE ARR'
    GOTO, DONE
  ENDIF
  IF N_ELEMENTS(ARR) EQ 1 THEN PRINT, ARR ELSE PRINT, FIRST(ARR), '  ', LAST(ARR)
  
  
  DONE:
END; #####################  END OF ROUTINE ################################

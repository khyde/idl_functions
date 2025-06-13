; $ID:	CONIC_PARALLELS.PRO,	2020-06-30-17,	USER-KJWH	$

	FUNCTION CONIC_PARALLELS,LIMIT

;+
; NAME:
;		CONIC_PARALLELS
;
; PURPOSE: CALCULATE CONIC_PARALLELS FOR CONIC MAP PROJECTIONS BASED ON 1/6TH RULE
;
; CATEGORY:
;		CATEGORY
;		 MATH
;
; CALLING SEQUENCE:
;
; INPUTS:
;		LIMIT:	VECTOR OF [LATMIN,LONMIN,LATMAX,LONMAX]
;		
; OPTIONAL INPUTS:
;		NONE:	
;
; KEYWORD PARAMETERS:
;		KEY1:	Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;		This function returns the
;

; EXAMPLE:
;  CONIC_PARALLELS
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

;		Citations or any other useful notes
;
;
; MODIFICATION HISTORY:
;			Written JUL 23,2011  J.O'Reilly
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'CONIC_PARALLELS'
  ERROR = ''
  IF N_ELEMENTS(LIMIT) NE 4 THEN BEGIN
    ERROR='MUST PROVIDE LIMIT'
    PRINT,ERROR
    RETURN, ERROR
  
  ENDIF ;IF N_ELEMENTS(LIMIT) NE 4 THEN BEGIN
  
  DELTA = ABS(LIMIT(2) - LIMIT[0])
ONE_SIXTH = DELTA *(1./6)
LOWER = LIMIT[0]+ ONE_SIXTH
UPPER = LIMIT(2)- ONE_SIXTH
RETURN,[LOWER,UPPER]

	END; #####################  End of Routine ################################

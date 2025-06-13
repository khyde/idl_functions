; $ID:	MAP_GEQ_PART.PRO,	DECEMBER 24,2012 	$
;########################################################################################
  PRO MAP_GEQ_PART, LONMIN=LONMIN, LONMAX=LONMAX, LATMIN=LATMIN,LATMAX=LATMAX
;+
; NAME:
;      MAP_GEQ_PART
;
; PURPOSE:
;      ESTABLISH CYLINDRICAL MAP_GEQ MAP PROJECTION FOR A PART OF THE GLOBE
;
; CATEGORY:
;      MAPPING
;
;
; KEYWORD PARAMETERS:
;      _EXTRA    :  ANY VALID KEYWORDS FOR MAP_SET MAY BE USED
;
; OUTPUTS:
;      MAP COORDINATE SYSTEM IS ESTABLISHED IN IDL
;
;
; MODIFICATION HISTORY:
;       WRITTEN BY:  J.E.O'REILLY, DECEMBER 24,1999.
;       DEC 24,2012,JOR,FORMATTING,MESSAGE WHEN INPUTS ARE NOT PROVIDED
;
;-

; NOTES ABOUT THE IDL PROJECTION/MAP
; ==============================================================
; T H I S     P R O J E C T I O N    I S    D E S I G N E D    T O
; M A K E     A  'SIMPLE CYLINDRICAL EQUIDISTANT' M A P   FOR THE G L O B E
;########################################################################################

;*********************************
ROUTINE_NAME = 'MAP_GEQ_PART'
;*********************************

IF N_ELEMENTS(LATMIN) NE 1 OR N_ELEMENTS(LATMAX) NE 1 $
OR N_ELEMENTS(LONMIN) NE 1 OR N_ELEMENTS(LONMIN) NE 1 THEN BEGIN
MESSAGE,'ERROR: MUST PROVIDE LATMIN,LATMAX,LONMIN,LONMAX   '
;RETURN
ENDIF;IF N_ELEMENTS(LATMIN) NE 1 OR N_ELEMENTS(LATMAX) NE 1 $


;ISOTROPIC SHOULD BE ZERO
MAP_SET, /CYLINDRICAL, 0, 0, ISOTROPIC = 0, LIMIT=[LATMIN,LONMIN,LATMAX,LONMAX], POSITION=[0.0, 0.0, 1.0, 1.0],/NOBORDER
END; #####################  END OF ROUTINE ################################

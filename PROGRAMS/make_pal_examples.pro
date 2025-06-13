; $ID:	MAKE_PAL_EXAMPLES.PRO,	2020-07-08-15,	USER-KJWH	$

	PRO MAKE_PAL_EXAMPLES

;+
; NAME:
;		MAKE_PAL_EXAMPLES
;
; PURPOSE:;
;		This procedure reads all of the different palette and creates a colorbar for comparison purposes
;
; CATEGORY:
;
; CALLING SEQUENCE:
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;		This function creates a postscript of colorbars
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written April 6, 2010 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'MAKE_PAL_EXAMPLES'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''

  DIR_PROGRAMS = !S.PROGRAMS
  DIR_IMAGES = !S.IMAGES
  PALS = FILE_SEARCH(DIR_PROGRAMS + 'pal*.pro')
  PSFILE = DIR_IMAGES + 'PAL_COLORBAR_EXAMPLES.PS'
  PSPRINT, FILENAME=PSFILE, /FULL, /COLOR
  !X.OMARGIN = [0,0]
  !Y.OMARGIN = [0.0]
  POS = [0.0,0.0,0.24,0.01]  ; [(X0, Y0), (X1, Y1)], 
  
  FOR NTH = 0L, N_ELEMENTS(PALS)-1 DO BEGIN
    PAL = PALS[NTH] & FP = FILE_PARSE(PAL)
    COLORBAR_TITLE = FP.NAME
    CALL_PROCEDURE,FP.NAME,R,G,B
    CBAR,VMIN=0,VMAX=255,CMIN=0,CMAX=255,CHARSIZE=1.0,XTITLE=COLORBAR_TITLE, POSITION=POS,/TOP
    POS = [POS[0],POS[1]+0.05,POS(2),POS(3)+0.05]
    IF NTH EQ 19 THEN POS = [0.25,0.0,0.49,0.01]
    IF NTH EQ 39 THEN POS = [0.50,0.0,0.74,0.01]
    IF NTH EQ 59 THEN POS = [0.75,0.0,0.99,0.01]      
  ENDFOR
  PSPRINT
  
  PSFILE = DIR_IMAGES + 'PAL_COLORBAR_EXAMPLES-IDL.PS'
  PSPRINT, FILENAME=PSFILE, /FULL, /COLOR
  !X.OMARGIN = [0,0]
  !Y.OMARGIN = [0.0]
  POS = [0.0,0.0,0.48,0.01]  ; [(X0, Y0), (X1, Y1)], 
  FOR NTH = 0L, 39 DO BEGIN
    COLORBAR_TITLE = NUM2STR[NTH]
    LOADCT, NTH
    CBAR,VMIN=0,VMAX=255,CMIN=0,CMAX=255,CHARSIZE=1.0,XTITLE=COLORBAR_TITLE, POSITION=POS,/TOP
    POS = [POS[0],POS[1]+0.05,POS(2),POS(3)+0.05]
    IF NTH EQ 19 THEN POS = [0.51,0.0,0.99,0.01]      
  ENDFOR
  PSPRINT
STOP



	END; #####################  End of Routine ################################

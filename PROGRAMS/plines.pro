; $ID:	PLINES.PRO,	2017-08-23-15,	USER-KJWH	$

	PRO PLINES, LINES, TXT=TXT

;+
; NAME:
;		PLINES
;
; PURPOSE:
;		THIS PROGRAM PRINTS  BLANK LINES TO THE SCREEN[CONSOLE OUTPUT] USING MULTIPLE PRINT COMMANDS
;
; CATEGORY:
;		PRINT/DISPLAY
;
; CALLING SEQUENCE:
;
; INPUTS:
;		LINES:	NUMBER OF BLANK LINES TO PRINT(DEFAULT = 5).
;
; OPTIONAL INPUTS:
;		NONE
;
; KEYWORD PARAMETERS:
;		NONE
;
; OUTPUTS:
; PRINTS '' TO DISPLAY
; 
;
; EXAMPLES:
;       PLINES
;       PLINES,5
;       PLINES,500; WILL CLEAR ENTIRE LOG/CONSOLE DISPLAY
;
; MODIFICATION HISTORY:
; WRITTEN NOVEMBER 4,2010 J O'REILLY, 28 TARZWELL DRIVE, NMFS, NOAA 02882 (JAY.OREILLY@NOAA.GOV)
;   AUG 22, 2017 - KJWH: Added TXT keyword option to include a text string in the middle of the printed lines
;   AUG 24, 2017 - KJWH: Changed PRINT, TXT to PLIST, TXT, /NOHEAD, /NOSEQ to list the txt if there are multiple items
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PLINES'
; ****************************************************************************************************
  ERROR = ''
  IF N_ELEMENTS(LINES) LT 1 THEN LINES = 4

  IF KEY(TXT) THEN BEGIN
    LNS = LINES/2
    FOR N=0, LNS-1 DO PRINT
    PLIST, TXT, /NOSEQ, /NOHEAD
    FOR N=0, LNS-1 DO PRINT
  ENDIF ELSE FOR NTH = 0, LINES-1 DO PRINT

END; #####################  End of Routine ################################

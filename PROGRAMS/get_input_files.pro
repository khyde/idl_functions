; $ID:	GET_INPUT_FILES.PRO,	2020-06-30-17,	USER-KJWH	$

  PRO GET_INPUT_FILES, FILES

;+
; NAME:
;   GET_INPUT_FILES
;
; PURPOSE:
;   This function will create a list of all files used to create the input file.
;
; CATEGORY:
;   CATEGORY
;
; CALLING SEQUENCE:
;
;   TEMPLATE, Parameter1, Parameter2, Foobar
;
;   Result = TEMPLATE(Parameter1, Parameter2, Foobar)
;
; INPUTS:
;   Parm1:  Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;   Parm2:  Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1: Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   This function returns the
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; COMMON BLOCKS: If no common blocks then delete this line
; SIDE EFFECTS:  If no side effects then delete this line
; RESTRICTIONS:  If no restrictions then delete this line
;
; PROCEDURE:
;
; EXAMPLE:
;
; NOTES:
;   This routine will display better if you set your tab to 2 spaces:
;   (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)
;
;   Citations or any other useful notes
;
;   
; COPYRIGHT: 
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          with assistance from John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
; ;   
;
; MODIFICATION HISTORY:
;			Written:  April 18, 2011 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;			Modified: Dec 29, 2015 - KJWH: Added SWITCHES information 
;			          Aug 01, 2018 - KJWH: Added COPYRIGHT
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'GET_INPUT_FILES'
	
	FILE = FLS(!S.FILES + 'M_201404*MODISA*L3B2*CHLOR_A-OCI-STATS.SAV')
	FILE = FLS(!S.OC + 'MODISA/L3B2/STATS/CHLOR_A-OCI/ANNUAL_*STATS.SAV')
	
	IF N_ELEMENTS(FILE) NE 1 THEN MESSAGE,'ERROR: Can only provide one input file at a time' ; Note, may be able to loop through files if use lists
	
	L2S = []
	
	FA = PARSE_IT(FILE,/ALL)
	IF STRUPCASE(FA.EXT) EQ 'SAV' THEN BEGIN
	  D = STRUCT_READ(FILE, STRUCT=S)
	  IF HAS(S,'INFILES') THEN INF = S.INFILES ELSE INF = []
	
	  IF FP.PERIOD_CODE NE 'D' AND FP.PERIOD_CODE NE 'S' THEN BEGIN
	    FI = FILE_PARSE(INF)
	 ;DO THE   OUTSTRING = STRJOIN(SAV_2NC(FI.NAME),'; ')
	    GOTO, DONE
	  ENDIF
	ENDIF 
	

  IF STRUPCASE(FA.EXT) EQ 'SAV' AND FP.PERIOD_CODE EQ 'D' THEN BEGIN
	
	FP = FILE_PARSE(INF)
	IF ~SAME(FP.EXT) THEN MESSAGE, 'ERROR: Input files do not have the same extension'
	
	IF STRUPCASE(FP[0].EXT) EQ 'NC' AND FP.MAP 'L3B2' THEN BEGIN
	  
	  PRINT, 'GET ORIGINAL FILES'
	   
	ENDIF ELSE BEGIN
	  GET_NEXT_LEVEL:
	  INF2 = []
	  FOR F=0, N_ELEMENTS(INF)-1 DO BEGIN
      D2 = STRUCT_READ(INF(F),STRUCT=S2)
      IF HAS(S2,'INFILES') THEN INF2 = [INF2,S2.INFILES]
    ENDFOR
    INF = INF2
    GOTO, RECHECK_FILES  
   
	ENDELSE
	
	GOTO, DONE
	; RETURN, OUTSTRING

END; #####################  End of Routine ################################

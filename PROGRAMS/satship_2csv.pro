; $ID:	SATSHIP_2CSV.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This program converts a SATSHIP structure with arrays to a .csv file 
;
; SYNTAX:
;		SATSHIP_2CSV, FILES
;		
; ARGUMENTS:
; 	Files:	IDL save files containing a SATSHIP structure 
; 	
; EXAMPLE:
;  	SATSHIP = SATSHIP_HDF()
;  	SAVE, FILENAME='SATSHIP.SAV', SATSHIP, /COMPRESS
;   SATSHIP_2CSV,'SATSHIP.SAV'
;
; VERSION:
;		May 8, 2015
;		
; HISTORY:
;		May 8, 2015	Written by:	K.J.W. Hyde, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO SATSHIP_2CSV, FILES
  ROUTINE_NAME='SATSHIP_2CSV'

  IF N_ELEMENTS(FILES) LT 1 THEN $
  FILES = DIALOG_PICKFILE(FILTER='*.SAV*',TITLE='Pick  SAVE Files',/MULTIPLE_FILE)

;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR _FILE=0L,N_ELEMENTS(FILES)-1L DO BEGIN
   	AFILE = FILES(_FILE)
   	FN    = FILE_PARSE(AFILE)
   	OUTFILE=FN.DIR+FN.NAME+'.CSV'
   	
   	STRUCT =	IDL_RESTORE(AFILE)
   	TEMP   = STRUCT[0]                                                                         ; Copy structure to get the tagnames
   	TEMP   = STRUCT_2MISSINGS(TEMP)                                                            ; Make structure missing
   	TEMP   = STRUCT_RETYPE(TEMP, 'STRING')                                                     ; Change structure type to string
   	TEMP   = REPLICATE(TEMP,N_ELEMENTS(STRUCT))                                                ; Replicate structure
   	TAGS   = TAG_NAMES(TEMP)                                                                   ; Get tag names
   	FOR N=0, N_ELEMENTS(TAGS)-1 DO BEGIN                                                       ; Loop on tags
   	  IF SIZE(STRUCT.(N), /N_DIMENSIONS) EQ 1 THEN TEMP.(N) = STRTRIM(STRUCT.(N),2) ELSE BEGIN ; If data are in a single dimension, then just copy
   	    FOR S=0, N_ELEMENTS(STRUCT)-1 DO BEGIN                                                 ; Loop through rows in the structure
   	      STR = STRUCT(S).(N)                                                                  ; Get data
   	      ARR = REFORM(STR,N_ELEMENTS(STR))                                                    ; Convert x by x array to a 1 by x array
   	      OK = WHERE(ARR EQ MISSINGS(ARR),COUNT_MISS)                                          ; Find where data are missing
   	      SARR = STRTRIM(ARR,2)                                                                ; Trim missing data and convert to string
   	      IF COUNT_MISS EQ N_ELEMENTS(ARR) THEN CONTINUE                                       ; Don't fill in if all values are missing
   	      IF COUNT_MISS GT 0 THEN SARR[OK] = ' '                                               ; Replace missing data with blanks
   	      TEMP[S].(N) = STRJOIN(SARR,';')                                                      ; Join array into a single string
   	    ENDFOR
   	  ENDELSE
   	ENDFOR
    CSV_WRITE, OUTFILE, TEMP
  ENDFOR
 END; #####################  End of Routine ################################

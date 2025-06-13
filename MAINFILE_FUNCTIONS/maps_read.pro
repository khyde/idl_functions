; $ID:	MAPS_READ.PRO,	2023-09-21-13,	USER-KJWH	$
;+
	FUNCTION MAPS_READ, MAPP, NAMES=NAMES, INIT=INIT, TRUE=TRUE
;	
; NAME:
;		MAPS_READ
;
; PURPOSE: THIS FUNCTION RETURNS DATA FROM THE MAPS MAIN IN A STRUCTURE 
;
; CATEGORY:
;		MAP_FUNCTIONS
;		 
; CALLING SEQUENCE:
;   RESULT = MAPS_READ(TXT)
;
; INPUTS:
;		MAPPS:	Name(s) of maps (e.g. [NES,EC,L3B2]) 
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;  NAMES..... RETURN JUST THE MAP NAME
;  INIT...... FORCES A REREADING OF THE MAPS_MAIN
;  TRUE...... SELECT MAPS WITH INIT = MAP_SET [ NOT L3B ETC.]
;
; OUTPUTS: 
;   A structure with the map information
;		
; EXAMPLES:
;  MAPS =  MAPS_READ() & HELP,MAPS
;  MAPS =  MAPS_READ(/NAMES) & HELP,MAPS
;  MAPS =  MAPS_READ(/NAMES,/TRUE) & HELP,MAPS
;  D = MAPS_READ(['NEC','SMI']) & PN,D
;  D = MAPS_READ(/TRUE) & PN,D
;
; COPYRIGHT:
; Copyright (C) 1999, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on October 10, 2013 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;
; MODIFICATION HISTORY:
;			OCT 15, 2013 - JEOR: RENAMED TO MAPS_READ
;			NOV 04, 2013 - JEOR: MAIN = GET_PATH() + 'IDL\DB\MAP_DATA_MAIN_DB.SAVE'
;                          REPLACED WHERE_IN WITH WHERE_MATCH [ TO KEEP OUTPUT ORDER IN SYNC WITH INPUT ORDER]
;     NOV 10, 2013 - JEOR: MAIN = !S.IDL_MAINFILES + 'MAPS_MAIN.SAVE'
;     NOV 19, 2013 - JEOR: MAPS = STRUPCASE(MAPS); ADDED KEYWORD NAMES
;     JAN 18, 2014 - JEOR: RENAMED READ_MAPS TO MAPS_READ FOR CONSISTENCY
;     JAN 19, 2014 - JEOR: MODIFIED TO USE THE NEW MAPS_MAIN.csv
;     JAN 21, 2014 - JEOR: FIXED IF COUNT GE 1 THEN RETURN, DB[OK]
;     DEC 08, 2014 - JEOR: USING NEW FUNCTIONS
;     DEC 10, 2014 - JEOR: IF KEY(NAMES) THEN RETURN,DB(SORT(DB.MAP)).MAP
;                          IF NONE(MAPS) THEN  RETURN,DB(SORT(DB.MAP))
;     FEB 08, 2016 - JEOR: ADDED KEY TRUE. REINIT TO COMMON
;     OCT 07, 2016 - KJWH: Added REINIT=0 if not KEY(TRUE) - Not sure if this is correct, but because REINIT = 1, it keep rereading the MAIN csv file instead of using the DB in COMMON memory
;     JUL 16, 2020 - KJWH: Added COMPILE_OPT IDL2
;                          Changed subscript () to []
;                          Updated formatting
;                          Changed the input MAPS to MAPP to avoid conflicts with IDL's MAPS functions
;-
;************************************************************************************************************
  ROUTINE_NAME  = 'MAPS_READ'
  COMPILE_OPT IDL2

  COMMON _MAPS_READ,DB,MTIME_LAST,REINIT
  
  IF NONE(REINIT) THEN REINIT = 1
  MPMAIN = !S.IDL_MAINFILES + 'MAPS_MAIN.csv'
  IF NONE(MTIME_LAST) THEN MTIME_LAST = GET_MTIME(MPMAIN)
  IF GET_MTIME(MPMAIN) GT  MTIME_LAST THEN INIT = 1
  IF NONE(DB) OR KEYWORD_SET(INIT) OR REINIT EQ 1 THEN BEGIN
    DB = CSV_READ(MPMAIN,/STRING)
    MTIME_LAST = GET_MTIME(MPMAIN)
    OK = WHERE(DB.MAP EQ '',COUNT) & IF COUNT GE 1 THEN DB = REMOVE(DB,OK)
  ENDIF;IF NONE(DB) OR KEYWORD_SET(INIT)OR KEY(TRUE) THEN BEGIN
  
  IF KEY(TRUE) THEN BEGIN
    OK = WHERE(DB.INIT EQ 'MAP_SET',COUNT)
    IF COUNT GE 1 THEN DB = DB[OK] 
    REINIT = 1
  ENDIF ELSE BEGIN
    REINIT = 0 ; Added by KH on October 7th, 2016 - Not sure if this is correct, but trying to keep MAPS_READ from continually rereading the MAIN csv file
    TRUE = 0;IF KEY(TRUE) THEN BEGIN
  ENDELSE;IF KEY(TRUE) THEN BEGIN
  
  
  IF KEY(NAMES) THEN RETURN,DB[SORT(DB.MAP)].MAP
  IF NONE(MAPP) THEN  RETURN,DB[SORT(DB.MAP)]
   
  MAPP = STRUPCASE(MAPP)
  OK = WHERE_MATCH(DB.MAP, MAPP,COUNT)
  IF COUNT EQ 0 THEN RETURN,'ERROR: MAPS ' + MAPP + '  NOT FOUND'
  RETURN, DB[OK]
         
END; #####################  END OF ROUTINE ################################

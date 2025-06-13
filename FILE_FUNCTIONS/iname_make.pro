; $ID:	INAME_MAKE.PRO,	2023-09-21-13,	USER-KJWH	$
FUNCTION INAME_MAKE, PERIOD=PERIOD, SENSOR=SENSOR, METHOD=METHOD, COVERAGE=COVERAGE, MAP=MAP, SAT_EXTRA=SAT_EXTRA

;+
;	NAME:
;	  INAME_MAKE
;	
;	PURPOSE:
;	  This function returns an iname from valid file name components (e.g. PERIOD, SENSOR, PROD, ALG)
;
; CATEGORY:
;   FILE_FUNCTIONS
;
; CALLING SEQUENCE:
;   INAME_MAKE
;
; REQUIRED INPUTS:
;   None
;
; OPTIONAL INPUTS:
;   PERIOD......... Valid file "period" array
;   SENSOR......... Valid file "sensor" array
;   METHOD......... Valid file "method" array
;   COVERAGE....... Valid file "coverage" array
;   MAP............ Valid file "map" array
;   SAT_EXTA....... Other valid file information 
;
; KEYWORD PARAMETERS:
;   None
;
; OUTPUTS:
;   Creates an "INAME" based on the inputs
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   None
;
; RESTRICTIONS:
;   None
;
; EXAMPLES:
;    PRINT, INAME_MAKE(PERIOD='D_19970508', SENSOR='OCTS',MAP='GEQ')
;    If any component is not valid then return '' 
;      HELP,FIRST(INAME_MAKE(PERIOD='D_19970508', SENSOR='OCTS',METHOD='CATAPULT'))
;    
; NOTES:
;   
;   
; COPYRIGHT:
; Copyright (C) 2003, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on Jun 12, 2003 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
;    
; MODIFICATION HISTORY:
;		JUN 12, 2003 - JEOR: Initial code written
;   JUL 15, 2008 - TD:   Added COVERAGE
;   FEB 18, 2014 - KJWH: Removed reference to OLD_PARSER
;   OCT 19, 2015 - JEOR: Now uses VALIDS 
;                        Note - COVERAGE is not a part of the iname
;   OCT 21, 2015 - JEOR: Added IF N_ELEMENTS(SATELLITE) NE N OR N_ELEMENTS(SENSOR) NE N OR SATELLITE EQ '' OR SENSOR EQ ''  THEN RETURN,''
;   OCT 22, 2015 - KJWH: Fixed error with V_PERIODS to look for a structure  
;                        Added METHOD, COVERAGE AND MAP keywords because SAT_EXTRA only works with a single parameter (i.e. you could not include both METHOD and COVERAGE in SAT_EXTRA)
;                        Changed the logic so that it is not necessary to include all of the parts of the name (i.e. you can exclude the PERIOD or SATELLITE)
;   NOV 03, 2015 - KJWH: Fixed bug with removing the last DELIM from the INAME when there were multiple inames by adding:
;                          FOR N=0, N_ELEMENTS(INAME)-1 DO INAME[N] = STRMID(INAME[N], 0, STRLEN(INAME[N]) - (STRPOS(INAME(N),DELIM,/REVERSE_OFFSET) + 1 EQ STRLEN(INAME(N))))                       
;   NOV 30, 2021 - KJWH: Updated documentation and formatting
;                        Moved to FILE_FUNCTIONS
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;                        Removed SATELLITES from the name
;                        Now determining N by determining the "MAX" array size
;- 
; *********************************************************************************************************************************

  ROUTINE_NAME='INAME_MAKE'
  COMPILE_OPT IDL2
  DELIM = DELIMITER(/DASH)
  
; ===> Determine the number of INAMES to create  
  N = MAX([N_ELEMENTS(PERIOD),N_ELEMENTS(SENSOR),N_ELEMENTS(METHOD),N_ELEMENTS(COVERAGE),N_ELEMENTS(MAP)])
  IF N EQ 0 THEN RETURN, ''
                 
;===> Check PERIOD info  
  IF N_ELEMENTS(PERIOD) THEN V_PERIODS = VALIDS('PERIODS',PERIOD) ELSE V_PERIODS = REPLICATE('',N)
  IF IDLTYPE(V_PERIODS) EQ 'STRUCT' THEN V_PERIODS = V_PERIODS.PERIOD

;===> Check SENSOR info
  IF N_ELEMENTS(SENSOR) THEN V_SENSORS = VALIDS('SENSORS',SENSOR) ELSE V_SENSORS = REPLICATE('',N)
  
;===> Check METHOD info
  IF N_ELEMENTS(METHOD) THEN V_METHODS = VALIDS('METHODS',METHOD) ELSE V_METHODS = REPLICATE('',N)
  
;===> Check COVERAGE info
  IF N_ELEMENTS(COVERAGE) THEN V_COVERAGES = VALIDS('COVERAGE',COVERAGE) ELSE V_COVERAGES = REPLICATE('',N)
  
;===> Check MAP info
  IF N_ELEMENTS(MAP) THEN V_MAPS = VALIDS('MAPS',MAP) ELSE V_MAPS = REPLICATE('',N)

;===> Check SAT_EXTRA info
  IF N_ELEMENTS(SAT_EXTRA) EQ N THEN BEGIN
  	V_SAT_EXTRAS = VALIDS('SAT_EXTRAS',SAT_EXTRA)
  ENDIF ELSE V_SAT_EXTRAS = REPLICATE('',N)

  _DELIM = REPLICATE('',N)
  OK = WHERE(V_SAT_EXTRAS NE MISSINGS(V_SAT_EXTRAS),COUNT)
  IF COUNT GE 1 THEN _DELIM[OK] = DELIM

  INAME = REPLICATE('',N)
  OK = WHERE(V_PERIODS    NE MISSINGS(V_PERIODS),   COUNT) & IF COUNT GE 1 THEN INAME[OK] = INAME[OK] + STRTRIM(V_PERIODS[OK],2)    + DELIM
  OK = WHERE(V_SENSORS    NE MISSINGS(V_SENSORS),   COUNT) & IF COUNT GE 1 THEN INAME[OK] = INAME[OK] + STRTRIM(V_SENSORS[OK],2)    + DELIM
  OK = WHERE(V_METHODS    NE MISSINGS(V_METHODS),   COUNT) & IF COUNT GE 1 THEN INAME[OK] = INAME[OK] + STRTRIM(V_METHODS[OK],2)    + DELIM
  OK = WHERE(V_COVERAGES  NE MISSINGS(V_COVERAGES), COUNT) & IF COUNT GE 1 THEN INAME[OK] = INAME[OK] + STRTRIM(V_COVERAGES[OK],2)  + DELIM
  OK = WHERE(V_MAPS       NE MISSINGS(V_MAPS),      COUNT) & IF COUNT GE 1 THEN INAME[OK] = INAME[OK] + STRTRIM(V_MAPS[OK],2)       + DELIM
  OK = WHERE(V_SAT_EXTRAS NE MISSINGS(V_SAT_EXTRAS),COUNT) & IF COUNT GE 1 THEN INAME[OK] = INAME[OK] + STRTRIM(V_SAT_EXTRAS[OK],2)
  
  FOR N=0, N_ELEMENTS(INAME)-1 DO INAME[N] = STRMID(INAME[N], 0, STRLEN(INAME[N]) - (STRPOS(INAME[N],DELIM,/REVERSE_OFFSET) + 1 EQ STRLEN(INAME[N])))
   
RETURN,INAME

END; #####################  END OF ROUTINE ################################

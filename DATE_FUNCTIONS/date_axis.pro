; $ID:	DATE_AXIS.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION DATE_AXIS, JD_OR_DATE, YEAR=YEAR, 	MONTH=MONTH, DAY=DAY, HOUR=HOUR, MINUTE=MINUTE, SECOND=SECOND,$
  																CYEAR=CYEAR, FYEAR=FYEAR, YY_YEAR=YY_YEAR, NO_MONTH_YEAR=NO_MONTH_YEAR,$
  																ROOM=ROOM, 	ENDS=ENDS, STEP_SIZE=STEP_SIZE, MID=MID, MAX_LABELS=MAX_LABELS, _EXTRA=_EXTRA
  														  	
;+
; NAME:
;   DATE_AXIS
;
; PURPOSE:
;   Construct date axis labels for ploting
;
; CATEGORY:
;   DATE_FUNCTIONS
;
; CALLING SEQUENCE:
;   RESULTS = DATE_AXIS(JD_OR_DATE)
;
; REQUIRED INPUTS:
;   JD_OR_DATES... An array of Julian Day or Date string (e.g. YYYY, YYYYMM, YYYYMMDD, YYYYMMDDHH, YYYYMMDDHHMM, YYYYMMDDHHMMSS)
;
; OPTIONAL INPUTS:
;   _EXTRA........ Other valid parameters passed to a PLOT routine
;
; KEYWORD PARAMETERS:
;   YEAR.......... Return YEAR axis labels
;   MONTH......... Return MONTH axis labels (/MONTH or MONTH=1, MONTH=2, MONTH=3); MONTH=4 or higher returns the full month name (e.g. January)
;   DAY........... Return DAY axis labels
;   HOUR.......... Return HOUR axis labels
;   MINUTE........ Return MINUTE axis lables
;   SECOND........ Return SECOND axis labels
;   CYEAR......... Current year
;   FYEAR......... Future year when no year lables are desired (used for climatologies)
;   YY_YEAR....... Only use the last two digits of the year
;   NO_MONTH_YEAR.
;   ROOM..........
;   ENDS.......... Forces the lower level 2 axis lables to appear only at the left and right ends of the axis 
;   STEP_SIZE.....
;   MID........... Place the ticks in the middle of the range (e.g. on the 15th day of a month)
;   MAX_LABELS....

;   
;
; OUTPUTS:
;   A structure containing values for the axis TICKS, TICKV, TICKNAMES to be used with the plotting routine
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
;   JD_OR_DATE: Must be julian day or date string (YYYY, YYYYMM, YYYYMMDD, YYYYMMDDHH, YYYYMMDDHHMM, YYYYMMDDHHMMSS)
;
; EXAMPLES:
; ===> YEAR AXIS
;   JD=TIMEGEN(14,UNITS='YEAR',START=JULDAY(1,1,2000,0)) & Y=INDGEN(N_ELEMENTS(JD))
;   AX=DATE_AXIS(JD,/YEAR)
;   P=PLOT(AX.JD,Y, XMAJOR=AX.TICKS,XTICKNAME=AX.TICKNAME,XTICKV=AX.TICKV,/XSTYLE, XTITLE=AX.TITLE,XMINOR = 0)
;
; ===> MONTH AXIS
;   JD=TIMEGEN(14,UNITS='MONTH',START=JULDAY(1,1,2000,0)) & Y=INDGEN(N_ELEMENTS(JD))
;   AX=DATE_AXIS(JD,/MONTH)
;   P=PLOT(AX.JD,Y, XMAJOR=AX.TICKS,XTICKNAME=AX.TICKNAME,XTICKV=AX.TICKV,/XSTYLE, XTITLE=AX.TITLE,XMINOR = 0)

; ===> DAY AXIS
;   JD=TIMEGEN(31,UNITS='DAY',START=JULDAY(1,1,2000,0)) & Y=INDGEN(N_ELEMENTS(JD))
;   AX=DATE_AXIS(JD,/DAY)
;   P=PLOT(AX.JD,Y, XMAJOR=AX.TICKS,XTICKNAME=AX.TICKNAME,XTICKV=AX.TICKV,/XSTYLE, XTITLE=AX.TITLE,XMINOR = 0)

;===> YY_YEAR
;   JD=TIMEGEN(14,UNITS='YEAR',START=JULDAY(1,1,2000,0)) & Y=INDGEN(N_ELEMENTS(JD))
;   AX=DATE_AXIS(JD,/YEAR,/YY_YEAR)
;   P=PLOT(AX.JD,Y, XMAJOR=AX.TICKS,XTICKNAME=AX.TICKNAME,XTICKV=AX.TICKV,/XSTYLE, XTITLE=AX.TITLE,XMINOR = 0)
;
; NOTES:
;   
;
; COPYRIGHT:
; Copyright (C) 1999, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on July 09, 1999 by John E. O'Reilly, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     All inquires should be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;   JUL 09, 1999 - JEOR: Initial code written
;   OCT 09, 2003 - JEOR: Added CYEAR - Suppresses the year from the axis title
;	  MAR 13, 2004 - JEOR: Now accepts JULIAN DAY or DATE
;	                       Updated documentation
;	                       Updated routine
;		JUN 09, 2011 - KJWH: Added YY_YEAR keyword to change the 4 digit year to a 2 digit year in the month option
;   NOV 13, 2014 - JEOR: Changed FYEAR = 2020 to FYEAR = 2100
;                        Updated formatting
;                        Using new logic functions
;                        Added examples                      
;   DEC 21, 2017 - KJWH: Updated Formatting
;   FEB 02, 2021 - KJWH: Updated documentation and formatting
;                        Moved to DATE_FUNCTIONS
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;-
;*************************************************************************************************************************
  ROUTINE_NAME = 'DATE_AXIS'
  COMPILE_OPT IDL2

; ===> If dates not provided then assume CYEAR (current year)
  IF NONE(JD_OR_DATE) THEN BEGIN
	  IF N_ELEMENTS(FYEAR) EQ 0 OR N_ELEMENTS(CYEAR) EQ 1 THEN BEGIN ;     ===> Current year
  		CYEAR = 1
  		_YEAR = STRING(SYSTIME(/JULIAN,/UTC),FORMAT='(C(CYI4))')
	  ENDIF	ELSE _YEAR = 2100                                        ;     ===> Use future year 2100
      FIRST_JULIAN = JULDAY(1, 1, _YEAR,0,0,0)
    	LAST_JULIAN  = JULDAY(12,31,_YEAR,23,59,59);
    	JD_OR_DATE=[FIRST_JULIAN,LAST_JULIAN]
   ENDIF ELSE BEGIN
  	IF N_ELEMENTS(JD_OR_DATE) EQ 1 THEN JD_OR_DATE = [JD_OR_DATE,JD_OR_DATE]
  ENDELSE

;	===> STEP_SIZE
	IF N_ELEMENTS(STEP_SIZE) EQ 1 THEN _STEP_SIZE = STEP_SIZE ELSE _STEP_SIZE = 1

; ===> ROOM TO LEFT AND RIGHT ?
  IF N_ELEMENTS(ROOM) EQ 0 THEN ROOM = [0,0]
  IF N_ELEMENTS(ROOM) EQ 1 THEN ROOM = [ROOM,ROOM]
  MAC= MACHAR()
  LEFT= -1*ROOM[0] & RIGHT= 1*ROOM[1]+MAC.EPS

;	===> IF NONE OF THESE SET THEN DEFAULT TO MONTH TICK LABELS
  IF NOT KEYWORD_SET(YEAR)   AND NOT KEYWORD_SET(MONTH) AND $
     NOT KEYWORD_SET(DAY)    AND NOT KEYWORD_SET(HOUR)  AND $
     NOT KEYWORD_SET(MINUTE) AND NOT KEYWORD_SET(SECOND) THEN MONTH=1;

	IF N_ELEMENTS(MAX_LABELS) EQ 0 THEN MAX_LABELS = 60

; ===> GET THE DATA TYPE FOR DATES
  TYPE = IDLTYPE(JD_OR_DATE,/CODE)

; ===> IF JD_OR_DATE IS FLOATING OR DOUBLE THEN ASSUME JD_OR_DATE IS JULIAN DAY ELSE IT IS DATE
  IF TYPE EQ 4 OR TYPE EQ 5 THEN JD=JD_OR_DATE ELSE JD= DATE_2JD(JD_OR_DATE)

; ===> SORT JD
  JD = JD[SORT(JD)] & FIRST_JD=MIN(JD) &  LAST_JD=MAX(JD)

;	===> GENERATE FIRST AND LAST JD'S
	IF KEYWORD_SET(YEAR) THEN BEGIN
		UNITS='YEAR'
 		_FIRST_JD		=	JD_ADD(JD_2JD(FIRST_JD,/YEAR,/START),LEFT,/YEAR)
 		_LAST_JD		=	JD_ADD(JD_2JD(LAST_JD,/YEAR,/ENDOF),RIGHT,/YEAR)
 		IF KEYWORD_SET(MID) THEN BEGIN
      _FIRST_JD   = JD_ADD(_FIRST_JD,0.5,/YEAR)
      _LAST_JD    = JD_ADD(_LAST_JD, 0.5,/YEAR)
    ENDIF
 	ENDIF

 	IF KEYWORD_SET(MONTH) THEN BEGIN
 		UNITS='MONTH'
 		_FIRST_JD		=	JD_ADD(JD_2JD(FIRST_JD,/MONTH,/START),LEFT,/MONTH)
 		_LAST_JD		=	JD_ADD(JD_2JD(LAST_JD,/MONTH,/ENDOF),RIGHT,/MONTH)
 		IF KEYWORD_SET(MID) THEN BEGIN
 		  _FIRST_JD   = JD_ADD(_FIRST_JD,14,/DAY)
      _LAST_JD    = JD_ADD(_LAST_JD, 14,/DAY)
 		ENDIF
 	ENDIF

	IF KEYWORD_SET(DAY) THEN BEGIN
		UNITS='DAY'
 		_FIRST_JD		=	JD_ADD(JD_2JD(FIRST_JD,/DAY,/START),LEFT,/DAY)
 		_LAST_JD		=	JD_ADD(JD_2JD(LAST_JD,/DAY,/ENDOF),RIGHT,/DAY)
 	ENDIF

	IF KEYWORD_SET(HOUR) THEN BEGIN
		UNITS='HOUR'
 		_FIRST_JD		=	JD_ADD(JD_2JD(FIRST_JD,/HOUR,/START),LEFT,/HOUR)
 		_LAST_JD		=	JD_ADD(JD_2JD(LAST_JD,/HOUR,/ENDOF),RIGHT,/HOUR)
 	ENDIF

	IF KEYWORD_SET(MINUTE) THEN BEGIN
		UNITS='MINUTE'
 		_FIRST_JD		=	JD_ADD(JD_2JD(FIRST_JD,/MINUTE,/START),LEFT,/MINUTE)
 		_LAST_JD		=	JD_ADD(JD_2JD(LAST_JD,/MINUTE,/ENDOF),RIGHT,/MINUTE)
 	ENDIF

	IF KEYWORD_SET(SECOND) THEN BEGIN
		UNITS='SECOND'
 		_FIRST_JD		=	JD_ADD(JD_2JD(FIRST_JD,/SECOND,/START),LEFT,/SECOND)
 		_LAST_JD		=	JD_ADD(JD_2JD(LAST_JD,/SECOND,/ENDOF),RIGHT,/SECOND)
 	ENDIF

; ===> MAKE THE JD SERIES
  ARR= TIMEGEN(START=_FIRST_JD,FINAL=_LAST_JD,UNITS=UNITS,STEP_SIZE=_STEP_SIZE)

; *******************************************************************
; ===> THIN THE NUMBER OF LABELS TO LE 60 (IDL LIMIT) OR LE MAX_LABELS
  WHILE N_ELEMENTS(ARR) GT MAX_LABELS DO BEGIN & ARR=SUBSAMPLE(ARR,2) & ENDWHILE

; ===> FORMAT THE LEVEL 1 AND LEVEL 2 AXIS LABEL STRINGS
  IF UNITS EQ 'SECOND' THEN BEGIN
  	L1_TXT = STRING(ARR,FORMAT= "(C(CSI2.2))")
  	L2_TXT = STRING(ARR,FORMAT= "(C(CMOA3,' 'CDI2.1,', ',CYI,' ',CHI2.1,'H ',CMI2.1,'M'))")
  ENDIF
  IF UNITS EQ 'MINUTE' THEN BEGIN
  	L1_TXT = STRING(ARR,FORMAT= "(C(CMI2.1))")
  	L2_TXT = STRING(ARR,FORMAT= "(C(CMOA3,' 'CDI2.1,', ',CYI,' ',CHI2.1,'H'))")
  ENDIF
  IF UNITS EQ 'HOUR' THEN BEGIN
  	L1_TXT = STRING(ARR,FORMAT= "(C(CHI2.1))")
  	L2_TXT = STRING(ARR,FORMAT= "(C(CMOA3,' 'CDI2.1,', ',CYI))")
  ENDIF
  IF UNITS EQ 'DAY' THEN BEGIN
  	L1_TXT = STRING(ARR,FORMAT= "(C(CDI2.1))")
  	L2_TXT = STRING(ARR,FORMAT= "(C(CMOA3,' ',CYI))")
  ENDIF
  IF UNITS EQ 'MONTH' THEN BEGIN
   IF MONTH LE 3 THEN FMT = "(C(CMOA" + STRTRIM(MONTH,2)+"))" ELSE FMT = "(C(CMOA0))"
  	L1_TXT = STRING(ARR,FORMAT= FMT)
  	L2_TXT = STRING(ARR,FORMAT= "(C(CYI))")
  	IF KEYWORD_SET(YY_YEAR) THEN L2_TXT = STRING(ARR,FORMAT= "(C(CYI2))") 
  	IF KEYWORD_SET(NO_MONTH_YEAR) THEN L2_TXT = REPLICATE('',N_ELEMENTS(L1_TXT))
  ENDIF
  IF UNITS EQ 'YEAR' THEN BEGIN
  	L1_TXT = STRING(ARR,FORMAT= "(C(CYI))")
  	IF KEYWORD_SET(YY_YEAR) THEN L1_TXT = STRING(ARR,FORMAT= "(C(CYI2))") 
  	L2_TXT = REPLICATE('',N_ELEMENTS(L1_TXT))
  ENDIF

;	===> REMOVE REDUNDANT L2_TXT AXIS LABELS
	IF NOT KEYWORD_SET(ENDS) THEN BEGIN
  	START = FIRST(L2_TXT)
  	SUBS = 0L
  	FOR NTH = 1,N_ELEMENTS(L2_TXT)-1 DO BEGIN
  		IF L2_TXT[NTH] EQ START THEN BEGIN
  			START=L2_TXT[NTH]
  			L2_TXT[NTH] = ''
  		ENDIF ELSE START=L2_TXT[NTH]
  	ENDFOR
  ENDIF ELSE BEGIN
  	TXT=REPLICATE('',N_ELEMENTS(L2_TXT))
  	LAST_SUB = N_ELEMENTS(L2_TXT)-1
  	TXT[0]=L2_TXT[0] & TXT[LAST_SUB]=L2_TXT[LAST_SUB]
  	L2_TXT=TXT
  ENDELSE

;	===> MAKE TITLE UPPER CASE FOR FIRST LETTER ONLY
  TITLE=STRUPCASE(STRMID(UNITS,0,1)) + STRLOWCASE(STRMID(UNITS,1))

  IF N_ELEMENTS(FYEAR) EQ 0 THEN STRUCT =  CREATE_STRUCT('TITLE',TITLE,'JD',JD,'TICKS',N_ELEMENTS(ARR)-1L,'TICKV',ARR ,'TICKNAME',L1_TXT+'!C'+L2_TXT ) $
                            ELSE STRUCT =  CREATE_STRUCT('TITLE',TITLE,'JD',JD,'TICKS',N_ELEMENTS(ARR)-1L,'TICKV',ARR ,'TICKNAME',L1_TXT )
  
  RETURN, STRUCT


END; #####################  END OF ROUTINE ################################

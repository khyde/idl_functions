; $ID:	FILE_ALL.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;############################################################################
FUNCTION FILE_ALL,FILES,PARAM2,_EXTRA=_EXTRA

;PURPOSE: THIS FUNCTION PARSES FILE NAMES INTO ALL OF ITS COMPONENTS
; SYNTAX:	RESULT = FILE_ALL(FILES)
;	
; OUTPUT:	STRUCTURE ARRAY WITH INFORMATION ABOUT THE FILES
;	
; ARGUMENTS:	FILES:	FULL FILE NAMES
; 
; KEYWORDS:	NONE:
;	
; EXAMPLE:
;		ST, FILE_ALL('S_20030820213554-SEAWIFS-OV2-MLAC-R2010-L2.hdf')
;   ST, FILE_ALL('ANNUAL_1996_2014-OSTAM-2010_12-SMI-CHLOR_A-MEAN.SAVE')
; CATEGORY:
;		FILES
;	NOTES:
;		WHEN THE RESOLUTION OF THE TIME PERIOD IS MONTHS THEN YEAR 2021 WILL BE ASSIGNED
;
;			DATE_START='19970904000000' ; FIRST DAY OF SEAWIFS
;			DATE_END  ='20101231235959'	; OPTIMISTIC
;
; MODIFICATION HISTORY:
;		FEB 21, 2001	WRITTEN BY:	J.O'REILLY & T. DUCAS
;	  JUNE 4, 2002 TD, ADD 'VAL','UNIQ','SIGNIF' TO STAT TYPES,  ADD 'YP','YPS' TO PERIODS
;		JUNE 24, 2002 JOR, ADDED '_DAY_'  (DAY) TO VALID PERIOD TYPES
;		JULY 3, TD, ADDED 'MO' (MONTH FOR L3B) PERIOD TYPE
;		JULY 25, 2002 JOR TD,  CONVENTION: DATE= YYYYMMDD  ; DT = YYYYMMDDHHMMSS
;		JAN 14,2003,TD ADD PERIOD 'DIAG' (DIAGNOSTIC SET)
;		JUNE 12, 2003 USING FILE_LABEL_PARSE, AND STREAMLINED PROGRAM WITH STRUCT_MERGE
;   NOV 18, 2010  DWM - CHANGED TO WORK WITHOUT '!' IN PERIOD CODES.  REQUIRE /OLD_PARSER
;                 KEYWORD TO FILE_ALL FOR SOME FILE LISTS.
;   JAN 28, 2011  DWM - MODIFIED TO DETECT '!' IN FILES FOR PROCESSING OLD PERIOD CODES,
;                 SIMPLIFIED OLD_PARSER LOGIC IN CALL TO PARSE_IT.		
;   FEB 18, 2014  KJWH - REMOVED REFERENCE TO OLD_PARSER   
;   FEB 18,2014,JOR -REMOVED SECOND EXIST FROM OUTPUT STRUCTURE 
;   FEB 12,2015,JOR, ADDED BACK MTIME TO STRUCT 
;   FEB 23,2015,JOR PARSE PZ  
;############################################################################
;-
  
;***************************  
ROUTINE_NAME='FILE_ALL.PRO'
;***************************

   IF N_ELEMENTS(PARAM2) EQ 0 THEN BEGIN
     IF STRPOS(FILES[0],'*') GE 0 THEN FILES_ALL = FILE_SEARCH(FILES,_EXTRA=_EXTRA) ELSE FILES_ALL = FILES
   ENDIF ELSE BEGIN
   	 IF STRPOS(FILES[0],'*') GE 0 OR STRPOS(PARAM2[0],'*') GE 0 THEN FILES_ALL = FILE_SEARCH(FILES,PARAM2,_EXTRA=_EXTRA) ELSE FILES_ALL = FILES
   ENDELSE

;*************************************************************  
FN = PARSE_IT(FILES_ALL,/ALL)

FI = FILE_INFO(FILES_ALL) &  FI=STRUCT_COPY(FI,TAGNAMES=['NAME','MTIME','EXIST','SIZE'],/REMOVE)
S=CREATE_STRUCT('ADATE','','CDATE','','MDATE','') & S =REPLICATE(S,N_ELEMENTS(FN))


ALL = STRUCT_MERGE(FN,FI)
ALL = STRUCT_MERGE(ALL,S) 
ALL = STRUCT_REMOVE(ALL,['EXISTS$2','MTIME$2'])
RETURN,ALL

END; #####################  END OF ROUTINE ################################

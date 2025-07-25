; $ID:	CHL_PROFILES_READ.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION CHL_PROFILES_READ,PNUM,S=S,INIT=INIT

; PURPOSE: THIS FUNCTION READS DATA FROM !S.MASTER + CHL_PROFILES-MASTER.SAV
; 
; CATEGORY:	CHL_PROFILES;		 
;
; CALLING SEQUENCE: RESULT = CHL_PROFILES_READ()
;
; INPUTS:  PNUM   RETURN ALL RECORDS FOR A PROFILE NUMBER (PNUM)
;		
; KEYWORD PARAMETERS:       
;         S   : WHEN USED BY ITSELF RETURNS ALL SUFACE RECORDS FOR ALL PROFILES 
;         S   : WHEN USED WITH PNUM RETURNS JUST THE SUFACE RECORD FOR A SINGLE PROFILE 
;         INIT: INITIALIZES THE DATABASE STORED IN COMMON MEMORY
; OUTPUTS: 
;         DEPENDS ON THE ABOVE PARAMETERS AND KEYS USED
;		
;; EXAMPLES:
;     S=CHL_PROFILES_READ() & PN,S      ; ENTIRE DATABASE
;     S=CHL_PROFILES_READ(/S) & PN,S    ; ALL THE SURFACE RECORDS
;     S=CHL_PROFILES_READ(5) & PN,S     ; ALL RECORDS FOR A SINGLE PROFILE 
;     S=CHL_PROFILES_READ(5,/S) & PN,S  ; A SINGLE SURFACE RECORD
;     
;     S=CHL_PROFILES_READ(700000) & PN,S     ;ERROR  PNUM OUTSIDE ALLOWABLE RANGE 
; 

;	NOTES:

;
; MODIFICATION HISTORY:
;			WRITTEN SEP 25, 2014 J.O'REILLY
;			SEP 30,2014,JOR ADDED KEYS PNUM,S  MESSAGE
;			OCT 4,2014,JOR EXPANDED COMMON BLOCK TO ENHANCE SPEED  
;			
;#################################################################################
;-
;**********************************
ROUTINE_NAME  = 'CHL_PROFILES_READ'
;**********************************
COMMON CHL_PROFILES,SAV,ALL_SURFACE,SURF_LON,SURF_LAT,SURF_DOY,SURF_CHL


;===> READ THE ENTIRE DATABASE INTO COMMON MEMORY
IF NONE(SAV) OR KEY(INIT) THEN BEGIN
  
  SAV_FILE = !S.MASTER + 'CHL_PROFILES-MASTER.SAV'
  SAV = IDL_RESTORE(SAV_FILE)
  SAV = STRUCT_CLEAN(SAV,EXCLUDE = ['TEMP','CODE','SOURCE'])
  SAV =STRUCT_2NUM(SAV)
  ALL_SURFACE= SAV(WHERE(SAV.CODE EQ 'S'))
  SURF_LON = ALL_SURFACE.LON
  SURF_LAT = ALL_SURFACE.LAT  
  SURF_DOY = ABS(ALL_SURFACE.DOY-183); ADJUSTED DOY [SYMMETRIC ABOUT JUL 1]
  SURF_CHL = ALL_SURFACE.CHL
ENDIF;IF NONE(SAV) OR KEY(INIT) THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||

;===> ENSURE PNUM IF PRESENT IS WITHIN RANGE OF PNUMS IN THE DATABASE
IF ANY(PNUM) THEN BEGIN
  OK = WHERE_IN(ULONG(SAV.PNUM),ULONG(PNUM),COUNT)
  IF MIN(PNUM) LT 1 OR MAX(PNUM) GT MAX(ULONG(SAV.PNUM)) THEN MESSAGE,'ERROR: PNUM NOT IN DATABASE'  
ENDIF;IF KEY(PNUM) THEN BEGIN
;||||||||||||||||||||||||||||

;===> RETURN ENTIRE DATABASE
IF NONE(PNUM)AND NONE(S)  THEN RETURN,SAV
;||||||||||||||||||||||||||||||||||||||||
;
;===> RETURN ALL SURFACE RECORDS
IF KEY(S) AND NONE(PNUM) THEN RETURN,ALL_SURFACE 
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;
;===> RETURN AN ENTIRE PROFILE
IF KEY(PNUM) AND NONE(S) THEN BEGIN
  OK = WHERE_IN(ULONG(SAV.PNUM),ULONG(PNUM),COUNT)
  IF COUNT GE 1 THEN RETURN,SAV[OK]
ENDIF;IF KEY(PNUM) AND KEY(S) THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||||||||

;===> RETURN A SINGLE SURFACE RECORD FOR A PROFILE
IF KEY(PNUM) AND KEY(S) THEN BEGIN
  OK = WHERE(ULONG(SAV.PNUM) EQ ULONG(PNUM) AND SAV.CODE EQ 'S',COUNT)
  IF COUNT EQ 1 THEN RETURN,SAV[OK]
ENDIF;IF KEY(PNUM) AND KEY(S) THEN BEGIN
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

   
DONE:          
	END; #####################  END OF ROUTINE ################################

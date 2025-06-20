; $ID:	GET_PATH.PRO,	2020-06-30-17,	USER-KJWH	$
;#############################################################################################################
	FUNCTION GET_PATH
	
;  PRO GET_PATH
;+
; NAME:
;		GET_PATH
;
; PURPOSE: THIS FUNCTION RETURNS THE MAIN PATH TO IDL\PROGRAMS\ 
;
; CATEGORY:
;		STRINGS
;		 
;
; CALLING SEQUENCE:RESULT = GET_PATH()
;
; INPUTS:
;		NONE 
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   NONE

; OUTPUTS:  THE FIXED DRIVE THAT HAS THE IDL PROGRAMS DIRECTORY ['IDL\PROGRAMS\']
;		
;; EXAMPLES:
;  PRINT, GET_PATH()
;	NOTES:
;
; MODIFICATION HISTORY:
;			WRITTEN OCT 2,2013 J.O'REILLY
;			DEC 13,2013,JOR NOW CHECKS IF OS IS WINDOWS
;			DEC 16,2013,JOR CHECKS FOR IDL\PROGRAMS\ ON ALL 'FIXED' DRIVES UNDER WINDOWS
;			DEC 17,2013,JOR ADDED BREAK WITHIN LOOP:
;			                FOR NTH = 0,N_ELEMENTS(DRIVES) -1 DO BEGIN
;                     SO THAT THE FIRST DRIVE FOUND IS RETURNED
;     OCT 23,2014,JOR :IF GET_COMPUTER() EQ 'LOLIGO' THEN RETURN,'D:\'  [BECAUSE C HAS A BACKUP COPY OF IDL\PROGRAMS]


;			
;#################################################################################
;-
;*************************
ROUTINE_NAME  = 'GET_PATH'
;*************************
OS =  STRUPCASE(!VERSION.OS_FAMILY)
IF OS EQ 'WINDOWS' THEN BEGIN 
  TARGET = 'IDL\PROGRAMS\'
  DRIVES = GET_DRIVE_NAMES() 
  OK = WHERE(DRIVES.TYPE EQ 'FIXED',COUNT_DRIVES) & DRIVES = DRIVES[OK].DRIVE
  IF GET_COMPUTER() EQ 'LOLIGO' THEN RETURN,'D:\'
  IF COUNT_DRIVES GE 1 THEN BEGIN
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
    FOR NTH = 0,N_ELEMENTS(DRIVES) -1 DO BEGIN
      TXT = DRIVES[NTH] + TARGET
      DRIVE = DRIVES[NTH]
      IF FILE_TEST(TXT) EQ 1 THEN BEGIN
        PATH = DRIVE
        BREAK
      ENDIF;IF FILE_TEST(TXT) EQ 1 THEN BEGIN
    ENDFOR;FOR NTH = 0,N_ELEMENTS(DRIVES) -1 DO BEGIN
    ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  ENDIF;IF COUNT_DRIVES GE 1 THEN BEGIN
  RETURN,PATH
  
ENDIF ELSE BEGIN
  RETURN,PATH_SEP()
ENDELSE;IF OS EQ 'WINDOWS' THEN BEGIN

DONE:          
	END; #####################  END OF ROUTINE ################################

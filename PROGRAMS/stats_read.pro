; $ID:	STATS_READ.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;############################################################################################################
	FUNCTION STATS_READ, FILE, STAT=STAT,STRUCT=STRUCT,ERROR=ERROR

; THIS FUNCTION READS THE STATS MADE BY:  STATS_ARRAYS_PERIODS [STATS_ARRAYS] 
;                                         STRUCTURES MADE USING STRUCT_SD_WRITE
; 
;	INPUT:
;		FILE: 	THE FULL PATH AND NAME FOR THE FILE
;
;	OUTPUT:  A STRUCTURE WITH EITHER ALL [DEFAULT] OR SOME OF THE STATS MADE BY STATS_ARRAYS_PERIODS [IF KEYWORD STATS USED]
;	         OR THE DATA ARRAY IF STRUCT_SD_WRITE WAS USED TO MAKE THE STATS STRUCTURE
;		
;	KEYWORDS:
;	  STAT:	THE NAME[S] OF THE STANDARD STATS TO EXTRACT FROM THE PACKED STATS FILE ('NUM','MIN','MAX','SPAN','NEG','WTS','SUM','SSQ','MEAN','STD','CV')
;            ALLOWABLE STATS = ['NUM','MIN','MAX','NEG','WTS','SUM','SSQ','MEAN','VAR','STD','CV','SPAN']
;    STRUCT:  THE ENTIRE STRUCTURE INFO IS PLACED INTO STRUCT

;		ERROR:    ANY ERROR MESSAGES ARE PLACED IN ERROR, IF NO ERRORS THEN ERROR = ''
;
; 	MODIFICATION HISTORY:
;   SEP 2,2013, WRITTEN BY J.O'REILLY
;   SEP 3,2013,JOR : IF VALID_STATS(FN.NAME) EQ 'STATS' AND WHERE(TAGNAMES EQ 'N_SETS') NE -1 THEN  BEGIN
;   NOV 10,2013,JOR NO LONGER USING [STRUCT_SD_READ & STRUCT_SD_2DATA] FOR SAVES MADE WITH STRUCT_SD_WRITE
;   NOV 13,2013,JOR ADDED KEYWORD STRUCT [ FOR BACKWARD COMPATIBILITY] 
;   NOV 15,2013,JOR: CHANGED KEYWORD STATS TO TARGETS; 
;                    ADDED KEY ATTRIBUTES FROM FILE_ALL(FILE) TO STRUCT
;                    RETURNS AN ERROR STRING IF STATS TARGETS ARE NOT FOUND
;                    IF N_ELEMENTS(TARGETS) EQ 0 THEN TARGETS = 'MEAN'
;   JAN 16,2014,JOR RENAMED READ_STATS 2 STATS_READ TO FOLLOW CONVENTION 
;                   THAT ALL STATS RELATED PROGRAMS BEGIN WITH 'STATS_'
;   JAN 29,2014,JOR: CHANGED KEYWORD TARGETS TO STAT; 
;   MAY 9,2014,JOR: ADDED CODE TO READ A PLAIN SAVE ARRAY USING IDL_RESTORE
;############################################################################################################
;-
;****************************
ROUTINE_NAME  = 'STATS_READ'
;*****************************
ERROR = ''
IF N_ELEMENTS(STAT) EQ 0 THEN STAT = 'MEAN' 
IF FILE_TEST(FILE) EQ 0 THEN MESSAGE,' CAN NOT FIND ' + FILE

IF N_ELEMENTS(FILE) EQ 1 AND N_ELEMENTS(STRUCT)EQ 0 THEN STRUCT = IDL_RESTORE(FILE)
FN = FILE_PARSE(FILE)
;===> IF NO TAGS THEN FILE IS PROBABLY A SIMPLE SAVEFILE ARRAY
IF N_TAGS(STRUCT) EQ 0 THEN RETURN,STRUCT
TAGNAMES = TAG_NAMES(STRUCT)
IF IDLTYPE(STRUCT.(0)) EQ 'STRUCT' THEN TAGNAMES =[TAGNAMES,TAG_NAMES(STRUCT.(0))]
IF WHERE(TAGNAMES EQ 'N_SETS') NE -1 THEN TYPE = 'STATS_ARRAYS'
IF WHERE(TAGNAMES EQ 'IMAGE') NE -1 THEN TYPE = 'STRUCT_SD_WRITE'

CASE (TYPE) OF
  'STATS_ARRAYS': BEGIN
  OK = WHERE_STRING(TAGNAMES , STAT,COUNT)
  IF COUNT EQ 0 THEN RETURN,'ERROR: NO STATS  ' +STAT + '  FOUND'
  IF COUNT EQ 1 THEN RETURN,STRUCT.(OK)
  END;'STATS_ARRAYS'
  
  'STRUCT_SD_WRITE': BEGIN
  OK = WHERE(TAGNAMES EQ 'IMAGE',COUNT)
  IF COUNT EQ 1 THEN BEGIN
    IF N_TAGS(STRUCT) EQ 1 THEN BEGIN
      STRUCT = STRUCT.(0)
      RETURN,STRUCT.IMAGE
    ENDIF ELSE BEGIN
      RETURN,STRUCT.(0).IMAGE
    ENDELSE;IF N_TAGS(STRUCT) EQ 1 THEN BEGIN
      
  ENDIF;IF COUNT EQ 1 THEN BEGIN
  
  END;'STRUCT_SD_WRITE'
  
  
  ELSE: BEGIN
    RETURN,STRUCT
  END;ELSE: BEGIN
    
ENDCASE;CASE (TYPE) OF

 END; #####################  END OF ROUTINE ################################

; $ID:	NEXT.PRO,	2020-07-01-12,	USER-KJWH	$
;#############################################################################################################
	FUNCTION NEXT,ARRAY,VAR=VAR,NUM,INIT=INIT
	
;  PRO NEXT
;+
; NAME:
;		NEXT
;
; PURPOSE: THIS FUNCTION RETURNS THE NEXT VALUE IN AN ARRAY OR NEXT SERIES OF VALUES IN THE ARRAY 
;
; CATEGORY:
;		ARRAYS
;		 
;
; CALLING SEQUENCE: RESULT = NEXT(ARRAY)
;
; INPUTS:
;		ARRAY:	  INPUT ARRAY OF VALUES
;		NUM:      THE NUMBER OF NEXT VALUES TO GET FROM THE ARRAY [DEFAULT = 1]
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   INIT:   INITIALIZES PROGRAM [ VARIABLES IN COMMON MEMORY]
;   VAR:    THE VARIABLE FROM WHICH TO EXTRACT THE NEXT ELEMENT [REQUIRED]
; OUTPUTS:    PRINTS THE NEXT VALUES IN THEINPUT ARRAY 
; EXAMPLES:   PRINT,NEXT([0,1,2,3,4,5,6,7,8])
;             PRINT,NEXT([0,1,2,3,4,5,6,7,8],1,VAR = 'DAT')
;             PRINT,NEXT([0,1,2,3,4,5,6,7,8],2)
;             PRINT,NEXT([0,1,2,3,4,5,6,7,8],3)
;   
;
;
; MODIFICATION HISTORY:
;			WRITTEN JUN 28,2012  J.O'REILLY
;			MAR 22,2013,JOR MODIFIED TO DEAL WITH MANY DIFFERENT VARIABLES [ARRAYS]
;#################################################################################
;
;
;-
;	*******************************************
ROUTINE_NAME  = 'NEXT'
; *******************************************
; ===> USEFUL WORDS FOR SEARCHING:
; STOP PRINT N_ELEMENTS  ENDFOR SWITCHES  RETURN    ,
; 
;********************************************************************
COMMON  NEXT_COMMON, STRUCT_NEXT
;********************************************************************
IF N_ELEMENTS(ARRAY) EQ 0 THEN MESSAGE,'ARRAY IS REQUIRED'
IF N_ELEMENTS(VAR) EQ 0 THEN MESSAGE,'VAR IS REQUIRED'
IF N_ELEMENTS(NUM) EQ 0 THEN NUM = 1L 
NUM =0 > N_ELEMENTS(ARRAY) < NUM
VAR = STRUPCASE(VAR)
PRINT
IF KEYWORD_SET(INIT)THEN BEGIN
  GONE,ARR
  GONE,SUB_START
  GONE,SUB_END
  GONE,SUBS
  GONE,STRUCT_NEXT
  SUB_START = 0L
  SUB_END = (SUB_START+NUM-1L)
  INITIALIZED = 1
ENDIF ;IF KEYWORD_SET(INIT) THEN BEGIN

; **********************************************************************************************************
; *** ADD THIS VARIABLE TO STRUCT_NEXT IF IT IS NOT ALREADY PRESENT ***
; **********************************************************************************************************
;
;*********************************************
IF IDLTYPE(STRUCT_NEXT) NE 'STRUCT' THEN BEGIN
;*********************************************
  STRUCT_NEXT=CREATE_STRUCT(VAR,CREATE_STRUCT(VAR,VAR,'ARRAY',ARRAY,'SUB_BEG',0L,'SUB_END',(NUM-1),'FIRST',1))
;STOP
  ; ===> COMBINE INTO A NESTED STRUCTURE
ENDIF 
;|||||||||||||||||||||||||||||||||||||||||||||||||||||

;########################################
;FIND THE APPROPRIATE STRUCTURE COMPONENT
;########################################
  OK_ARR = WHERE(TAG_NAMES(STRUCT_NEXT) EQ VAR,FOUND_ARR)

IF FOUND_ARR GE 1 THEN BEGIN
  ;STOP
  IF STRUCT_NEXT.(OK_ARR).FIRST EQ 1 THEN BEGIN
    SUB_BEG = STRUCT_NEXT.(OK_ARR).SUB_BEG
    SUB_END   = STRUCT_NEXT.(OK_ARR).SUB_END
    STRUCT_NEXT.(OK_ARR).FIRST = 0
  ENDIF ELSE BEGIN
    STRUCT_NEXT.(OK_ARR).SUB_BEG =  STRUCT_NEXT.(OK_ARR).SUB_BEG + NUM 
    STRUCT_NEXT.(OK_ARR).SUB_END = STRUCT_NEXT.(OK_ARR).SUB_END + NUM 
    SUB_BEG= STRUCT_NEXT.(OK_ARR).SUB_BEG
    SUB_END= STRUCT_NEXT.(OK_ARR).SUB_END
  ENDELSE;IF STRUCT_NEXT.(OK_ARR).FIRST EQ 1 THEN BEGIN
ENDIF ELSE BEGIN
  ;===> ADD NEW STRUCT TO STRUCT_NEXT
  STRUCT = CREATE_STRUCT(VAR,CREATE_STRUCT(VAR,VAR,'ARRAY',ARRAY,'SUB_BEG',0L,'SUB_END',(NUM-1),'FIRST',1))
  STRUCT_NEXT = STRUCT_MERGE(STRUCT_NEXT,STRUCT)
  
  OK_ARR = WHERE(TAG_NAMES(STRUCT_NEXT) EQ VAR,FOUND_ARR)
  IF STRUCT_NEXT.(OK_ARR).FIRST EQ 1 THEN BEGIN
    SUB_BEG = STRUCT_NEXT.(OK_ARR).SUB_BEG
    SUB_END   = STRUCT_NEXT.(OK_ARR).SUB_END
    STRUCT_NEXT.(OK_ARR).FIRST = 0
  ENDIF ELSE BEGIN
    STRUCT_NEXT.(OK_ARR).SUB_BEG =  STRUCT_NEXT.(OK_ARR).SUB_BEG + NUM 
    STRUCT_NEXT.(OK_ARR).SUB_END = STRUCT_NEXT.(OK_ARR).SUB_END + NUM 
    SUB_BEG= STRUCT_NEXT.(OK_ARR).SUB_BEG
    SUB_END= STRUCT_NEXT.(OK_ARR).SUB_END
  ENDELSE;IF STRUCT_NEXT.(OK_ARR).FIRST EQ 1 THEN BEGIN
  
  
ENDELSE;IF FOUND_ARR GE 1 THEN BEGIN

IF SUB_END GT N_ELEMENTS(ARRAY)-1 THEN BEGIN
  
  TXT = 'END OF ARRAY' & TXT = REPLICATE(TXT,2) & PLIST,TXT,/NOSEQ
  
  RETURN, LAST(ARRAY)
  GONE,ARR     
ENDIF;IF SUBS(1) GT N_ELEMENTS(ARRAY)-1 THEN BEGIN
    
RETURN, ARRAY(SUB_BEG:SUB_END)
      
	END; #####################  END OF ROUTINE ################################

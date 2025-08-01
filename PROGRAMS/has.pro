; $ID:	HAS.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION HAS,VAR,ITEM,EXACT=EXACT
;
; PURPOSE: THIS FUNCTION RETURNS: 1 [TRUE] IF THE ITEM IS PRESENT IN VAR
;                                 0 [FALSE] IF THE ITEM IS NOT PRESENT IN VAR
; 
; CATEGORY:	LOGICAL		 
;
; CALLING SEQUENCE: RESULT = HAS(VAR,ITEM)
;
; INPUTS: VAR VARIABLE TO SEARCH 
;         ITEM  THE ITEM TO FIND IN VAR

; OPTIONAL INPUTS: NONE
;			
;		
; KEYWORD PARAMETERS: 
;                   EXACT..... ONLY FIND EXACT MATCHES
;  
; 
; OUTPUTS: 1= IF ITEM PRESENT IN VAR  0=IF ITEM NOT PRESENT IN VAR

;	NOTES:  BOTH VAL AND ITEM MAY BE ARRAYS	
;	
;; EXAMPLES:
;  PRINT,HAS('R'); RESULT IS !NULL
;  PRINT,HAS('RSVP','R'); RESULT IS 1
;  PRINT,HAS('RSVP','S'); RESULT IS 1
;  PRINT,HAS('RSVP','V'); RESULT IS 1
;  PRINT,HAS('RSVP','V'); RESULT IS 1
;  PRINT,HAS('RSVP','Q'); RESULT IS 0
;  PRINT,HAS('RSVP','R',/EXACT); RESULT IS 0
;  PRINT,HAS('AREA_1_3','_'); RESULT IS 1
;  PRINT, HAS(0,0);  RESULT IS 1
;  PRINT, HAS(1,0);  RESULT IS 0
;  PRINT, HAS('','');  RESULT IS 1
;  HELP, HAS([],[]);  RESULT IS !NULL
;  PRINT, HAS('123','123');  RESULT IS 1 
;  PRINT, HAS(INDGEN(3),1);  RESULT IS 1
;  PRINT, HAS(INDGEN(3),4);  RESULT IS 0
;  PRINT, HAS(INDGEN(3),[9,9]);  RESULT IS 0
;  PRINT, HAS(INDGEN(3),[0,1]);  RESULT IS 1
;  PRINT, HAS(INDGEN(3),'CAT');  RESULT IS !NULL
;  L = LIST('HELLO') & PRINT, HAS(L,'H');  RESULT IS 1
;  L = LIST(INDGEN(3)) & PRINT, HAS(L,1);  RESULT IS 1
;  L = LIST(INDGEN(3)) & PRINT, HAS(L,4);  RESULT IS 0
;  PRINT,HAS(CREATE_STRUCT('DATA',INDGEN(9),'JUNK','JUNK'),'DATA');  RESULT IS 1
;  PRINT,HAS(CREATE_STRUCT('DATA',INDGEN(9),'JUNK','JUNK'),'JUNK');  RESULT IS 1
;  PRINT,HAS(CREATE_STRUCT('DATA',INDGEN(9),'JUNK','JUNK'),'JJ');  RESULT IS 0
; 
; MODIFICATION HISTORY:
;			APR 19,2014  WRITTEN BY J.O'REILLY
;			DEC 7, 2014,JOR ADDED CASES, EXAMPLES, AND ISA FUNCTION
;			DEC 10,2014: ADDED CODE TO DEAL WITH LISTS
;			FEB 14,2014,JOR:IF IDLTYPE(VAR_) EQ 'STRUCT' THEN RETURN,STRUCT_HAS(VAR_,ITEM)
;     MAR 6,2015,JOR CHANGED HASTAG TO STRUCT_HAS
;     MAR 15,2015,JOR :       IF MAX(STRPOS(STRUPCASE(VAR_),STRUPCASE(ITEM)) ) GE 0 THEN RETURN,1 ELSE RETURN, 0
;     AUG 11, 2015 - KJWH: CHANGED "IF VAR EQ [] THEN RETURN, []" TO RETURN 0 INSTEAD SO THAT IT WON'T CRASH PROGRAMS THAT ARE LOOKING FOR EITHER A 0 OR A 1
;     NOV 09, 2015 - KJWH: ADDED "EXACT" KEYWORD IF YOU WANT TO ONLY FIND EXACT MATCHES.
;     NOV 12, 2015 - JEOR: ADDED EXACT EXAMPLE
;     NOV 30, 2015 - KJWH: Now return 0 if VAR EQ []

;			
;#################################################################################
;-
;*********************
ROUTINE_NAME  = 'HAS'
;*********************
;===> CONSERVE VAR
IF VAR EQ [] THEN RETURN,0 ELSE VAR_ = VAR
;
;===> IS THE TAG PRESENT IN A STRUCTURE ?
IF IDLTYPE(VAR_) EQ 'STRUCT' THEN RETURN,STRUCT_HAS(VAR_,ITEM)


; CHECK INPUTS
;===> EXTRACT LISTS [ASSUMES ONLY ONE DIMENSION
IF TYPENAME(VAR_) EQ 'LIST' THEN VAR_ = VAR[0]
IF TYPENAME(VAR_) NE TYPENAME(ITEM) THEN RETURN,[]

IF NONE(VAR_) OR NONE(ITEM) THEN RETURN,[]

NUM = ISA(VAR_,/NUMBER)
CASE (NUM) OF; STRINGS>>>
    0: BEGIN   
       IF ITEM EQ '' OR KEY(EXACT) THEN BEGIN
        IF WHERE(STRUPCASE(ITEM) EQ STRUPCASE(VAR_)) GE 0 THEN RETURN, 1 ELSE RETURN, 0
       ENDIF;IF ITEM EQ '' OR KEY(EXACT) THEN BEGIN
       
       IF MAX(STRPOS(STRUPCASE(VAR_),STRUPCASE(ITEM)) ) GE 0 THEN RETURN,1 ELSE RETURN, 0
    END;0 STRINGS
    
    1: BEGIN ; NUMBERS>>> 
       OK = WHERE_IN(VAR_ , ITEM,COUNT) 
       IF COUNT  GE 1 THEN RETURN ,1 ELSE RETURN, 0      
    END;1 NUMBERS
    
    ELSE: BEGIN
    END
  ENDCASE


DONE:          
	END; #####################  END OF ROUTINE ################################

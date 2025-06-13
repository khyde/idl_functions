; $ID:	GET_OBJ_DATA.PRO,	2014-04-29	$
;+
;;#############################################################################################################
	FUNCTION GET_OBJ_DATA,OBJ

; PURPOSE: THIS FUNCTION EXTRACTS THE APPROPRIATE DATA FROM IDL GRAPHICS OBJECTS
; 
; 
; CATEGORY:	OBJECTS;		 
;
; CALLING SEQUENCE: RESULT = GET_OBJ_DATA(OBJ)
;
; INPUTS: OBJ  

; OPTIONAL INPUTS:
;		
; KEYWORD PARAMETERS:

; OUTPUTS: 
;		
;; EXAMPLES:
;  ST, GET_OBJ_DATA(OBJ)
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN OCT 11, 2013 J.O'REILLY
;#################################################################################
;-
;****************************
ROUTINE_NAME  = 'GET_OBJ_DATA'
;****************************

;##### IS  OBJECT PRESENT ? #####
IF NONE(OBJ) THEN MESSAGE,'ERROR: PLOT OBJECT IS REQUIRED'
IF IDLTYPE(OBJ) NE 'OBJREF' THEN MESSAGE,'ERROR: OBJ MUST BE A PLOT OBJECT'
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
NAME = STRUPCASE(OBJ.NAME)
;IF WHERE_STRING(NAME,'IMAGE') NE -1  THEN OBJ.GETDATA, IMAGE,X, Y
;IF WHERE_STRING(NAME,'PLOT') NE -1  THEN OBJ.GETDATA,X, Y
 IMAGE = '' & X = '' & Y=''
;*************************
CASE STRUPCASE(NAME) OF
;*************************
  'IMAGE': BEGIN
   
   OBJ.GETDATA, IMAGE
   S = CREATE_STRUCT('NAME',NAME,'IMAGE',IMAGE,'X',X,'Y',Y)
  END;'IMAGE': BEGIN
  ;|||||||||||||||||
  'PLOT' : BEGIN
   OBJ.GETDATA,X, Y
;   SYMBOL                    = 0
;   SYM_COLOR                 = [0,   0,   0]
;   SYM_FILLED                = 0
;   SYM_FILL_COLOR            = 0   0   0
;   SYM_INCREMENT
   S = CREATE_STRUCT('NAME',NAME,'IMAGE','','XRANGE',OBJ.XRANGE,'YRANGE',OBJ.YRANGE,'X',X,'Y',Y,'SYMBOL',OBJ.SYMBOL)
  END;'PLOT' : BEGIN
  ;|||||||||||||||||
    
  ELSE: BEGIN
  END
ENDCASE
;||||||

RETURN,S
DONE:          
	END; #####################  END OF ROUTINE ################################

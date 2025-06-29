; $ID:	STRUCT_INFO.PRO,	2020-07-08-15,	USER-KJWH	$
;########################################################################################################################                   
FUNCTION STRUCT_INFO, STRUCT
;+
;PURPOSE:
;	THIS FUNCTION RETURNS THE INFO [NAMES,TYPES,SIZES,SCALAR OR ARRAY,2D OR 3-D] OF THE TAGS IN A STRUCTURE	
; SYNTAX:
;		RESULT = STRUCT_INFO(STRUCT)
;		
; OUTPUT: A STRUCTURE WITH THE NAME,DATA TYPE, AND SIZE PX,PY,PZ OF EACH TAG IN THE STRUCTURE
; 
; 
; ARGUMENTS:
; 	STRUCT:	IDL STRUCTURE 

; KEYWORDS: NONE

; EXAMPLES:
;          SPREAD,STRUCT_INFO(CREATE_STRUCT('CAT','CAT','NUM',FINDGEN(9)))
;          SPREAD,STRUCT_INFO(CREATE_STRUCT('CAT','CAT','NUM',BINDGEN(9),'IMG',INDGEN([9,10]),'D3',FINDGEN([333,444,10])))
;          SPREAD,STRUCT_INFO(MAPS_READ('NEC'))
;          SPREAD,STRUCT_INFO(MAPS_READ())
; CATEGORY:
;		STRUCTURES
; NOTES:
;		INPUT STRUCTURE IS NOT ALTERED.

; HISTORY:
;		NOV 22, 2016 - WRITTEN BY:	J.E. O'REILLY
;
;########################################################################################################################		                
;-
;**************************
 ROUTINE_NAME='STRUCT_INFO'
;**************************

 
IF IDLTYPE(STRUCT) NE 'STRUCT' THEN     RETURN, 'ERROR: STRUCT MUST BE AN IDL STRUCTURE'
NTAGS = N_TAGS(STRUCT)
TAGNAMES = TAG_NAMES(STRUCT)
;===> MAKE A STRUCT TO HOLD ALL THE INFO
S = CREATE_STRUCT('TAG','','TYPE_NAME','','TYPE',0,'VAR_TYPE','','PX',0L,'PY',0L,'PZ',0L)

;FFFFFFFFFFFFFFFFFFFFFFFFFF
FOR N = 0, NTAGS-1 DO BEGIN
 S.TAG = TAGNAMES(N)
;===> RECURSIVE CALL FOR STRUCTURES IN STRUCTURES NOT WORKING
;  IF IDLTYPE(STRUCT.(N)) EQ 'STRUCT' THEN BEGIN
;    STOP
;    STRUCT = STRUCT.(N)
;    TEMP = STRUCT_INFO(STRUCT.(N))
;  ENDIF
  CASE [1] OF
    ISA(STRUCT.(N),/SCALAR): BEGIN
     S.VAR_TYPE = 'SCALAR'
    END;SCALAR
   
    ISA(STRUCT.(N),/ARRAY): BEGIN
     S.VAR_TYPE = 'ARRAY'
    END;ARRAY
    ELSE: BEGIN
    END
  ENDCASE;CASE (1) OF
  
  ;===> 1-D,2-D, OR 3-D  
  IF S.VAR_TYPE EQ 'ARRAY' THEN BEGIN
    CASE [1] OF
      IS_2D(STRUCT.(N)): BEGIN
       S.VAR_TYPE = '2D'
        END;2D
      IS_1D(STRUCT.(N)): BEGIN
       S.VAR_TYPE = '1D'
      END;1D
      
      IS_3D(STRUCT.(N)): BEGIN
        
       S.VAR_TYPE = '3D'
      END;3D
      ELSE: BEGIN
      END
    ENDCASE    
  ENDIF;IFS.VAR_TYPE EQ 'ARRAY' THEN BEGIN
    
  SZ = SIZEXYZ(STRUCT.(N))
  C =S
  STRUCT_ASSIGN,SZ,C,/NOZERO
 S = C
  IF NONE(DB) THEN DB = S ELSE DB = [DB,S]
ENDFOR;FOR N = 0, N_TAGS(STRUCT)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  RETURN,DB



END; #####################  END OF ROUTINE ################################

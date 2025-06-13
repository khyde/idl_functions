; $ID:	PTAGS.PRO,	2015-12-03,	USER-JOR	$
;###############################################################################################
	PRO PTAGS, STRUCT,ROW=ROW,ARR=ARR

;+
; NAME:
;		PTAGS
;
; PURPOSE:;
;		THIS PROGRAM LISTS THE  TAGNAMES OF STRUCTURES

; CATEGORY:
;		PRINT
;
; CALLING SEQUENCE:
;		PTAGS,STRUCT
;
; INPUTS:
;		STRUCT:	STRUCTURE
;
;
; KEYWORD PARAMETERS:
;		                 ROW..... PRINT TAGS IN A SINGLE ROW INSTEAD OF A COLUMN LIST
;		                 ARR..... MAKE A STRING ARRAY OF THE TAGNAMES USING ARR_2STR
;
; OUTPUTS:
;		LISTS TAGNAMES IN STRUCTURE
;
; EXAMPLES:
;  DB = MAPS_READ() & PTAGS,DB
;  DB = MAPS_READ() & PTAGS,DB,/ROW
;  DB = MAPS_READ() & PTAGS,DB,/ARR

;
; MODIFICATION HISTORY:
;			WRITTEN JAN 15,2014 BY J.O'REILLY
;			MAY 29,2014,JOR ADDED KEYWORD ROW
;			OCT 12,2014,JOR: IF NONE(STRUCT) THEN STRUCT = STRUCT_READ()
;     JUL 30,2015,JOR  ADDED KEY ARR
;     DEC 04,2015,JOR, ADDED EXAMPLES
;###############################################################################################
;-
;	*******************
ROUTINE_NAME = 'PTAGS'
;********************
IF NONE(STRUCT) THEN STRUCT = STRUCT_READ()
IF IDLTYPE(STRUCT) EQ 'STRUCT' THEN BEGIN
  AKEY = ''
  IF KEY(ROW) THEN AKEY = 'ROW'
  IF KEY(ARR) THEN AKEY = 'ARR'
  CASE (AKEY) OF
    'ROW': BEGIN
     PRINT,TAG_NAMES(STRUCT)
    END;'ROW'
    'ARR': BEGIN
      PRINT,ARR_2STR(TAG_NAMES(STRUCT),/Q,/B)
    END;'ARR'
    ELSE: BEGIN
      PLIST,TAG_NAMES(STRUCT)
    END
  ENDCASE
ENDIF;IF IDLTYPE(STRUCT) EQ 'STRUCT' THEN BEGIN

	
	END; #####################  END OF ROUTINE ################################

; $ID:	STR_TRIM.PRO,	2017-03-12-20,	USER-JEOR	$
;##############################################################################################
FUNCTION STR_TRIM, STR
;+
; NAME:
;       STR_TRIM
;
; PURPOSE:
;       USE IDL STRTRIM AND STRCOMPRESS TO TRIM EXCESS BLANKS FROM STRINGS
;
; CATEGORY:
;       STRING
;
; CALLING SEQUENCE:
;       PRINT STR_TRIM(ST)
;
; INPUTS:
;       STRING ARRAY OR SIMPLE STRUCTURE
;       FLAG (OPTIONAL INPUT OF 0,1,2 (SEE STRTRIM)
;
; KEYWORD PARAMETERS:  NONE
; OUTPUTS:  SAME AS INPUT BUT ANY STRING VARIABLES ARE TRIMMED

;
; EXAMPLES:
;          PRINT,STR_TRIM('A    A    B    B    C    C    D    D    E    E')
;
;
; MODIFICATION HISTORY:
;       WRITTEN BY:  J.E.O'REILLY, NOV 28,2000
;       MAR 11,2017, JEOR MODIFIED TO USE STRTIM AND STRCOMPRESS
;                    REMOVED KEY FLAG,CHANGED DATA TO STR, ADDED CASE BLOCK
;                    REMOVED ALL CODE RELATED TO STRUCTURES [ ONLY 2 OLD,UNUSED PROGRAMS USE IT]
;-
;##############################################################################################

;*******************
ROUTINE = 'STR_TRIM'
;******************* 
IF NOF(STR) GE 2 THEN RETURN, STRTRIM(STRCOMPRESS(STRING(STRJOIN(STR,';'))),2) ELSE $
RETURN, STRTRIM(STRCOMPRESS(STRING(STR)),2)
END ; OF PROGRAM
; ******************************************************

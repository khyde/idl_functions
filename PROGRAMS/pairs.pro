; $ID:	PAIRS.PRO,	2020-06-30-17,	USER-KJWH	$

	FUNCTION PAIRS, DATA, SUBS=subs, ERROR = error

;+
; NAME:
;		PAIRS
;
; PURPOSE:
;		This function generates an array (2,*) of all pairwise combinations of a Values Array
;
; CATEGORY:
;		ARRAY
;
; CALLING SEQUENCE:
;
;		Result = PAIRS(Data)
;
; INPUTS:
;		Data:	An array of 2 or more elements
;

;
; KEYWORD PARAMETERS:
;		SUBS:	Returns the Subscript Pairs instead of the Data Pairs
;
; OUTPUTS:
;		An array (2,*) of all pairwise combinations of the input Data
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;

; EXAMPLE:
;		Result = PAIRS([1,2,3,4,5,6]) & PRINT, Result
;		Result = PAIRS([2,5,4,3,6,1]) & PRINT, Result
;		Result = PAIRS([2,5,4,3,6,1],/subs) & PRINT, Result
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

;
; MODIFICATION HISTORY:
;			Written Oct 25, 1999 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PAIRS'

  IF N_ELEMENTS(DATA) LT 2 THEN RETURN, -1
  N = N_ELEMENTS(DATA)
  C = FACTORIAL(N) / (FACTORIAL(2)*FACTORIAL(N - 2))

  SETS = REPLICATE(DATA[0],2,C)

  SUB=-1L
;	LLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR NTH=0L, N-1L  DO BEGIN
    FOR _NTH = NTH+1L, N-1L DO BEGIN
      SUB = SUB+1
      IF NOT KEYWORD_SET(SUBS) THEN SETS(*,SUB)= [DATA[NTH],DATA(_NTH)] ELSE  SETS(*,SUB)= [[NTH],(_NTH)]
    ENDFOR
  ENDFOR
  RETURN, SETS

	END; #####################  End of Routine ################################

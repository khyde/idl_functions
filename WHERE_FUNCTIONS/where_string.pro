; $ID:	WHERE_STRING.PRO,	2020-06-30-17,	USER-KJWH	$
;#######################################################################################################
  FUNCTION WHERE_STRING, TXT, TARGETS, CASES=CASES, MULTIPLE=MULTIPLE, COUNT, NCOMPLEMENT=NCOMPLEMENT, COMPLEMENT=COMPLEMENT
;+
; NAME:
;       WHERE_STRING
;
; PURPOSE:
;       LOCATE SUBSCRIPTS (LINE NUMBERS) OF A TEXT ARRAY HAVING SPECIFIED WORDS
;
;
; INPUTS:
;       TEXT: A STRING OR STRING ARRAY
;				TARGETS: THE STRING OR STRING ARRAY TO SEARCH FOR WITHIN THE TEXT
;
;
; KEYWORD PARAMETERS:
;				CASES:  Looks for matches with case insensitive
;				MULTIPLE: Set keyword to look for multiple matches within the text string
;				
; OUTPUTS:
;       List of subscripts that contain match(es) for the string target(s)
;       
; OPTIONAL OUTPUTS      
;       COUNT:  Number of matches (lines) found
;       NCOMPLEMENT:  Number of elements where the targets were not found
;       COMPLEMENT:   Subscripts for those elements where the targets were not found
;
;	EXAMPLES:
;		OK=WHERE_STRING('HELP', 'HEL') & PRINT,OK
;	  OK=WHERE_STRING('HELP', 'hel',/CASES) & PRINT,OK
;	  OK=WHERE_STRING(['HELP','ELP'], ['HEL','ELP']) & PRINT,OK
;		OK=WHERE_STRING(['HELP','HELP'], 'hel' ) & PRINT,OK
;		OK=WHERE_STRING(['HELP','HELP'], 'hel',/CASES) & PRINT,OK
;		
; MODIFICATION HISTORY:
;       WRITTEN BY:  J.E.O'REILLY, SEPTEMBER 12,2006
;       SEP 26, 2011 - JEOR: ADDED MORE EXAMPLES & DOCUMENTATION
;       NOV 13, 2014 - JEOR: Formatting
;                            IF COUNT EQ 0 THEN RETURN, [] ELSE  RETURN,OK
;       JUN 20, 2017 - KJWH: Changed TEXT to TXT to avoid IDL function conflicts
;
;       
;#######################################################################################################
;-
;**********************************************
	ROUTINE_NAME='WHERE_STRING'
;**********************************************

	ERROR=''
	NUM=N_ELEMENTS(TXT)
	N_TARGETS = N_ELEMENTS(TARGETS)

	SUBS = REPLICATE(-1L, NUM)
	IF KEYWORD_SET(CASES) THEN BEGIN
		_TEXT = STRUPCASE(TXT)
		_TARGETS = STRUPCASE(TARGETS)
	ENDIF ELSE BEGIN
		_TEXT = TXT
		_TARGETS = TARGETS
	ENDELSE

;	FFFFFFFFFFFFFFFFFFFFFFFFFFF
	FOR NTH = 0L,NUM-1 DO BEGIN
		ATEXT = _TEXT[NTH]
;		FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
		CT = 0
		FOR _TARGET = 0L,N_TARGETS-1L DO BEGIN
			ATARGET = _TARGETS(_TARGET)
			POS = STRPOS(ATEXT,ATARGET)
			IF POS GE 0 THEN BEGIN
				IF KEY(MULTIPLE) THEN CT = CT + 1 ELSE CT = N_TARGETS
			  IF CT EQ N_TARGETS THEN SUBS[NTH] = NTH
				IF ~KEY(MULTIPLE) THEN BREAK
			ENDIF;IF POS GE 0 THEN BEGIN
		ENDFOR;FOR _TARGET = 0L,N_TARGETS-1L DO BEGIN
		;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
	ENDFOR;FOR NTH = 0L,NUM-1 DO BEGIN

	OK=WHERE(SUBS NE -1,COUNT,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)
	IF COUNT EQ 0 THEN RETURN, [] ELSE  RETURN,OK


  END; #####################  END OF ROUTINE ################################

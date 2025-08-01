; $ID:	REPLACE.PRO,	2020-07-29-14,	USER-KJWH	$
	FUNCTION REPLACE, DATA, OLD, NEW, SUBS=SUBS, COUNT=COUNT, TAGNAMES=TAGNAMES
;+
;	THIS FUNCTION REPLACES (SUBSTITUTES) ONE (OR MORE) VALUES FOR ANOTHER (OR MORE) VALUES

; OUTPUT:
;		SAME AS INPUT DATA BUT VALUES IN DATA THAT MATCH OLD ARE REPLACED WITH NEW
; ARGUMENTS:
;		DATA: INPUT NUMERIC, STRING, OR STRUCURE DATA
;		OLD:  VALUES IN DATA TO BE REPLACED
;   NEW:  VALUES TO REPLACE WITH;
;
; KEYWORDS:
;		SUBS: 		SUBSCRIPTS IN DATA WHERE CHANGES WERE MADE (N/A FOR STRUCTURES)
;		COUNT: 		PROVIDES A COUNT OF THE NUMBER OF TIMES REPLACEMENTS WERE MADE
;		TAGNAMES: EXACT TAGNAMES TO BE SEARCHED FOR OLD AND REPLACED WITH NEW IF DATA IS A STRUCTURE
;		ERROR:		ERROR =1 IF ENCOUNTER AN ERROR
;
; NOTES:
;		SIZE OF OLD MUST EQUAL SIZE OF NEW
;   SUBS = -1 WHEN A STRUCTURE IS PROVIDED BECAUSE THE SUBSCRIPTS REPLACED IN A STRUCTURE WILL BE ABIGUOUS
;		TAGNAMES WILL BE CONVERTED TO UPPER CASE WHEN COMPARING WITH THE TAGNAMES IN THE DATA STRUCTURE
; $$$ COUNT IS STILL INCORRECT WHEN REPLACING STRING VALUES IN NESTED STRUCTURES
;
;	CAUTIONS:
;		IF DATA IS A STRUCTURE AND TAGNAMES NOT PROVIDED THEN ANY INSTANCE OF OLD ANYWHERE IN THE STRUCTURE WILL BE
;		REPLACED BY NEW
;
;	  THIS PROGRAM WILL REPLACE !VALUES.F_NAN AND !VALUES.D_NAN WITH NEW  BUT IT USES THE ~FINITE FUNCTION
;		TO FIND THE NAN (AND WILL ALSO FIND !VALUES.F_INFINITY AND !VALUES.D_INFINITY) AND REPLACE WITH NEW

;		WITH STRINGS, REPLACEMENT OCCURS WHEN THE FIRST NEW IS FOUND IN THE STRING, THEN OTHER NEW VALUES ARE IGNORED

; HISTORY:
;		OCT 11,1999	WRITTEN BY:	J.E. O'REILLY, NOAA, 28 TARZWELL DRIVE, NARRAGANSETT, RI 02882
;		AUG 4, 2003 ADDED SUBS
;		JAN 16,2005 JOR. REPLACEMENT OCCURS WHEN THE FIRST NEW IS FOUND IN THE STRING, THEN OTHER NEW VALUES ARE IGNORED
;		APR 5,2012,JOR [RESTORED VERSION FROM: OCTOBER 25 2010 WHICH WORKS WELL-EXCEPT FOR STRUCTURE TAGNAMES
;		               UPPERCASE;EDITED
;		               REPLACED ERROR WITH ERROR STRING
;		NOV 20,2014,JOR RETURN [] INSTEAD OF -1
;		JAN 14,2015,JOR REMOVED ERROR
;-
; *********************
ROUTINE_NAME='REPLACE'
; *********************

	COUNT = 0L
	SUBS  = -1L

  IF 	N_ELEMENTS(DATA) 	LT 1 THEN  RETURN,'ERROR: DATA ARE UNDEFINED'
      

  IF 	NONE(OLD) OR NONE(NEW) OR NOF(OLD) NE NOF(NEW) THEN RETURN,'ERROR: SIZE OF OLD MUST EQUAL SIZE OF NEW'
    

; ===> MAKE A COPY OF DATA TO PERSERVE DATA
  COPY = DATA
  TYPE = IDLTYPE(COPY,/CODE)


; *************************
;	***** S T R I N G S *****
; *************************
  IF TYPE EQ 7 THEN BEGIN
    SUBS = REPLICATE(-1L,N_ELEMENTS(COPY)) ; ONE PER LINE OF INPUT TEXT
    FOR NTH = 0L,N_ELEMENTS(COPY)-1L DO BEGIN
      FOR _NTH = 0,N_ELEMENTS(OLD)-1L DO BEGIN
        _OLD = OLD(_NTH)
        _NEW = NEW(_NTH)
        _COPY= COPY[NTH]
        TXT = STR_SEP(_COPY,_OLD)
        IF N_ELEMENTS(TXT) GE 2 THEN BEGIN
          COPY[NTH] = STRJOIN(STR_ADD(TXT,_NEW,/NO_LAST))
          COUNT=COUNT+1
          SUBS[NTH]=NTH          
        ENDIF ELSE BEGIN
          COPY[NTH] = _COPY
        ENDELSE
      ENDFOR
    ENDFOR
    OK=WHERE(SUBS NE -1,FOUND)
    IF FOUND GE 1 THEN SUBS=SUBS[OK] ELSE SUBS = []
    RETURN, COPY
  ENDIF


; *************************
; ***** N U M E R I C *****
; *************************
  IF (TYPE GE 0 AND TYPE LE 5) OR (TYPE GE  12 AND TYPE LE 15) THEN BEGIN
  	CASE TYPE OF
  		1: RANGE = [0B,255B]
  		2: RANGE = [MISSINGS(0)+1,					MISSINGS(0)]
  		3: RANGE = [MISSINGS(0L)+1,					MISSINGS(0L)]
  		4: RANGE = [-MISSINGS(0.0),					MISSINGS(0.0)]
  		5: RANGE = [-MISSINGS(0D),					MISSINGS(0D)]
  		12: RANGE = [0,											MISSINGS(UINT[0])]
  		13: RANGE = [0,											MISSINGS(ULONG[0])]
  		14: RANGE = [MISSINGS(LONG64[0])+1,	MISSINGS(LONG64[0])]
  		15: RANGE = [0,											MISSINGS(ULONG64[0])]
		ENDCASE



;		===> MUST COMPARE USING DOUBLE TO AVOID WRAPAROUND OF UNSIGNED INTEGERS & BYTES (TYPES 1,12,13,15)
   IF (DOUBLE(MIN(NEW)) LT DOUBLE(RANGE[0])) > (DOUBLE(MAX(NEW)) GT DOUBLE(RANGE[1])) THEN BEGIN
    	 ERROR='ERROR: NEW IS NOT COMPATIBLE WITH DATA, RETURNING DATA UNCHANGED'
      PRINT,ERROR
      SUBS = [] 
      COUNT = 0
      RETURN,DATA
    ENDIF

  	SUBS = REPLICATE(-1L,N_ELEMENTS(COPY))

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    FOR N=0,N_ELEMENTS(OLD)-1L DO BEGIN
;			===> SINCE DATA IS NUMERIC THEN  OLD, AND NEW MUST ALSO BE ABLE TO BE TRANSLATED INTO VALID NUMBERS
   		IF NUMBER(OLD(N)) NE 1 OR NUMBER(NEW(N)) NE 1 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


			TXT=STRTRIM(OLD(N),2)
;			===> IF NAN OR -NAN
			IF TXT EQ 'NAN' OR TXT EQ '-NAN' THEN BEGIN
				OK=WHERE(~FINITE(DATA) AND DATA NE !VALUES.F_INFINITY AND DATA NE !VALUES.D_INFINITY,FOUND)
			ENDIF ELSE BEGIN
				OK = WHERE(DATA EQ OLD(N),FOUND)
			ENDELSE

      IF FOUND GE 1 THEN BEGIN
      	COPY[OK] = NEW(N)
      	SUBS[OK]=OK
      	COUNT=COUNT+FOUND
    	ENDIF
    ENDFOR
    OK=WHERE(SUBS NE -1,GOOD)
    IF GOOD GE 1 THEN SUBS=SUBS[OK] ELSE SUBS = []
    RETURN, COPY
  ENDIF

; ********************************
; ***** S T R U C T U R E S  *****
; ********************************
  IF TYPE EQ 8 THEN BEGIN
  	NTAGS = N_TAGS(COPY)
  	TAGNAMES_COPY = TAG_NAMES(COPY)
    COUNTER=0L

		IF N_ELEMENTS(TAGNAMES) EQ 0 THEN BEGIN
;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  		FOR NTH = 0L, NTAGS-1L DO BEGIN
  	  	S_ARR = DATA.(NTH)
  	  	COUNT=0
  	  	COPY.(NTH) = REPLACE(S_ARR,OLD,NEW,COUNT=COUNT)
  	  	COUNTER = COUNTER+COUNT
  		ENDFOR
  	ENDIF ELSE BEGIN
;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  		FOR NTH = 0L, NTAGS-1L DO BEGIN
  			OK_TAG = WHERE_IN(STRUPCASE(TAGNAMES),TAGNAMES_COPY[NTH],COUNT_TAG)
  			IF COUNT_TAG EQ 0 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.
  	  	S_ARR = DATA.(NTH)
  	  	COUNT=0
  	  	COPY.(NTH) = REPLACE(S_ARR,OLD,NEW,COUNT=COUNT)
  	  	COUNTER = COUNTER+COUNT
  		ENDFOR
  	ENDELSE

  	COUNT=COUNTER
  	SUBS = [] ; BECAUSE THE SUBSCRIPTS IN A STRUCTURE WILL BE ABIGUOUS
   	RETURN, COPY
  ENDIF

  END; #####################  END OF ROUTINE ################################

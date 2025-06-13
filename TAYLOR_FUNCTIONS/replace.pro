; $Id:	replace.pro,	October 25 2010	$
	FUNCTION REPLACE, Data, Old, New, SUBS=subs, COUNT=count, TAGNAMES=tagnames, ERROR=error
;+
;	This Function Replaces (Substitutes) one (or more) values for another (or more) values

; OUTPUT:
;		Same as Input Data but values in Data that match Old are replaced with New
; ARGUMENTS:
;		Data: Input numeric, string, or Strucure data
;		Old:  Values in data to be replaced
;   New:  Values to replace with;
;
; KEYWORDS:
;		SUBS: 		Subscripts in Data where changes were made (N/A for structures)
;		COUNT: 		Provides a count of the number of times replacements were made
;		TAGNAMES: Exact tagnames to be searched for Old and replaced with New if Data is a Structure
;		ERROR:		Error =1 if encounter an error
;
; NOTES:
;		Size of old must equal size of new
;   SUBS = -1 When a Structure is provided because the subscripts replaced in a structure will be abiguous
;		TAGNAMES will be converted to UPPER CASE when comparing with the tagnames in the Data Structure
; $$$ Count is still incorrect when replacing string values in nested structures
;
;	CAUTIONS:
;		If Data is a Structure and TAGNAMES not provided then any instance of old ANYWHERE in the structure will be
;		replaced by new
;
;	  This program will replace !VALUES.F_NAN and !VALUES.D_NAN with new  but it uses the ~FINITE function
;		to find the Nan (and will also find !VALUES.F_INFINITY AND !VALUES.D_INFINITY) and replace with NEW

;		With strings, replacement occurs when the first NEW is found in the string, then other NEW values are ignored

; HISTORY:
;		Oct 11,1999	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;		Aug 4, 2003 added subs
;		Jan 16,2005 JOR. replacement occurs when the first NEW is found in the string, then other NEW values are ignored
;-
; *************************************************************************
  ROUTINE_NAME='REPLACE'

	ERROR = 0
	COUNT = 0L
	SUBS  = -1L

  IF 	N_ELEMENTS(Data) 	LT 1 THEN BEGIN
  	ERROR=1
  	PRINT,'ERROR: Data are UNDEFINED'
  	RETURN,-1L
  ENDIF

  IF 	N_ELEMENTS(Old) 	LT 1 OR $
    	N_ELEMENTS(New) 	LT 1 OR $
   		N_ELEMENTS(Old) 	NE N_ELEMENTS(New) THEN BEGIN
  		ERROR=1
  		PRINT,'ERROR: Size of Old must equal Size of New'
  		RETURN,DATA
  ENDIF

; ===> Make a copy of data to perserve data
  COPY = DATA
  SZ=SIZE(COPY,/STRUCT)
  TYPE = SZ.TYPE


; *************************
;	***** S T R I N G S *****
; *************************
  IF TYPE EQ 7 THEN BEGIN
    SUBS = REPLICATE(-1L,N_ELEMENTS(COPY)) ; ONE PER LINE OF INPUT TEXT
    FOR NTH = 0L,N_ELEMENTS(COPY)-1L DO BEGIN
      FOR _NTH = 0,N_ELEMENTS(OLD)-1L DO BEGIN
        _OLD = OLD(_NTH)
        _NEW = NEW(_NTH)
        _COPY= COPY(NTH)
        TXT = STR_SEP(_COPY,_OLD)
        IF N_ELEMENTS(TXT) GE 2 THEN BEGIN
          COPY(NTH) = STRJOIN(STR_ADD(TXT,_NEW,/NO_LAST))
          count=count+1
          SUBS(NTH)=NTH          
        ENDIF ELSE BEGIN
          COPY(NTH) = _COPY
        ENDELSE
      ENDFOR
    ENDFOR
    OK=WHERE(SUBS NE -1,FOUND)
    IF FOUND GE 1 THEN SUBS=SUBS(OK) ELSE SUBS = -1L
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
  		12: RANGE = [0,											MISSINGS(UINT(0))]
  		13: RANGE = [0,											MISSINGS(ULONG(0))]
  		14: RANGE = [MISSINGS(LONG64(0))+1,	MISSINGS(LONG64(0))]
  		15: RANGE = [0,											MISSINGS(ULONG64(0))]
		ENDCASE



;		===> Must Compare using DOUBLE to avoid wraparound of unsigned integers & bytes (types 1,12,13,15)
   IF (DOUBLE(MIN(NEW)) LT DOUBLE(RANGE(0))) > (DOUBLE(MAX(NEW)) GT DOUBLE(RANGE(1))) THEN BEGIN
    	PRINT,'ERROR: New is not compatible with DATA, Returning DATA unchanged'
    	ERROR=1 & SUBS = -1L & COUNT = 0
    	RETURN,DATA
    ENDIF

  	SUBS = REPLICATE(-1L,N_ELEMENTS(COPY))

;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    FOR N=0,N_ELEMENTS(OLD)-1L DO BEGIN
;			===> Since Data is Numeric then  Old, and New must also be able to be translated into valid numbers
   		IF NUMBER(OLD(N)) NE 1 OR NUMBER(NEW(N)) NE 1 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


			TXT=STRTRIM(OLD(N),2)
;			===> If NAN or -NAN
			IF TXT EQ 'NaN' OR TXT EQ '-NaN' THEN BEGIN
				ok=WHERE(~FINITE(DATA) AND DATA NE !VALUES.F_INFINITY AND DATA NE !VALUES.D_INFINITY,FOUND)
			ENDIF ELSE BEGIN
				OK = WHERE(DATA EQ OLD(N),FOUND)
			ENDELSE

      IF FOUND GE 1 THEN BEGIN
      	COPY(OK) = NEW(N)
      	SUBS(OK)=OK
      	COUNT=COUNT+FOUND
    	ENDIF
    ENDFOR
    OK=WHERE(SUBS NE -1,GOOD)
    IF GOOD GE 1 THEN SUBS=SUBS(OK) ELSE SUBS = -1L
    RETURN, COPY
  ENDIF

; ********************************
; ***** S T R U C T U R E S  *****
; ********************************
  IF TYPE EQ 8 THEN BEGIN
  	ntags = N_TAGS(COPY)
  	TAGNAMES_COPY = TAG_NAMES(COPY)
    COUNTER=0L

		IF N_ELEMENTS(TAGNAMES) EQ 0 THEN BEGIN
;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  		FOR nth = 0L, ntags-1L DO BEGIN
  	  	s_arr = data.(nth)
  	  	COUNT=0
  	  	COPY.(nth) = REPLACE(s_arr,old,new,COUNT=COUNT)
  	  	COUNTER = COUNTER+COUNT
  		ENDFOR
  	ENDIF ELSE BEGIN
;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  		FOR nth = 0L, ntags-1L DO BEGIN
  			OK_TAG = WHERE_IN(STRUPCASE(TAGNAMES),TAGNAMES_COPY(nth),COUNT_TAG)
  			IF COUNT_TAG EQ 0 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.
  	  	s_arr = data.(nth)
  	  	COUNT=0
  	  	COPY.(nth) = REPLACE(s_arr,old,new,COUNT=COUNT)
  	  	COUNTER = COUNTER+COUNT
  		ENDFOR
  	ENDELSE

  	COUNT=COUNTER
  	SUBS = -1L ; Because the subscripts in a structure will be abiguous
   	RETURN, COPY
  ENDIF

  END; #####################  End of Routine ################################

; $ID:	STR_EXTRACT_NUM.PRO,	2020-06-30-17,	USER-KJWH	$
;+
; NAME:
;	ROUTINE_NAME
;
; PURPOSE:
;	This Function extracts numbers from a string with embeded numbers
;
; CATEGORY:
;	STRING
;
; CALLING SEQUENCE:
;	Result = STR_EXTRACT_NUM(Str)
;
; INPUTS:
;	Str:	Input String (scaler)
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;	COMMA:  Allows numbers to have commas, e.g. 2,345,100
;
; OUTPUTS:
;	Number extracted from the input string OR ''
;
; OPTIONAL OUTPUTS:
;	None
;
; COMMON BLOCKS:
;	NONE:
;
; SIDE EFFECTS:
;	NONE:
;
; RESTRICTIONS:
;	This scheme is far from a perfect one to extract correctly any number from a string
;   containing numbers.  Negative numbers are difficult to extract exactly.

;
;
; PROCEDURE:
;
;
; EXAMPLE:
;   str ='-1.234----th22i.,3s is --3a _(1.234_) -3.123--t(es T'
;   arr=STR_EXTRACT_NUM(str) &  print,ARR
;	Create a PICKFILE widget that lets users select only files with
;	the extensions 'pro' and 'dat'.  Use the 'Select File to Read' title
;	and store the name of the selected file in the variable F.  Enter:
;
;  	A=STR_EXTRACT_NUM('12-a-a12.3---') & FOR N=0,N_ELEMENTS(A)-1 DO PRINT,A(N)
;	12
;	12.3

;
; MODIFICATION HISTORY:
; 	Written by:	John E. O'Reilly, December 24,2000
;
;-


  FUNCTION STR_EXTRACT_NUM, Str, COMMA=comma
  PRO_NAME='STR_EXTRACT_NUM'


; ====================>
; Check that input Str is a single string
  SZ=SIZE(Str,/struct)
  IF SZ.TYPE NE 7 OR SZ.N_ELEMENTS NE 1 THEN BEGIN
    PRINT, 'ERROR: Input Str must be A single STRING'
    RETURN,''
  ENDIF


;	===> IF 1 element but array
	IF SZ.N_DIMENSIONS EQ 1 THEN STR=STR[0]


; ====================>
; Make a copy of input Str and add to both ends a number 1
  COPY=' 1 '+STR+' 1 '

; ====================>
; Make a String with valid numeric characters
; + - . 0 1 2 3 4 5 6 7 8 9  and a comma  IF KEYWORD_SET(COMMA)
  B=[STRING(43b),STRING(45b),STRING(46b),STRING(48b),STRING(49b),STRING(50b),$
     STRING(51b),STRING(52b),STRING(53b),STRING(54b),STRING(55b),STRING(56b),STRING(57b)]
  IF KEYWORD_SET(COMMA) THEN B=[B,STRING(44B)]

; =====================>
; Make a single string of target numbers
  B=STRJOIN(B)

; ====================>
; Dimension ARR to Length of copy
  N_ARR =STRLEN(COPY)
  NTH=N_ARR-1L
  ARR=STRARR(N_ARR);

; LLLLLLLLLLLLLLLLLLLLL
; Determine which characters in copy are numeric.
; Set numerics to n and non-numerics to 0
  FOR N=0L,NTH DO BEGIN
    POS= ((STRPOS(B,STRMID(COPY,N,1),0)) GE 0) * N
    ARR(N)= POS
  ENDFOR

; ====================>
; Now negate any elements that are '-' and are preceeded by an '-'
  ARR_NEG =LONARR(N_ARR);
  FOR N=1L,NTH DO BEGIN
    IF STRMID(COPY,N,1) EQ '-' AND  STRMID(COPY,N-1,1) EQ '-' THEN ARR_NEG(N-1:N) = 1 ;
  ENDFOR


; ====================>
; Find just the 'valid' numerics
  NUMS = WHERE(ARR NE 0 AND ARR_NEG NE 1 ,COUNT)
  L = LINDGEN(COUNT-1)

; ====================>
; Determine the locations of breaks in the sequences
  OK = WHERE(NUMS(L+1) NE NUMS(L)+1)
  SUBS=[0,OK+1]

; ====================>
; Extract the numbers from the copy string
  I=LINDGEN(N_ELEMENTS(SUBS))
  LEN= 1> (SUBS(I+1)-SUBS(I))
  ARR= STRMID(COPY, NUMS(SUBS),LEN)

; ===========================>
; If arr has more than the two dummy numbers (first and last)  then ..
  IF N_ELEMENTS(ARR) EQ 2 THEN ARR = '' ELSE ARR = ARR(1:N_ELEMENTS(ARR)-2)

; ====================>
; First, remove any '-' from the right side of any string
; (assume it is a dash or dashes and not a negative sign)

  POS =    STRPOS(ARR,'-',/REVERSE_SEARCH) < (1 > STRPOS(ARR,'-'))
  OK = WHERE( POS EQ STRLEN(ARR)-1,count)
  OK = WHERE( POS GT 1,count)
  IF COUNT GE 1 THEN BEGIN
    FOR NTH=0,COUNT-1L DO BEGIN
      ARR(OK[NTH]) = STRMID(ARR(OK[NTH]),0,POS(OK[NTH]))
    ENDFOR
  ENDIF


; ====================>
; Eliminate any ambiguous values such as '.' or '..'
  OK = WHERE(  (STRLEN(ARR) EQ 0) OR $
               (STRPOS(ARR,'+' ) GE 0 AND STRLEN(ARR) EQ 1) OR $
               (STRPOS(ARR,'++') GE 0 AND STRLEN(ARR) GE 2) OR $
               (STRPOS(ARR,'+-') GE 0 AND STRLEN(ARR) GE 2) OR $
               (STRPOS(ARR,'-+') GE 0 AND STRLEN(ARR) GE 2) OR $
               (STRPOS(ARR,'.+') GE 0 AND STRLEN(ARR) GE 2) OR $
               (STRPOS(ARR,'+.') GE 0 AND STRLEN(ARR) GE 2) OR $
               (STRPOS(ARR,'.-') GE 0 AND STRLEN(ARR) GE 2) OR $
               (STRPOS(ARR,'.' ) GE 0 AND STRLEN(ARR) EQ 1) OR $
               (STRPOS(ARR,'..') GE 0 AND STRLEN(ARR) GE 2) OR $
               (STRPOS(ARR,',' ) GE 0 AND STRLEN(ARR) EQ 1) OR $
               (STRPOS(ARR,',,') GE 0 AND STRLEN(ARR) GE 2) OR $
               (STRPOS(ARR,'-' ) GE 0 AND STRLEN(ARR) EQ 1), $
               COMPLEMENT=SUBS)

; If do not find any good (complement) subscripts then return empty string
  IF SUBS[0] NE -1 THEN ARR = ARR(SUBS) ELSE ARR = ''

  RETURN, ARR

END ; End of Program

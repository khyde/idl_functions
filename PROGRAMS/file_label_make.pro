; $ID:	FILE_LABEL_MAKE.PRO,	2020-06-30-17,	USER-KJWH	$
;#########################################################################3
FUNCTION FILE_LABEL_MAKE,TXT,LST=LST
;+
;	THIS FUNCTION EXTRACTS LST COMPONENTS(SENSOR,SATELLITE,SAT_EXTRA,METHOD,MAP, ETC) FROM TXT STRING
; HISTORY:
;		AUG 6, 2003 TD
;		OCT 5, 2007 TD ADD MATH TO LABEL ORDER
;   JULY 1, 2008 TD, ADD COVERAGE TO LABEL ORDER
;   DEC 12,2014, JOR UPDATED ,FORMATTING, NEW CODE
;   FEB 11, 2015 - KJWH: ADDED 'ALG' AS A DEFAULT
;   DEC 01, 2016 - KJWH: Added IF LABEL EQ [] THEN RETURN [] to avoid errors when a label is not created
;   FEB 17, 2017 - KJWH: Changed the variable LABEL to FLABEL to avoid conflicts with a LABEL program
;                        Now creating an array of label variables and then using STRJOIN to combine them
;-
;******************************
  ROUTINE_NAME='FILE_LABEL_MAKE'
;******************************
;===> DEFAULTS
  LABEL_ORDER=['SENSOR','SATELLITE','SAT_EXTRA','METHOD','SUITE',$
             'COVERAGE','MAP','MAP_SUBSET','PXY','PROD','ALG','STAT','MATH','EDIT','DAYNIGHT','EXT']
  IF NONE(LST) THEN LST=['SENSOR','VERSION','SATELLITE','SAT_EXTRA','METHOD','MAP','MAP_SUBSET','PXY','PROD','ALG','DAYNIGHT']
  DELIM = '-'
  FLABEL = []
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

	IF 	NONE(TXT) OR NONE(LST) THEN RETURN,[]
	FA=PARSE_IT(TXT,/ALL)
	TAGNAMES=TAG_NAMES(FA)
	;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
	FOR NTH=0,N_ELEMENTS(LABEL_ORDER)-1 DO BEGIN
		ALABEL=STRUPCASE(LABEL_ORDER[NTH])
		OK_LST=WHERE(STRUPCASE(LST) EQ ALABEL,COUNT_LST)
		IF COUNT_LST EQ 0 THEN CONTINUE;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		
		OK=WHERE(STRUPCASE(TAGNAMES) EQ ALABEL,COUNT)
		IF COUNT EQ 1 THEN IF FA.(OK) NE '' THEN FLABEL= [FLABEL,FA.(OK)]
		
	ENDFOR;FOR NTH=0,N_ELEMENTS(LABEL_ORDER)-1 DO BEGIN
  ;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

  IF FLABEL EQ [] THEN RETURN, []
  RETURN, STRJOIN(FLABEL,'-') ; Return a '-' joined string

END; #####################  END OF ROUTINE ################################

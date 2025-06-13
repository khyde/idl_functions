; $ID:	DOC_SAVE_MAKE.PRO,	2020-07-08-15,	USER-KJWH	$

	PRO DOC_SAVE_MAKE,DIR_IN=DIR_IN,DIR_OUT=DIR_OUT,DATE_RANGE=DATE_RANGE,CDOM_ALG=CDOM_ALG,PRODUCTS=PRODUCTS,INPUT_RRS=INPUT_RRS,REVERSE_FILES=REVERSE_FILES,$
	                       PERIOD_CODE=PERIOD_CODE,MAP_OUT=MAP_OUT,PX_OUT=PX_OUT,PY_OUT=PY_OUT,OVERWRITE=OVERWRITE

;+
; NAME:
;		DOC_SAVE_MAKE
;
; PURPOSE:;
;		This procedure creates phtytoplankton pigment files using the PAN pigment algorithm
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE:
;
;		PIGMENTS_SAVE_MAKE, Parameter1, Parameter2
;
; INPUTS:
;		Parm1:	Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;		Parm2:	Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;		KEY1:	Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
;
; OUTPUTS:
;		This procedure creates pigment save files 
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Feb 7, 2014 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'DOC_SAVE_MAKE'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''
	SL = DELIMITER(/PATH)

  IF N_ELEMENTS(PERIOD_CODE) NE 1 THEN _PERIOD_CODE ='S'                 ELSE _PERIOD_CODE=PERIOD_CODE
  IF N_ELEMENTS(CDOM_ALG)    GE 1 THEN CALG         = CDOM_ALG           ELSE CALG  = 'MAN_MLR'
  IF N_ELEMENTS(ALGS)        GE 1 THEN _ALGS        = ALGS               ELSE _ALGS = 'MAN_MLR'
  IF N_ELEMENTS(INPUT_RRS)   EQ 0 THEN RRS          = NUM2STR(INPUT_RRS) ELSE RRS   = '412'
  IF N_ELEMENTS(DIR_OUT)     LT 1 THEN DIR_OUT      = DIR_IN       
  IF N_ELEMENTS(DIR_IN) LT 1 THEN STOP
    
  FOR R=0, N_ELEMENTS(RRS)-1 DO BEGIN
    FILES = FILE_SEARCH(DIR_IN+'A_CDOM_'+RRS+'-'+CALG+SL+_PERIOD_CODE+'_*-A_CDOM_'+RRS+'-'+CALG+'.SAVE')
    FILES = DATE_SELECT(FILES,DATE_RANGE[0],DATE_RANGE[1])
    IF FILES EQ [] THEN CONTINUE
    IF KEYWORD_SET(REVERSE_FILES) THEN FILES = REVERSE(FILES)  
      
    PRODS = 'DOC_' + ['NMAB','SMAB'] + '_' + RRS 
    IF N_ELEMENTS(PRODUCTS) GE 1 THEN BEGIN
      OK = WHERE_MATCH(PRODS,PRODUCTS,COUNT,VALID=VALID,COMPLEMENT=COMPLEMENT)
      IF COUNT GE 1 THEN PRODS = PRODUCTS(VALID)          
    ENDIF
    DIR_TEST,DIR_OUT+PRODS+'-'+CALG+SL
    
    FOR NTH = 0L,N_ELEMENTS(FILES)-1L DO BEGIN
      AFILE=FILES[NTH]       
      SAVEFILES = []
      FA=PARSE_IT(AFILE,/ALL)
      IF NONE(MAP_OUT) THEN MAP_OUT = [] ELSE BEGIN 
        MS  = MAPS_SIZE(MAP_OUT)
        IF NONE(PX_OUT) THEN PX_OUT = MS.PX
        IF NONE(PY_OUT) THEN PY_OUT = MS.PY 
      ENDELSE  
      IF MAP_OUT EQ [] THEN MP = FA.MAP ELSE MP = MAP_OUT
  
      FOR PTH = 0L, N_ELEMENTS(PRODS)-1 DO SAVEFILES = [SAVEFILES,DIR_OUT+PRODS(PTH)+'-'+CALG+SL+REPLACE(FA.FIRST_NAME,[FA.MAP,STRUPCASE('A_CDOM_'+RRS+'-'+CALG)],[MP,PRODS(PTH)+'-'+_ALGS  ])+'.SAVE']                            
      INFILES  = AFILE
      IF FILE_MAKE(AFILE,SAVEFILES,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
    
  ;   ===> Read the 490 file    
      DATA=STRUCT_SD_READ(AFILE,STRUCT=DATA_STRUCT,MAP_OUT=MAP_OUT,PX_OUT=PX_OUT,PY_OUT=PY_OUT,ERROR=ERROR,ERR_MSG=ERR_MSG)
      IF ERROR EQ 1 THEN STOP
      IF DATA_STRUCT EQ [] THEN GOTO, DONE
      PRINT, 'Creating DOC data for ' + DIR_OUT+'-'+CALG + DATA_STRUCT.PERIOD
      MISSING=MISSINGS(DATA)
      DATE = PERIOD_2DATE(DATA_STRUCT.PERIOD)
      
      IF RRS EQ '355' THEN STRUCT = DOC_MANNINO(A_CDOM_355=DATA, A_CDOM_412=[], DATE=DATE, REFRESH=refresh, ERROR=ERROR, ERR_MSG=ERR_MSG) 
      IF RRS EQ '412' THEN STRUCT = DOC_MANNINO(A_CDOM_412=DATA, A_CDOM_355=[], DATE=DATE, REFRESH=refresh, ERROR=ERROR, ERR_MSG=ERR_MSG)
      
      IF STRUCT EQ [] THEN GOTO, DONE  
      GONE,DATA
      
      FA = PARSE_IT(SAVEFILES)            
      FOR PTH = 0L, N_ELEMENTS(PRODS)-1 DO BEGIN  
        OK = WHERE_MATCH(FA.SUB,PRODS(PTH)+'-'+_ALGS,COUNT) & IF COUNT EQ 0 THEN STOP
        SAVEFILE = SAVEFILES[OK]            
        POS = WHERE(TAG_NAMES(STRUCT) EQ PRODS(PTH),COUNT) & IF COUNT EQ 0 THEN STOP      
        MISS = WHERE(STRUCT.(POS) NE MISSINGS(STRUCT.(POS)),COUNT_MISS)
        IF COUNT_MISS GT 0 THEN $
        STRUCT_SD_WRITE,SAVEFILE,PROD=VALIDS('PRODS',PRODS(PTH)),ALG=_ALGS,IMAGE=FLOAT(STRUCT.(POS)),MISSING_CODE=MISSINGS(0.0), $
                        DATA_UNITS=UNITS(VALIDS('PRODS',PRODS(PTH))),PERIOD=DATA_STRUCT.PERIOD, SENSOR=DATA_STRUCT.SENSOR, SATELLITE=DATA_STRUCT.SATELLITE,$
                        METHOD=DATA_STRUCT.METHOD, COVERAGE=DATA_STRUCT.COVERAGE, MAP=MP,INFILE=INFILES,NOTES='',ERROR=ERROR
      ENDFOR
      GONE,STRUCT
      DONE:                  
    ENDFOR
  ENDFOR
   
END; #####################  End of Routine ################################

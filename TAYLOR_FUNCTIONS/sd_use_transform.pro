; $Id:	sd_use_transform.pro,	February 09 2011	$

	FUNCTION SD_USE_TRANSFORM, PROD, MATH=MATH, ERROR = error

;+
; NAME:
;		TEMPLATE
;
; PURPOSE:
;		This function determines if data needs to be transformed
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE: _stats_transform=SD_USE_TRANSFORM('CHLOR_A',MATH=MATH)
;
; INPUTS:
;		Parm1:	PRODUCT NAME
;
; OPTIONAL INPUTS:
;		Parm2:
;
; KEYWORD PARAMETERS:
;		KEY1:	Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;		This function returns '' OR 'ALOG' OR 'ALOG10'
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
;
;	PROCEDURE:
;
; EXAMPLE:
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

;		Citations or any other useful notes
;
;
; MODIFICATION HISTORY
;			Written April 2, 2009  Teresa Ducas NMFS Narragansett,RI
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'SD_USE_TRANSFORM'

; ====> Check on Values being present
  IF N_ELEMENTS(PROD) EQ 0 THEN BEGIN
  	ERROR='Must provide Values and PROD (name)'
  	RETURN,''
  ENDIF

; ===> Take only the first prod if it is an array
	APROD=STRUPCASE(PROD(0))	; do not change input PROD but make a copy (aprod)

;	===> See if APROD is hyphenated (special_scale)
	W=STRSPLIT(APROD,'-',/EXTRACT)
	IF N_ELEMENTS(W) EQ 2 THEN APROD=W(0)

	TRANSFORM=''
 IF APROD EQ 'CHLA' OR APROD EQ 'CHLB' OR APROD EQ 'CHLC' OR APROD EQ 'CARO' OR APROD EQ 'ALLO' OR APROD EQ 'FUCO' $
 OR APROD EQ 'PERID' OR APROD EQ 'DIA' OR APROD EQ 'ZEA' OR APROD EQ 'LUT' OR APROD EQ 'NEO' OR APROD EQ 'VIOLA' THEN APROD = 'PIGMENTS'
 CASE STRUPCASE(APROD) OF

;*********************************************************
;*************  SEAWIFS, MODIS, CZCS ,PRODUCTS  **********
;*********************************************************
	'A_CDOM_300'	: TRANSFORM='ALOG'
	'A_CDOM_355'	: TRANSFORM='ALOG'
	'A_CDOM_443'  : TRANSFORM='ALOG'
	'ANGSTROM_510': TRANSFORM=''
	'ANGSTROM_520': TRANSFORM=''
	'CDOM_INDEX'  : TRANSFORM='ALOG'
	'CHLOR_A'			: TRANSFORM='ALOG'	
	'CZCS_PIGMENT': TRANSFORM='ALOG'
	'DOC'					: TRANSFORM=''
	'EPSILON'			: TRANSFORM=''
	'L2_FLAGS'		: TRANSFORM=''
	'MBR'					: TRANSFORM=''
	'NLW_412'			: TRANSFORM=''
	'NLW_443'			: TRANSFORM=''
	'NLW_490'			: TRANSFORM=''
	'NLW_550'			: TRANSFORM=''
	'NLW_510'			: TRANSFORM=''
	'NLW_520'			: TRANSFORM=''
	'NLW_555'			: TRANSFORM=''
	'NLW_670'			: TRANSFORM=''
	'PAR'					: TRANSFORM=''
	'PIGMENTS'    : TRANSFORM='ALOG'
	'POC'					: TRANSFORM='ALOG'
	'SENZ'				: TRANSFORM=''
	'TAUA_510'		: TRANSFORM=''
	'TAU_670'			: TRANSFORM=''
	'TAUA_865'		: TRANSFORM=''


;*********************************************************
;**************      SST PRODUCTS    *********************
;*********************************************************

	'SST'					: TRANSFORM=''



;*********************************************************
;**************   PRIMARY PRODUCTION        **************
;*********************************************************

	'BOTTOM_FLAG'		: TRANSFORM=''
	'CHLOR_EUPHOTIC': TRANSFORM=''
	'K_PAR'					: TRANSFORM=''
	'PPD'						: TRANSFORM='ALOG'
	'PPY'           : TRANSFORM='ALOG'



;*********************************************************
;**************   SEADAS FLAGS     **************
;*********************************************************

	'CLDICE'		: TRANSFORM=''
	'ATMFAIL'		: TRANSFORM=''
	'LAND'			: TRANSFORM=''
	'BADANC'		: TRANSFORM=''
	'HIGLINT'		: TRANSFORM=''
	'HILT'			: TRANSFORM=''
	'HISATZEN'	: TRANSFORM=''
	'COASTZ'		: TRANSFORM=''
	'NEGLW'			: TRANSFORM=''
	'STRAYLIGHT': TRANSFORM=''
	'COCCOLITH'	: TRANSFORM=''
	'TURBIDW'		: TRANSFORM=''
	'HISOLZEN'	: TRANSFORM=''
	'HITAU'			: TRANSFORM=''
	'LOWLW'			: TRANSFORM=''
	'CHLFAIL'		: TRANSFORM=''


	ELSE: BEGIN
	ERROR='PROD NOT FOUND'
	RETURN, ''
	END
	ENDCASE ;  CASE APROD OF;
; |||||||||||||||||||||||||||||||||



	; NEED TO CHECK IF MATH PROVIDED
	IF KEYWORD_SET(MATH) THEN BEGIN
		; We are checking for this in ts_subareas.pro
		IF MATH EQ 'RATIO' THEN TRANSFORM='ALOG'
		IF MATH EQ 'GRAD_DIR' THEN TRANSFORM=''
		IF MATH EQ 'GRAD_MAG_RATIO' THEN TRANSFORM='ALOG'
	ENDIF

	RETURN,TRANSFORM
	END; #####################  End of Routine ################################

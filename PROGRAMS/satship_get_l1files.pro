; $ID:	SATSHIP_GET_L1FILES.PRO,	2020-07-08-15,	USER-KJWH	$

FUNCTION SATSHIP_GET_L1FILES, SATFILES, L1DIR, ERROR=ERROR, ERR_MSG=ERR_MSG

;+
; NAME:
;   SATSHIP_GET_L1FILES.PRO
;
; PURPOSE:
;   Look at dates of the satship L2 files and determine which L1 files should processed in SeaDAS  
;
; CATEGORY:
;   SATSHIP Utilities
;
; CALLING SEQUENCE:
;
; INPUTS:
;   INFILES:   SEAWIFS, MODIS or other L2 files
;   L1DIR:     Directory to find the L1 files
;   
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   This function returns a list of files to process in SeaDAS
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; PROCEDURE:
;     This is usually a description of the method, or any data manipulations
;
; EXAMPLES:
;     L1FILES = SATSHIP_GET_L1FILES(SATFILES, L1DUR, HOURS=24, ERROR=ERROR, ERR_MSG=ERR_MSG)
;   
; NOTES:
;
; MODIFICATION HISTORY:
;     Written May 14, 2015 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov) 
;     
;-
; ****************************************************************************************************

  ROUTINE_NAME='SATSHIP_GET_L1FILES'
  ERROR = 0
  ERR_MSG = ''
  AS=DELIMITER(/ASTER)
  DASH=DELIMITER(/DASH)
  UL=DELIMITER(/UL)
  
  IF NONE(SATFILES) THEN BEGIN
    ERROR = 1
    ERR_MSG = 'ERROR: Must provide L2 satfiles'
    PRINT, ERR_MSG
    RETURN, []
  ENDIF
  
  IF NONE(L1DIR) THEN BEGIN
    ERROR = 1
    ERR_MSG = 'ERROR: Must provide L1 directory to search for files'
  ENDIF
    
  FP = PARSE_IT(SATFILES)
  DP = DATE_PARSE(PERIOD_2DATE(FP.PERIOD))
  SATDATE = DP.DATEDOY
  DATERANGE = MINMAX(DP.DATE)
  
  L1FILES = FILE_SEARCH(L1DIR + '*.*')
  L1FILES = DATE_SELECT(L1FILES,DATERANGE[0],DATERANGE[1],/SATDATE)
  FP1 = FILE_PARSE(L1FILES)
  OK = WHERE_MATCH(SATDATE,STRMID(FP1.FIRST_NAME,1),COUNT,COMPLEMENT=COMPLEMENT,VALID=VALID)
  
  IF COUNT GE 1 THEN RETURN, L1FILES(VALID) ELSE RETURN, []

END

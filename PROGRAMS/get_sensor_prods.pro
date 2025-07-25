; $ID:	GET_SENSOR_PRODS.PRO,	2020-06-26-15,	USER-KJWH	$
;#############################################################################################################
	PRO GET_SENSOR_PRODS
	
;  PRO GET_SENSOR_PRODS
;+
; NAME:
;		GET_SENSOR_PRODS
;
; PURPOSE: THIS PROGRAM EXTRACTS THE UNIQUE PRODUCTS FROM TXT FILES FROM SEARCHES OF NASA OCEAN COLOR DATA SITE http://oceandata.sci.gsfc.nasa.gov/search/file_search.cgi
;
; CATEGORY:
;		PALETTE
;		 
;
; CALLING SEQUENCE: GET_SENSOR_PRODS
;
; INPUTS: NONE
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: 
;		
;; EXAMPLES:
;         
;
;  GET_SENSOR_PRODS
;
; MODIFICATION HISTORY:
;			WRITTEN MAR 12,2013 J.O'REILLY
;			
;			
;			
;#################################################################################
;
;
;-
;***********************************
ROUTINE_NAME  = 'GET_SENSOR_PRODS'
;***********************************
; CONSTANTS
SITE = 'http://oceandata.sci.gsfc.nasa.gov/cgi/getfile/'
FILES = FILE_SEARCH('D:\IDL\DATA\','*_DAY_L3M-MISSION.TXT')
PLIST,FILES
DB = REPLICATE(CREATE_STRUCT('SENSOR','', 'PRODS',''),N_ELEMENTS(FILES))
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR _FILE = 0,N_ELEMENTS(FILES)-1 DO BEGIN
FILE = FILES(_FILE)
PFILE,FILE,/R
FN = FILE_PARSE(FILE)
T = STR_SEP(FN.NAME,'_DAY')
SENSOR = FIRST(T)
DB(_FILE).SENSOR = SENSOR
TXT = READ_TXT(FILE)
PN,TXT,'LINES'
;===> FIND ONLY VALID LINES 
OK = WHERE_STRING(TXT,SITE,COUNT)
IF COUNT EQ 0 THEN MESSAGE,'ERROR: FILE IS NOT VALID'
TXT=TXT[OK]
;NOW REMOVE ANY DUPLICATES
S = SORT(TXT)
TXT = TXT(S)
U=UNIQUE(TXT)
TXT = TXT(U)
PN,TXT,' LINES'
FN = FILE_PARSE(TXT)
NAMES= FN.NAME

NAMES = STR_BREAK(NAMES,SITE)
NAMES = NAMES(*,0)
FN=FILE_PARSE(NAMES)
FN=FILE_PARSE(FN.NAME)
NAMES = FN.NAME_EXT
SATDATES = FN.FIRST_NAME

T = STR_BREAK(NAMES,'.L3m_DAY')
PRODS = '.L3m_DAY' +T(*,1)
PLIST,PRODS(0:9)

SETS = WHERE_SETS(PRODS)
PRODS = SETS.VALUE
D = CREATE_STRUCT('SENSOR',SENSOR, 'PRODS',PRODS)
STOP

ENDFOR;FOR _FILE = 0,N_ELEMENTS(FILES)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF




END; #####################  END OF ROUTINE ################################

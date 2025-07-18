; $ID:	STATS_PHENOLOGY.PRO,	2020-07-29-14,	USER-KJWH	$
;#############################################################################################################
	PRO STATS_PHENOLOGY,FILES,DIR_OUT = DIR_OUT,MAP_OUT = MAP_OUT
	
;  PRO STATS_PHENOLOGY
;+
; NAME:
;		STATS_PHENOLOGY
;
; PURPOSE: THIS PROGRAM CALCULATES THE TIMING OF THE MIN AND MAX PERIOD
;
; CATEGORY:
;		MATH
;		 
;
; CALLING SEQUENCE:STATS_PHENOLOGY
;
; INPUTS: 
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS:  STRUCT_SD_WRITE,SAVEFILE [MONTH MIN, MONTH MAX]
;		
;; EXAMPLES:
;  STATS_PHENOLOGY
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN AUG 1,2012 J.O'REILLY
;			NOV 9,2012,JOR,MADE MIN_PER & Max_PER int  =REPLICATE(MISSINGS(0),[PX,PY])
;                   OK_MAX = WHERE(DATA GT MAX_DATA AND DATA NE MISSINGS(DATA),COUNT_MAX)
;                   BECAUSE MAX_PER WAS INITIALIZED TO -1, MUST CHANGE TO MISSINGS CODE [TO AVOID BLACK LAND]
;     FEB 26,2013,JOR ADDED KEYWORD MAP_OUT DEFAULT = ROBINSON


;#################################################################################
;
;
;-
;	*******************************************
ROUTINE_NAME='STATS_PHENOLOGY'
; *******************************************
; STOP PRINT N_ELEMENTS  ENDFOR SWITCHES  RETURN    ,
; 

IF N_ELEMENTS(FILES) NE 36 THEN MESSAGE,'ERROR:  36 !MONTH FILES ARE REQUIRED'
FN = FILE_PARSE(FILES)
PER = VALID_PERIODS(FN.NAME)
IF FIRST(PER.PERIOD_CODE) NE '!MONTH' THEN MESSAGE,'ERROR: ALL FILES MUST !MONTH FILES '
IF SAME(PER.PERIOD_CODE) EQ 0 THEN MESSAGE,'ERROR: ALL FILES MUST BE THE SAME PERIOD '

PRODS = VALIDS('PRODS',FN.NAME)
MAP_IN = VALID_MAPS(FIRST(FN.NAME))
IF SAME(PRODS) EQ 0 THEN MESSAGE,'ERROR: ALL FILES MUST HAVE THE SAME PROD'
MAP_OUT = 'ROBINSON'
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
FOR _FILE = 0,N_ELEMENTS(FILES)-1 DO BEGIN
;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
POF,_FILE,FILES
IF _FILE EQ 0 THEN BEGIN
FILE = FILES(_FILE)
DATA = STRUCT_SD_READ(FILE)
M = MAPS_SIZE(MAP_IN)
MAP_IN=M.MAP
PX_OUT=M.PX
PY_OUT=M.PY
GOTO,SKIP
DATA = MAP_REMAP(DATA, MAP_IN=map_in, MAP_OUT=map_out, PX_OUT=px_out, PY_OUT=py_out,$
                      SUBS=subs, NULL=null,$
                      LONMIN=Lonmin, LONMAX=Lonmax, LATMIN=Latmin,LATMAX=Latmax, $
                      CONTROL_LONS=control_lons, CONTROL_LATS=control_lats, $
                      CONTROL_SUBS_LON=control_subs_lon, CONTROL_SUBS_LAT=control_subs_lat,$
                      SPEED = SPEED,ERROR=error,SENSOR=SENSOR)
SKIP:

SZ = SIZEXYZ(DATA)
PX=SZ.PX
PY = SZ.PY

MIN_DATA =REPLICATE(FIRST(DATA),[PX,PY])
MAX_DATA =-1*REPLICATE(FIRST(DATA),[PX,PY])
MIN_PER =REPLICATE(MISSINGS(0),[PX,PY])
MAX_PER =-1*REPLICATE(MISSINGS(0),[PX,PY])

ENDIF;IF _FILE EQ 0 THEN BEGIN
DATA = STRUCT_SD_READ(FILES(_FILE))
PRINT,'DATA:',MM(DATA,/FIN)
IF PER(_FILE).PERIOD_CODE EQ '!MONTH' THEN CODE = FIX(PER(_FILE).MONTH_START)

OK_MIN = WHERE(DATA LT MIN_DATA,COUNT_MIN)
IF COUNT_MIN GE 1 THEN BEGIN
  MIN_DATA(OK_MIN) = DATA(OK_MIN)
  MIN_PER(OK_MIN) = CODE
ENDIF;IF COUNT_MIN GE 1 THEN BEGIN

OK_MAX = WHERE(DATA GT MAX_DATA AND DATA NE MISSINGS(DATA),COUNT_MAX)
IF COUNT_MAX GE 1 THEN BEGIN
  MAX_DATA(OK_MAX) = DATA(OK_MAX)
  ;STOP
  MAX_PER(OK_MAX) = CODE
ENDIF;IF COUNT_MAX GE 1 THEN BEGIN


ENDFOR;FOR _FILE = 0,N_ELEMENTS(FILES)-1 DO BEGIN
;'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
OVERWRITE=1
;STOP
;===> BECAUSE MAX_PER WAS INITIALIZED TO -1, MUST CHANGE TO MISSINGS CODE
OK = WHERE(MAX_PER LT 0,COUNT)
MAX_PER[OK] = MISSINGS(MAX_PER)
FA = FILE_ALL(FIRST(FILES))
MAP=FA.MAP
PROD = FA.PROD

;*******************
;===> MONTH_MIN
ASTAT='MONTH_MIN'
SAVEFILE = DIR_OUT + '!ANNUAL-'+FA.SENSOR +'-'+ FA.SATELLITE +'-'+MAP +'-' + FA.METHOD +'-' +PROD +'-' +ASTAT   +'.SAVE'
STRUCT_SD_WRITE,SAVEFILE,PROD=ASTAT,ASTAT=ASTAT, $
                      IMAGE=MIN_PER,    MISSING_CODE=MISSINGS(MIN_PER), $
                      MAP=MAP, $
                      INFILE=FILES,$
                      NOTES = 'CHLOR_A',      ERROR=ERROR
                      
  
 PNGFILE = REPLACE(SAVEFILE,'.SAVE','.PNG')
 STRUCT_SD_2PNG, SAVEFILE,OVERWRITE=OVERWRITE,/ADD_COLORBAR,/ADD_LAND,/ADD_LONLAT,BACKGROUND=254,DIR_OUT = DIR_OUT,MAP_OUT = MAP_OUT
                      
  
;*******************
;===> MONTH_MAX
ASTAT='MONTH_MAX'
SAVEFILE = DIR_OUT + '!ANNUAL-'+FA.SENSOR +'-'+ FA.SATELLITE +'-'+MAP +'-' + FA.METHOD +'-' +PROD +'-' +ASTAT   +'.SAVE'
STRUCT_SD_WRITE,SAVEFILE,PROD=ASTAT,ASTAT=ASTAT, $
                        IMAGE=MAX_PER,    MISSING_CODE=MISSINGS(MAX_PER), $
                        MAP=MAP, $
                        INFILE=FILES,$
                        NOTES = 'CHLOR_A',      ERROR=ERROR
  
 PNGFILE = REPLACE(SAVEFILE,'.SAVE','.PNG')
 STRUCT_SD_2PNG, SAVEFILE,OVERWRITE=OVERWRITE,/ADD_COLORBAR,/ADD_LAND,/ADD_LONLAT,BACKGROUND=254,DIR_OUT = DIR_OUT,MAP_OUT = MAP_OUT
                      

DONE:          
	END; #####################  END OF ROUTINE ################################

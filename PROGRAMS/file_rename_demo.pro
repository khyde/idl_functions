; $ID:	FILE_RENAME_DEMO.PRO,	2020-07-01-12,	USER-KJWH	$
;#############################################################################################################
	PRO FILE_RENAME_DEMO
	
;  PRO FILE_RENAME_DEMO
;+
; NAME:
;		FILE_RENAME_DEMO
;
; PURPOSE: THIS PROGRAM DEMONSTRATES FILE_RENAME ! EDIT IT AS NEEDED  !
;
; CATEGORY:
;		MATH
;		 
;
; CALLING SEQUENCE:FILE_RENAME_DEMO
;
; INPUTS: 
;		
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: PRINTS TO SCREEN
;		
;; EXAMPLES:
;  FILE_RENAME_DEMO
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:
;			WRITTEN AUG 1,2012 J.O'REILLY
;#################################################################################
;
;
;-
;	*******************************************
ROUTINE_NAME='FILE_RENAME_DEMO'
; *******************************************

; ===> USEFUL WORDS FOR SEARCHING:
; STOP PRINT N_ELEMENTS  ENDFOR SWITCHES  RETURN    ,
; 
DIR_IN = 'E:\SMI\FRONTS\STATS\'
OLD = '-CHLOR_A_GRAD_X-'
NEW = '-CHLOR_A-GRAD_X-'
TEST = 1
FILES=FILE_SEARCH(DIR_IN,'*'+NEW +'*.SAVE')

HELP,FILES
STOP
NAME_CHANGE = [OLD,NEW]
FILE_RENAME, FILES, $
                 NAME_CHANGE=name_change,$
                 NAME_PREFIX=name_prefix, NAME_ADD = name_add,$
                 EXT_ADD = ext_add, $
                 EXT_REMOVE=ext_remove,$
                 EXT_NEW = ext_new, $
                 LOWER=lower, UPPER=upper,$
                 LOW_EXT = LOW_EXT,UP_EXT=up_ext,$
                 TEST=test


STOP

DIR_OUT = 'I:\SMI\SAVE\'
TXT ='-OCTS_SEAWIFS_TERRA_AQUA_MERIS-SMI-2010_12-'
PROD = 'A_CDOM'
FILES = FILE_SEARCH(DIR_OUT,'*'+ PROD +'.SAVE')
PN,FILES

TEST = 1
NAME_CHANGE = [ TXT,'-SEAWIFS-SMI-2010_12-'] 

FILE_RENAME, FILES, $
                 NAME_CHANGE=NAME_CHANGE,$
                 NAME_PREFIX=NAME_PREFIX, NAME_ADD = NAME_ADD,$
                 EXT_ADD = EXT_ADD, $
                 EXT_REMOVE=EXT_REMOVE,$
                 EXT_NEW = EXT_NEW, $
                 LOWER=LOWER, UPPER=UPPER,$
                 LOW_EXT = LOW_EXT,UP_EXT=UP_EXT,$
                 TEST=TEST
STOP
FILES = FILE_SEARCH('I:\SMI\I_ISERIES_SAVE\','!D_*-PAT-SMI-SST-INTERP-TS_IMAGES.SAVE')& PN,FILES
TEST = 0
TXT ='TS_IMAGES'

NAME_CHANGE = [ TXT,'TS_IMAGES-MEAN'] 

FILE_RENAME, FILES, $
                 NAME_CHANGE=NAME_CHANGE,$
                 NAME_PREFIX=NAME_PREFIX, NAME_ADD = NAME_ADD,$
                 EXT_ADD = EXT_ADD, $
                 EXT_REMOVE=EXT_REMOVE,$
                 EXT_NEW = EXT_NEW, $
                 LOWER=LOWER, UPPER=UPPER,$
                 LOW_EXT = LOW_EXT,UP_EXT=UP_EXT,$
                 TEST=TEST
                 
                 
   FILES = FILE_SEARCH('I:\SMI\STATS_ALL\','*-CHLOR_A-*.SAVE')& PN,FILES
TEST = 0
TXT ='-2010_12-'
;!M_199611-2010_12-CHLOR_A-NUM.SAVE
NAME_CHANGE = [ TXT,'-SMI-2010_12-'] 

FILE_RENAME, FILES, $
                 NAME_CHANGE=NAME_CHANGE,$
                 NAME_PREFIX=NAME_PREFIX, NAME_ADD = NAME_ADD,$
                 EXT_ADD = EXT_ADD, $
                 EXT_REMOVE=EXT_REMOVE,$
                 EXT_NEW = EXT_NEW, $
                 LOWER=LOWER, UPPER=UPPER,$
                 LOW_EXT = LOW_EXT,UP_EXT=UP_EXT,$
                 TEST=TEST         
   FILES = FILE_SEARCH('I:\SMI\SST\','!*-SST-*.SAVE')& PN,FILES
   FN = FILE_PARSE(FILES)
TEST = 1
TXT ='D_'
;!M_199611-2010_12-CHLOR_A-NUM.SAVE
NAME_CHANGE = [ TXT,'!D_'] 

FILE_RENAME, FILES, $
                 NAME_CHANGE=NAME_CHANGE,$
                 NAME_PREFIX=NAME_PREFIX, NAME_ADD = NAME_ADD,$
                 EXT_ADD = EXT_ADD, $
                 EXT_REMOVE=EXT_REMOVE,$
                 EXT_NEW = EXT_NEW, $
                 LOWER=LOWER, UPPER=UPPER,$
                 LOW_EXT = LOW_EXT,UP_EXT=UP_EXT,$
                 TEST=TEST             

DONE:          
	END; #####################  END OF ROUTINE ################################

; $ID:	STATS_2CSV_DEMO.PRO,	2014-04-29	$
;#############################################################################################################
	PRO STATS_2CSV_DEMO
	
;  PRO STATS_2CSV_DEMO
;+
; NAME:
;		STATS_2CSV_DEMO
;
; PURPOSE: THIS PROGRAM IS A DEMO FOR WRITING STATS TO A CSV FILE
;
; CATEGORY:
;		PLOT
;		 
;
; CALLING SEQUENCE: STATS_2CSV_DEMO
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
;  STATS_2CSV_DEMO
;
; MODIFICATION HISTORY:
;			WRITTEN APR 18,2013 J.O'REILLY
;			
;			
;			
;#################################################################################
;
;
;-
;********************************
ROUTINE_NAME  = 'STATS_2CSV_DEMO'
;********************************

DATA = [1,2,3,4,5]
FILE_NAME= ROUTINE_NAME+ '.CSV'
DB =STATS_2CSV( DATA,$

            FILE_NAME=FILE_NAME, PERIOD=PERIOD,METHOD=METHOD, PROD=PROD, MAP=MAP, SUBAREA=SUBAREA, LABEL=LABEL,  NOTES=NOTES,$
            CSV_FILE=CSV_FILE, $
            REFRESH=REFRESH,$
            ERROR = ERROR)
            ST,DB
STOP

END; #####################  END OF ROUTINE ################################

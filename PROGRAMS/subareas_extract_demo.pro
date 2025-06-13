; $ID:	SUBAREAS_EXTRACT_DEMO.PRO,	2020-04-14-13,	USER-KJWH	$
; #########################################################################; 
PRO SUBAREAS_EXTRACT_DEMO
;+
; PURPOSE:  DEMO FOR SUBAREAS_EXTRACT
;
; CATEGORY: SUBAREAS FAMILY
;
;
; INPUTS: NONE
;
;
; KEYWORDS:  NONE

; OUTPUTS: 
;
;; EXAMPLES:
;
; MODIFICATION HISTORY:
;     FEB 20, 2017  WRITTEN BY: J.E. O'REILLY
;-
; #########################################################################

;********************************
  ROUTINE = 'SUBAREAS_EXTRACT_DEMO'
;********************************

  SL = PATH_SEP()

  DATERANGE  = ['1998','1999']
  REPRO      = 'L3B9_R2015'
  DATASET    = 'OC-SEAWIFS-9KM'  ; 'SST-AVHRR-4KM'
  SUBDIR     = 'NC'
  DIR_DATA   = !S.DATASETS + DATASET + SL + REPRO + SL + SUBDIR + SL
  TARGET     = 'S*CHL*'
  FILES      = FLS(DIR_DATA + TARGET) & PN,FILES
  MAPP       = 'GL8'
  DIR_OUT    = !S.DEMO + 'SUBAREAS_EXTRACT_DEMO' + SL & DIR_TEST, DIR_OUT

  SUBAREAS_EXTRACT,FILES, MAPP=MAPP, DIR_OUT=DIR_OUT
  STOP
  SUBAREAS_PLOT


END; #####################  END OF ROUTINE ################################

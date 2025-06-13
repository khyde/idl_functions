; $ID:	GET_DATASET.PRO,	2020-07-08-15,	USER-KJWH	$

  FUNCTION GET_DATASET, FILES

;+
; NAME:
;   GET_DATASET
;
; PURPOSE:
;   This function will parse out the DATASET name (if available) from a file name
;
; CATEGORY:
;   File parsing
;
; CALLING SEQUENCE:
;
;   Result = GET_DATASET(FILES
;
; INPUTS:
;   FILES:  Filenames to parse
;
; OPTIONAL INPUTS:
;   NA
;
; KEYWORD PARAMETERS:
;   NA
;
; OUTPUTS:
;   This function returns the DATASET name(s) if found in the filename
;
; OPTIONAL OUTPUTS:
;   
; EXAMPLE:
;
; NOTES:
;   
; MODIFICATION HISTORY:
;			Written:  February 22, 2017 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'GET_DATASET'
	SL = PATH_SEP()
	
	IF NONE(FILES) THEN RETURN, ''
	
	DATASETS = []
	FOR N=0, N_ELEMENTS(FILES)-1 DO BEGIN
	  T = STR_SEP(FILES(N),SL)
	  CASE [1] OF
	    HAS(T,'DATASET') EQ 1: POS = WHERE(T EQ 'DATASETS')
	    HAS(T,'PPD')     EQ 1: POS = WHERE(T EQ 'PPD')
	    HAS(T,'FRONTS')  EQ 1: POS = WHERE(T EQ 'FRONTS')
	    ELSE: POS = -1
	  ENDCASE
	  IF POS EQ -1 THEN DATASETS = [DATASETS,''] ELSE DATASETS = [DATASETS,T(POS+1)] ; If /DATASETS/ not found in the file name, then return blank string
  ENDFOR
  RETURN, DATASETS

END; #####################  End of Routine ################################

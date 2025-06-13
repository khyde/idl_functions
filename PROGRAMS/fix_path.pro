; $ID:	FIX_PATH.PRO,	2014-09-17-15	$
;######################################################################################
	FUNCTION FIX_PATH, DIR

;+
; NAME:
;		FIX_PATH
;
; PURPOSE: THIS FUNCTION REPLACES THE PATH DELIMITER ['\' OR '/'] 
;		       WITH THE CORRECT DELIMITER FOR THE OPERATING SYSTEM.
;
; CATEGORY:
;		FILES
;

;
;		RESULT = FIX_PATH(DIR)
;
; INPUTS:
;		DIR:	DIRECTORY NAME
;
; OPTIONAL INPUTS:
;		NONE
;
; KEYWORD PARAMETERS:
;		NONE
;
; OUTPUTS:
;		DIR WITH THE CORRECT PATH DELIMITER FOR THE OPERATING SYSTEM
;
; EXAMPLES:  
;      PRINT,FIX_PATH('D:\JUNK\')
;      PRINT,FIX_PATH('D:/JUNK/')
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			WRITTEN NOV 1, 2011 BY K.J.W.HYDE, 28 TARZWELL DRIVE, NMFS, NOAA 02882 (KIMBERLY.HYDE@NOAA.GOV)
;			SEP 17,2014,JOR, USING PATH_SEP(), FORMATTING,ADDED EXAMPLES
;######################################################################################
;-
;*************************
ROUTINE_NAME = 'FIX_PATH'
;*************************	

  SL = PATH_SEP()
  
  DIR = REPLACE(DIR,'/',SL)
  DIR = REPLACE(DIR,'\',SL)
  RETURN, DIR
	END; #####################  END OF ROUTINE ################################

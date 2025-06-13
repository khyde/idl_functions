; $Id:	nice_range_demo.pro,	February 13 2007	$

PRO NICE_RANGE_DEMO
;+
; NAME:
; 	NICE_RANGE_DEMO
;
; PURPOSE:
;		DEMO FOR NICE_RANGE
;
; CATEGORY:
;		MATH
;
; CALLING SEQUENCE:
;		NICE_RANGE_DEMO
;
; INPUTS:
;		NONE
;
; OUTPUTS:
;  	Prints results from NICE_RANGE
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan 5,1999
;
;-

;	***********************************************************************************
	ROUTINE_NAME = 'NICE_RANGE_DEMO'


  DATA = [0.0022, 0.0083D]
  RANGE = NICE_RANGE(DATA )
  PRINT,data,RANGE
	PRINT


 	DATA = [0.011, 0.008]
  RANGE = NICE_RANGE(DATA )
  PRINT,data,RANGE
	PRINT


 	DATA = [0.011, 3122]
  RANGE = NICE_RANGE(DATA )
  PRINT,data,RANGE


	DATA = [1E8, 3122]
  RANGE = NICE_RANGE(DATA )
  PRINT,data,RANGE

  END; #####################  End of Routine ################################


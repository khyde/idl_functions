; $ID:	DOC_MANNINO_NYB.PRO,	2020-07-08-15,	USER-KJWH	$

 FUNCTION DOC_MANNINO_NYB, A_CDOM_355=A_CDOM_355, DATE=DATE,  REFRESH=refresh, ERROR=ERROR

;+
; NAME:
;		DOC_MANNINO
;
; PURPOSE:
;		This function estimates DOC concentrations using the Mannino algorithm and Absorption at 355nm

; CATEGORY:
;		Algorithm
;
; CALLING SEQUENCE:
;
;		Result = DOC_MANNINO_NYB( A_CDOM_355=A_CDOM_355, DATE=DATE)
;
; INPUTS:
;		A_CDOM_355..Absorption by CDOM at 355nm
;   DATE........Date (i.e. yyyymmdd or yyyymmddhh or yyyymmddhhmm format)
;
; KEYWORD PARAMETERS:
;		REFRESH.... Reinitializes variables in COMMON MEMORY
;
; OUTPUTS:
;		This function returns micromolar DOC concentration
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; COMMON BLOCKS:
;		COMMON COMMON_DOC_MANNINO, WEIGHT_WINTER, WEIGHT_SUMMER
;		The weight_winter and weight_summer are stored in common to avoid computing these weights each time
;		the routine is called.
;
;
; RESTRICTIONS:  Must provide both A_CDOM_355 and DATE so that the algorithm may deterimine the day of year and
;								 the weight factors to apply to the two seasonal functions
;
;	PROCEDURE:
;		This algorithm for the New York Bight uses two seasonal functions relating ACDO at 355nm to Dissolved Organic Carbon (micromolar):
;		FALL-WINTER-SPRING FUNCTION: DOC=1/(ALOG(A_CDOM_355[OK])*(-0.0048650) + 0.0074394)
;		SUMMER FUNCTION:						 DOC=1/(ALOG(A_CDOM_355[OK])*(-0.002923)  + 0.0062469)

;Fall/Winter/Spring DOC (May to October)
;DOC = 1/(alog(A_CDOM355)*(-0.0048650) + 0.0074394)

;Summer DOC (July to September)
;DOC = 1/(alog(A_CDOM355)*(-0.0029492) + 0.0062629)
;
;		Based on the input DATE this routine switches between these two seasonal functions.
;		During the transition period between seasons the result is based on a weighting/blending of the
;		estimates from each of the two seasonal functions.
;		The blending of the two functions is accomplished by using BLEND.PRO which provides a weight factor ranging from
;		0 to 1 (or 1 to 0) which asymptotically approaches 0 and 1 to avoid kinks and inflections.
;
;
; EXAMPLE:
;		Result = DOC_MANNINO(A_CDOM_355=0.4, DATE='20060521') & print,result
;		Result = DOC_MANNINO(A_CDOM_355=[0.4,0.4,0.4,0.4,0.4], DATE=['20040511','20040605', '20040701', '20041016', '20041110' ]) & print,result
;
;
;		Run the Demo program:  DOC_MANNINO_DEMO.PRO
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)
;
; MODIFICATION HISTORY:
;   Algorithm by A. Mannino, NASA, GSFC Version:  March 19, 2010
;   Program written by K.J.W.Hyde (KIMBERLY.HYDE@NOAA.GOV), March 19, 2010
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'DOC_MANNINO'
	ERROR = ''



;	***********************************************************
	COMMON COMMON_DOC_MANNINO, WEIGHT_WINTER, WEIGHT_SUMMER
; Make two 367 Day of Year Functions to apply to the two Seasonal DOC Equations
;	***********************************************************

;	===> CHECK If WEIGHT_WINTER or WEIGHT_SUMMER does not exist. If not then make them and store in COMMON Memory
	IF N_ELEMENTS(WEIGHT_WINTER) NE 367 OR N_ELEMENTS(WEIGHT_SUMMER) NE 367 OR KEYWORD_SET(REFRESH) THEN BEGIN

		WEIGHT_WINTER = FLTARR(367) ; Note 367 so that indices may start at doy 1 and end at 366 for leap years
		WEIGHT_SUMMER = FLTARR(367)

;		===> Dates
		JAN_01 	= DATE_2DOY('20200101') ; Jan 1, 	2020
		MAY_11	= DATE_2DOY('20200511') ; May 11,	2020
		JUN_30 	= DATE_2DOY('20200630') ; Jun 30, 2020
		SEP_20	= DATE_2DOY('20200920') ;	Sep 20, 2020
		NOV_10	=	DATE_2DOY('20201110') ; Nov 10, 2020
		DEC_31	=	DATE_2DOY('20201231') ; Dec 31; 2020

;		===> Initialize periods when weighting is full [1] for one of the two functions
		WEIGHT_WINTER(JAN_01:MAY_11) = 1
		WEIGHT_WINTER(NOV_10:DEC_31) = 1
		WEIGHT_SUMMER(JUN_30:SEP_20) = 1


;		===> Get the Increasing blending fraction for the MAY_11:JUN_30
;			 	 period (zero at beginning and 1 at the end of the period)
		DOYS = MAY_11 + INDGEN(JUN_30-MAY_11+1)
		F = BLEND(DOYS)
	 	WEIGHT_SUMMER(MAY_11:JUN_30) = F ;
	 	WEIGHT_WINTER(MAY_11:JUN_30) = 1-F ;

;		===> Get the Decreasing blending fraction for the SEP_20:NOV_10
;			 	 period (1 at beginning and zero at the end of the period)
		DOYS = SEP_20 + INDGEN(NOV_10-SEP_20+1)
		F = BLEND(DOYS,/DOWN)
	 	WEIGHT_SUMMER(SEP_20:NOV_10) = F ;
	  WEIGHT_WINTER(SEP_20:NOV_10) = 1-F ;

	ENDIF ; 	IF N_ELEMENTS(WEIGHT_WINTER) NE 367 OR N_ELEMENTS(WEIGHT_SUMMER) NE 367 THEN BEGIN
;	********************************************************************************************



	IF N_ELEMENTS(A_CDOM_355) LT 1 OR  N_ELEMENTS(DATE) LT 1 THEN BEGIN
		ERROR ='ERROR: Must imput A_CDOM_355 and DATE'
		RETURN,''
	ENDIF

	IF N_ELEMENTS(DATE) EQ 1 THEN BEGIN
	;	===> Convert input dates to JD, AND JD to month
		DOY = REPLICATE(FIX(DATE_2DOY(DATE)),N_ELEMENTS(A_CDOM_355))
	ENDIF ELSE BEGIN
		DOY = FIX(DATE_2DOY(DATE))
	ENDELSE

;	===>
	IF N_ELEMENTS(DOY) NE N_ELEMENTS(A_CDOM_355) THEN BEGIN
		ERROR = 'Date must have same number of elements as A_CDOM_355'
		RETURN,''
	ENDIF

; ===> Initialize DOC array
	DOC = DOUBLE(A_CDOM_355)
	DOC(*) = MISSINGS(DOC) 

;	===> Find valid data
	OK = WHERE(DOY GE 1 AND DOY LT 367 AND A_CDOM_355 NE MISSINGS(A_CDOM_355) AND FINITE(A_CDOM_355) AND A_CDOM_355 GT 0.0,COUNT)
	IF COUNT EQ 0 THEN RETURN, DOC ; ALL WILL BE MISSING

;	===> Compute DOC according to Winter and Summer Functions
	DOC_WINTER = 1/ ( ALOG(DOUBLE(A_CDOM_355[OK]))*(-0.003380)  + 0.0085806  )
	DOC_SUMMER = 1/ ( ALOG(DOUBLE(A_CDOM_355[OK]))*(-0.0033928) + 0.0077601  )

;	===> Based on the Day of Year, the DOC concentration is the sum
;			 of the FALL-WINTER-SPRING FUNCTION*WEIGHT_WINTER + Summer FUNCTION*WEIGHT_SUMMER

	DOC[OK] =  (DOC_WINTER*WEIGHT_WINTER(DOY[OK]) + DOC_SUMMER*WEIGHT_SUMMER(DOY[OK]))*12 ; Convert uM to mg m^-3

;	===> Check for negative DOC values and set to missing if found
	OK = WHERE(DOC LE 0,COUNT)
	IF COUNT GE 1 THEN DOC[OK] = MISSINGS(DOC)

	RETURN, DOC

END; #####################  End of Routine ################################




; $ID:	DOC_MANNINO.PRO,	2020-07-08-15,	USER-KJWH	$

 FUNCTION DOC_MANNINO, RRS412=RRS412, RRS443=RRS443, RRS555=RRS555, RRS547=RRS547, RRS667=RRS667, RRS670=RRS670, DATE=DATE, ACDOM_ALG=ACDOM_ALG, LINEAR=LINEAR, SENSOR=SENSOR, INIT=INIT, GET_ALGS=GET_ALGS, ERROR=ERROR, ERR_MSG=ERR_MSG

;+
; NAME:
;		DOC_MANNINO
;
; PURPOSE:
;		This function estimates DOC concentrations using the Mannino algorithm for Chesapeake Bay, Delaware Bay, Hudson-Raritan Estuary and the Mid-Atlantic Bight 

; CATEGORY:
;		Algorithm
;
; CALLING SEQUENCE:
;
;		Result = DOC_MANNINO(RRS412=RRS412, RRS443=RRS443, RRS555=RRS555, RRS547=RRS547, RRS667=RRS667, RRS670=RRS670, DATE=DATE, ACDOM_ALG=ACDOM_ALG, SENSOR=SENSOR)
;
; INPUTS:
;		RRS data to calculate A_CDOM
;		A_CDOM..Absorption by CDOM at 355nm
;   DATE........Date (i.e. yyyymmdd or yyyymmddhh or yyyymmddhhmm format)
;
; KEYWORD PARAMETERS:
;		INIT.... Reinitializes variables in COMMON MEMORY
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
;		This algorithm uses two seasonal functions relating ACDOM at 355nm to Dissolved Organic Carbon (micromolar):
;		FALL-WINTER-SPRING FUNCTION: DOC=1/(ALOG(A_CDOM_355[OK])*(-0.0048650) + 0.0074394)
;		SUMMER FUNCTION:						 DOC=1/(ALOG(A_CDOM_355[OK])*(-0.002923)  + 0.0062469)
;
;   Fall/Winter/Spring DOC (May to October)
;   DOC = 1/(alog(A_CDOM355)*(-0.0048650) + 0.0074394)
;
;   Summer DOC (July to September)
;   DOC = 1/(alog(A_CDOM355)*(-0.0029492) + 0.0062629)
;
;		Based on the input DATE this routine switches between these two seasonal functions.
;		During the transition period between seasons the result is based on a weighting/blending of the
;		estimates from each of the two seasonal functions.
;		The blending of the two functions is accomplished by using BLEND.PRO which provides a weight factor ranging from
;		0 to 1 (or 1 to 0) which asymptotically approaches 0 and 1 to avoid kinks and inflections.
;
; EXAMPLE:
;		Run the Demo program:  DOC_MANNINO_DEMO.PRO
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)
;
; MODIFICATION HISTORY:
;		Algorithm by A. Mannino, NASA, GSFC Version: March 15, 2007
;		Program written by J.E. O'Reilly (Jay.O'Reilly@NOAA.GOV), May 12, 2007
;		Modified by: 
;		Feb  7, 2014 - KJWH: Added SMAB and NMAB algorithms
;		                     Now returns a structure with all available DOC prods
;		May 13, 2015 - KJWH: Updated with new algorithms from A. Mannino    
;		                     Changed inputs to be RRS data and now calculate A_CDOM within the program     
;		                     Added GET_ALGS keyword to just return the ALG names for the various DOC algorithms  
;	  Mar 15, 2017 - KJWH: Added steps to do LINEAR weighting instead of the COSINE weighting in BLEND    
;	                       Removed SENSOR keyword - instead looking for duplicate inputs RRS555 and RRS670      
;	  Jul 28, 2017 - KJWH: Removed the code to look for duplicate inputs of RRS555 and RRS670.  This check can be done in A_CDOM_MANNINO.                                           
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'DOC_MANNINO'
	ERROR = []
	ERR_MSG = []

  DOC_ALGS = ['CHS','DEL','HUD','MAB']
  IF KEY(GET_ALGS) THEN RETURN, DOC_ALGS

  IF NONE(DATE) THEN BEGIN
	  ERROR = 1
	  PRINT,'ERROR: Must input DATE to DOC_MANNINO'
	  RETURN,[]
	ENDIF
  
  IF NONE(ACDOM_ALG) THEN ACDOM_ALG = 'MLR_A412'
  ACDOM_380 = 'MLR_A380'
  
  IF NONE(RRS412) THEN RRS412 = [] ELSE RRS412 = DOUBLE(RRS412)
	IF NONE(RRS443) THEN RRS443 = [] ELSE RRS443 = DOUBLE(RRS443)
	IF NONE(RRS547) THEN RRS547 = [] ELSE RRS547 = DOUBLE(RRS547)
	IF NONE(RRS555) THEN RRS555 = [] ELSE RRS555 = DOUBLE(RRS555)
	IF NONE(RRS667) THEN RRS667 = [] ELSE RRS555 = DOUBLE(RRS667)
	IF NONE(RRS670) THEN RRS670 = [] ELSE RRS670 = DOUBLE(RRS670)
	
	; ===> initialize ACDOM_355 array to same size as Rrs490
	IF ANY(RRS412) THEN TEMP = DOUBLE(RRS412)
	IF NONE(TEMP) AND ANY(RRS443) THEN TEMP = DOUBLE(RRS443)
	IF NONE(TEMP) AND ANY(RRS547) THEN TEMP = DOUBLE(RRS547)
	IF NONE(TEMP) AND ANY(RRS555) THEN TEMP = DOUBLE(RRS555)
	IF NONE(TEMP) AND ANY(RRS667) THEN TEMP = DOUBLE(RRS667)
	IF NONE(TEMP) AND ANY(RRS670) THEN TEMP = DOUBLE(RRS670)
	TEMP(*) = MISSINGS(TEMP)
  STRUCT = CREATE_STRUCT('ACDOM_412',TEMP,'ACDOM_380',TEMP,'SS_275',TEMP,'DOC_CHS',TEMP, 'DOC_DEL',TEMP, 'DOC_HUD',TEMP, 'DOC_MAB',TEMP,'DOC_GOM',TEMP) 
      
;	***********************************************************
	COMMON _COMMON_DOC_MANNINO, WEIGHT_SS1, WEIGHT_SS2, WEIGHT_MAB1, WEIGHT_MAB2
; Make two 367 Day of Year Functions to apply to the two Seasonal DOC Equations
;	***********************************************************
  IF KEY(INIT) THEN _COMMON_DOC_MANNINO = []

;	===> Check if WEIGHT_WINTER or WEIGHT_SUMMER exist. If not, then make them and store in COMMON Memory
	IF NONE(_COMMON_DOC_MANNINO) THEN BEGIN

		WEIGHT_SS1  = FLTARR(367) ; Note 367 so that indices may start at doy 1 and end at 366 for leap years
		WEIGHT_SS2  = FLTARR(367) ; For the Bays and Estuaries
		WEIGHT_MAB1 = FLTARR(367) ; For MAB
		WEIGHT_MAB2 = FLTARR(367) ; Initialize all weights to 0, weights during transition periods will be overwritten

;		===> Transition Dates
    BES_SS = DATE_2DOY('20200601') ; Jun 01, 2020 - Bays & Estuaries Summer transition start
    BES_SE = DATE_2DOY('20200615') ; Jun 15, 2020 - Bays & Estuaries Summer transition end
    BES_WS = DATE_2DOY('20201001') ; Oct 01, 2020 - Bays & Estuaries Winter transition start
    BES_WE = DATE_2DOY('20201014') ; Oct 14, 2020 - Bays & Estuaries Winter transition end
		MAB_SS = DATE_2DOY('20200516') ; May 16, 2020 - MAB Summer transition start
		MAB_SE = DATE_2DOY('20200615') ; Jun 15, 2020 - MAB Summer transition end
		MAB_WS = DATE_2DOY('20201001') ; Oct 01, 2020 - MAB Winter transition start
		MAB_WE = DATE_2DOY('20201031') ; Oct 31, 2020 - MAB Winter transition end
		
;   ===> Initialize periods when weighting is full [1] for one of the two functions
		WEIGHT_SS1(DATE_2DOY('20200101'):DATE_2DOY('20200531')) = 1 ; Jan 01 to May 31 - Winter for the Bays and Estuaries
		WEIGHT_SS1(DATE_2DOY('20201015'):DATE_2DOY('20201231')) = 1 ; Oct 15 to Dec 31 - Winter for the Bays and Estuaries
		WEIGHT_SS2(DATE_2DOY('20200616'):DATE_2DOY('20200930')) = 1 ; Jun 16 to Sep 30 - Summer for the Bays and Estuaries

		WEIGHT_MAB1(DATE_2DOY('20200101'):DATE_2DOY('20200515')) = 1 ; Jan 01 to May 15 - Winter for the MAB
		WEIGHT_MAB1(DATE_2DOY('20201101'):DATE_2DOY('20201231')) = 1 ; Nov 01 to Dec 31 - Winter for the MAB
		WEIGHT_MAB2(DATE_2DOY('20200616'):DATE_2DOY('20200930')) = 1 ; Jun 16 to Sep 30 - Summer for the MAB

;   ===> DOY Arrays for the transition dates
		SDOYS = BES_SS + INDGEN(BES_SE-BES_SS+1)  & MSDOYS = MAB_SS + INDGEN(MAB_SE-MAB_SS+1) ; Summer estuaries & MAB
		WDOYS = BES_WS + INDGEN(BES_WE-BES_WS+1)  & MWDOYS = MAB_WS + INDGEN(MAB_WE-MAB_WS+1) ; Winter estuaries & MAB
    IF KEY(LINEAR) THEN BEGIN
      SS = 1.0D/(BES_SE-BES_SS) * SDOYS  -BES_SS/(BES_SE-BES_SS) ; Linear blend for summer estuaries
      SW = 1.0D/(BES_WE-BES_WS) * WDOYS  -BES_WS/(BES_WE-BES_WS) ; Linear blend for winter estuaries
      MS = 1.0D/(MAB_SE-MAB_SS) * MSDOYS -MAB_SS/(MAB_SE-MAB_SS) ; Linear blend for summer MAB
      MW = 1.0D/(MAB_WE-MAB_WS) * MWDOYS -MAB_WS/(MAB_WE-MAB_WS) ; Linear blend for winter MAB
    ENDIF ELSE BEGIN ; IF NOT LINEAR THEN USE A COSINE SHAPED WEIGHTING FOUND IN "BLEND"
  		SS = BLEND(SDOYS)          & MS = BLEND(MSDOYS)             ; Cosine blend for summer estuaries & MAB
	    SW = BLEND(WDOYS,/DOWN)    & MW = BLEND(MWDOYS,/DOWN)       ; Cosine blend for winter estuaries & MAB
    ENDELSE
;   ===> Add the increasing blending fraction for the SUMMER TRANSITION period (zero at beginning and 1 at the end of the period)
 	 	WEIGHT_SS1(BES_SS:BES_SE) = 1-SS & WEIGHT_MAB1(MAB_SS:MAB_SE) = 1-MS ; WINTER=1 & SUMMER = 0
	 	WEIGHT_SS2(BES_SS:BES_SE) = SS   & WEIGHT_MAB2(MAB_SS:MAB_SE) = MS   ; WINTER=0 & SUMMER = 1

;		===> Add the decreasing blending fraction for the WINTER TRANSITION period (1 at beginning and zero at the end of the period)		
	 	WEIGHT_SS1(BES_WS:BES_WE) = SW         & WEIGHT_MAB1(MAB_WS:MAB_WE) = MW
	  WEIGHT_SS2(BES_WS:BES_WE) = 1-SW       & WEIGHT_MAB2(MAB_WS:MAB_WE) = 1-MW

	ENDIF ; 	IF N_ELEMENTS(WEIGHT_WINTER) NE 367 OR N_ELEMENTS(WEIGHT_SUMMER) NE 367 THEN BEGIN
;	********************************************************************************************

  DOC = []

; Create the CDOM data
  ASTRUCT = A_CDOM_MANNINO(RRS_412=RRS412, RRS_443=RRS443, RRS_547=RRS547, RRS_555=RRS555, RRS_667=RRS667, RRS_670=RRS670, AT_412=DATA_A412, AT_443=DATA_A443, SATELLITE=SENSOR)
  APOS    = WHERE(TAG_NAMES(ASTRUCT) EQ ACDOM_ALG, COUNTA)
  BPOS    = WHERE(TAG_NAMES(ASTRUCT) EQ ACDOM_380, COUNTB)
  IF COUNTA EQ 0 OR COUNTB EQ 0 THEN BEGIN
    ERROR = 1
    ERR_MSG ='ERROR: Invalid ACDOM_ALG'
    RETURN,[]
  ENDIF
  CDOM412 = VALID_DATA(ASTRUCT.(APOS),PROD='A_CDOM')
  CDOM380 = VALID_DATA(ASTRUCT.(BPOS),PROD='A_CDOM')
  SS275   = VALID_DATA(ASTRUCT.MLR_S275,RANGE=[0.005,0.1])
	
	OK_ACDOM412 = WHERE(CDOM412 NE MISSINGS(CDOM412), COUNT_DATA, COMPLEMENT=OK_BAD, NCOMPLEMENT=NCOMPLEMENT) ;  ===> Find valid data
  IF COUNT_DATA EQ 0 THEN BEGIN
    ERROR = 1
    PRINT, 'No valid A_CDOM_412 data to calculate DOC'
    C412 = []
  ENDIF ELSE C412 = CDOM412(OK_ACDOM412)
  
  OK_ACDOM380 = WHERE(CDOM380 NE MISSINGS(CDOM380) AND SS275 NE MISSINGS(SS275), COUNT_DATA, COMPLEMENT=OK_BAD, NCOMPLEMENT=NCOMPLEMENT) ;  ===> Find valid data
  IF COUNT_DATA EQ 0 THEN BEGIN
    ERROR = 1
    PRINT, 'No valid A_CDOM_380 data to calculate DOC GOM'
    C380 = []
    S275 = []
  ENDIF ELSE BEGIN
    C380 = CDOM380(OK_ACDOM380)
    S275 = SS275(OK_ACDOM380)
  ENDELSE
  
  DOY = FIX(DATE_2DOY(DATE[0]))
  IF MIN(DOY) LT 0 OR MAX(DOY) GT 366 THEN BEGIN
    ERROR = 1
    ERROR = 'Date must be between 0 and 366'
    RETURN,[]
  ENDIF
	
;	===> A and B coefficients for the various regional summer and winter algorithms
;  A_CHS_WINTER = -0.004904 & B_CHS_WINTER = 0.002615 ; Chesapeake Bay (<= 38 degrees latitude)
;  A_CHS_SUMMER = -0.002623 & B_CHS_SUMMER = 0.003539
;  A_DEL_WINTER = -0.004914 & B_DEL_WINTER = 0.002795 ; Delaware Bay (> 38 and <= 39 degrees latitude)
;  A_DEL_SUMMER = -0.004061 & B_DEL_SUMMER = 0.004683  
;  A_HUD_WINTER = -0.003388 & B_HUD_WINTER = 0.005460 ; Hudson-Raritan Estuary (> 39 degrees latitude)
;  A_HUD_SUMMER = -0.005460 & B_HUD_SUMMER = 0.004804
;  A_MAB_WINTER = -0.004649 & B_MAB_WINTER = 0.003305 ; Mid-Atlantic Bight
;  A_MAB_SUMMER = -0.003305 & B_MAB_SUMMER = 0.003771
  
  ; ===> A and B coefficients for the various regional summer and winter algorithms - UPDATED 03 MARCH 2017 - Based on Sergio's 2017 code
  A_CHS_WINTER = -0.00490400 & B_CHS_WINTER = 0.0026148 ; Chesapeake Bay (<= 38 degrees latitude)
  A_CHS_SUMMER = -0.00262250 & B_CHS_SUMMER = 0.0035390
  A_DEL_WINTER = -0.00491380 & B_DEL_WINTER = 0.0027947 ; Delaware Bay (> 38 and <= 39 degrees latitude)
  A_DEL_SUMMER = -0.00406060 & B_DEL_SUMMER = 0.0046830
  A_HUD_WINTER = -0.00338840 & B_HUD_WINTER = 0.0054600 ; Hudson-Raritan Estuary (> 39 degrees latitude)
  A_HUD_SUMMER = -0.00338545 & B_HUD_SUMMER = 0.0048041
  A_MAB_WINTER = -0.00464930 & B_MAB_WINTER = 0.0033050 ; Mid-Atlantic Bight
  A_MAB_SUMMER = -0.00261270 & B_MAB_SUMMER = 0.0037710
  AGOM = 1.178 & BGOM = 103.6 & CGOM = 4.237 & DGOM = 326.8
  
  D_CHS_WINTER = 1./(A_CHS_WINTER * ALOG(C412) + B_CHS_WINTER)
  D_CHS_SUMMER = 1./(A_CHS_SUMMER * ALOG(C412) + B_CHS_SUMMER)
  
  D_DEL_WINTER = 1./(A_DEL_WINTER * ALOG(C412) + B_DEL_WINTER)
  D_DEL_SUMMER = 1./(A_DEL_SUMMER * ALOG(C412) + B_DEL_SUMMER)
  
  D_HUD_WINTER = 1./(A_HUD_WINTER * ALOG(C412) + B_HUD_WINTER)
  D_HUD_SUMMER = 1./(A_HUD_SUMMER * ALOG(C412) + B_HUD_SUMMER)
  
  D_MAB_WINTER = 1./(A_MAB_WINTER * ALOG(C412) + B_MAB_WINTER)
  D_MAB_SUMMER = 1./(A_MAB_SUMMER * ALOG(C412) + B_MAB_SUMMER)
  
  D_GOM = C380/(EXP(AGOM - BGOM * S275) + EXP(CGOM - DGOM * S275))
  
  STRUCT.ACDOM_412(OK_ACDOM412) = CDOM412(OK_ACDOM412)
  STRUCT.ACDOM_380(OK_ACDOM380) = CDOM380(OK_ACDOM380)
  STRUCT.SS_275(OK_ACDOM380)    = SS275(OK_ACDOM380)
  STRUCT.DOC_CHS(OK_ACDOM412)   = VALID_DATA((D_CHS_WINTER*WEIGHT_SS1(DOY)  + D_CHS_SUMMER*WEIGHT_SS2(DOY)) * 12.0, PROD='DOC')   ;  
  STRUCT.DOC_DEL(OK_ACDOM412)   = VALID_DATA((D_DEL_WINTER*WEIGHT_SS1(DOY)  + D_DEL_SUMMER*WEIGHT_SS2(DOY)) * 12.0, PROD='DOC')   ;
  STRUCT.DOC_HUD(OK_ACDOM412)   = VALID_DATA((D_HUD_WINTER*WEIGHT_SS1(DOY)  + D_HUD_SUMMER*WEIGHT_SS2(DOY)) * 12.0, PROD='DOC')   ;
  STRUCT.DOC_MAB(OK_ACDOM412)   = VALID_DATA((D_MAB_WINTER*WEIGHT_MAB1(DOY) + D_MAB_SUMMER*WEIGHT_MAB2(DOY))* 12.0, PROD='DOC')   ; Be sure to use the MAB weights
  STRUCT.DOC_GOM(OK_ACDOM380)   = VALID_DATA(D_GOM* 12.0, PROD='DOC')   
 
  RETURN, STRUCT 
  
  
END; #####################  End of Routine ################################




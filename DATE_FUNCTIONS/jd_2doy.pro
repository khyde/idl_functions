; $ID:	JD_2DOY.PRO,	2020-06-30-17,	USER-KJWH	$
;###############################################################################################      
FUNCTION JD_2DOY ,JD, NO_LEAP=NO_LEAP
;+
; NAME:
;       JD_2DOY
;
; PURPOSE:  CONVERT JULIAN DAY INTO DAY OF YEAR (1-366)
;
; CATEGORY:
;		DATE
;
; CALLING SEQUENCE:
;       RESULT = JD_2DOY(2451908.5)
; 
; EXAMPLES:
;      PRINT,JD_2DOY(DATE_2JD('20001231'))
;      PRINT,JD_2DOY(DATE_2JD('20001231'),/NO_LEAP)
;      PRINT,FIX(JD_2DOY(DATE_2JD(DATE_GEN(['19980101','19981231'],UNITS='DAY') )))
;    
; INPUTS:
; 	JD:  IDL JULIAN DAY
;
; KEYWORD PARAMETERS:
;		NO_LEAP..... IF THE YEAR IS A LEAP YEAR AND NO_LEAP KEYWORD IS SET THEN 
;		             THE MAXIMUM DOY WILL BE 365.9999 (NONE FOR 366.0 TO 366.999)
;
; OUTPUTS:
;		DOY  DAY OF YEAR 1-366 IN DECIMAL DAYS)
;
; MODIFICATION HISTORY:
;       WRITTEN BY:  J.E.O'REILLY, OCT 23, 2000
;       AUG 04,2015,JOR CHANGED NOLEAP TO NO_LEAP;ADDED EXAMPLES;FORMATTING
;###############################################################################################      
;-

;************************
ROUTINE_NAME = 'JD_2DOY'
;************************
;
;	===> MAKE OUTPUT ARRAY MISSING
	DOY = JD
	DOY[*] = MISSINGS(DOY)

;	===> FIND VALID INPUT JD
  OK=WHERE(FINITE(JD) AND JD NE MISSINGS(JD),COUNT)

  IF COUNT EQ 0 THEN RETURN, DOY

;===> COMPUTE YEAR FROM JD
  YEAR  = DOUBLE(STRING(JD[OK],FORMAT='(C(CYI4.4))'))

;===> CALCULATE FIRST OF YEAR
  FOY = JULDAY(1.0D,1.0D,YEAR,0.0D,0.0D,0.0D)

;	===> CALCULATE DAY OF YEAR (DOY)
  IF ~KEYWORD_SET(NO_LEAP) THEN DOY[OK] = JD[OK] - FOY + 1.0D $
                           ELSE DOY[OK] = (JD[OK]-FOY) + ((JD[OK] - FOY) LT 365) * 1.0D  ; if NO_LEAP is set then change DOY 366 to DOY 365 (but keep the decimal day precision in the doy)

  IF N_ELEMENTS(DOY) EQ 1 THEN RETURN, DOY[0] ELSE RETURN, DOY

  END; #####################  END OF ROUTINE ################################

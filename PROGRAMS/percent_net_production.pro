; $ID:	PERCENT_NET_PRODUCTION.PRO,	2020-06-26-15,	USER-KJWH	$

	FUNCTION PERCENT_NET_PRODUCTION, MONTH=month, SUBAREA=subarea

;+
; NAME:
;		PERCENT_NET_PRODUCTION
;
; PURPOSE:;
;		This function determines the amount of 'new production' based on MARMAP estimates of the monthly % net production.  
;
; CATEGORY:
;		PRODUCTION
;
; CALLING SEQUENCE:
;		Write the calling sequence here. Include only positional parameters
;		(i.e., NO KEYWORDS). For procedures, use the form:
;
;		ROUTINE_NAME, Parameter1, Parameter2, Foobar
;
;		Note that the routine name is ALL CAPS and arguments have Initial
;		Caps.  For functions, use the form:
;
;		Result = FUNCTION_NAME(Parameter1, Parameter2, Foobar)
;
; INPUTS:
;		Parm1:	Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;		Parm2:	Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;		KEY1:	Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
;
; OUTPUTS:
;		This function returns the
;
; OPTIONAL OUTPUTS:  ;
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
;     The net production values are only available for the Northeast U.S. Continental Shelf and the 4 subregions from the GFISH4 subarea mask 
;       Middle Atlantic Bight
;       Southern New England Shelf
;       Georges Bank
;       Gulf of Maine
;	PROCEDURE:
; EXAMPLE:
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Nov 21, 2007 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PERCENT_NET_PRODUCTION'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''

; ===> Determine if subarea was provided, if not the default is the NE Shelf
  IF NOT KEYWORD_SET(SUBAREA) THEN AREA   = 'NE_SHELF'    ELSE AREA   = STRUPCASE(SUBAREA)
  IF NOT KEYWORD_SET(MONTH)   THEN MONTHS = ''            ELSE MONTHS = STRUPCASE(MONTH) 

; ===>      !MONTH percent net production based on the MARMAP productivity data
  MNAME    = ['JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER']
  MSHORT   = ['JAN',  'FEB',  'MAR',  'APR',  'MAY',  'JUN',  'JUL',  'AUG',  'SEP',  'OCT',  'NOV',  'DEC' ]
  MNUM     = ['01',   '02',   '03',   '04',   '05',   '06',   '07',   '08',   '09',   '10',   '11',   '12'  ]
  NE_SHELF = [0.4670, 0.4701, 0.4960, 0.3543, 0.2644, 0.1334, 0.1779, 0.2013, 0.1513, 0.2433, 0.3361, 0.2892] 
  MAB      = [0.4183, 0.5184, 0.5356, 0.3810, 0.2340, 0.1369, 0.2767, 0.3592, 0.1858, 0.2724, 0.3208, 0.2384]
  SNE      = [0.4701, 0.3819, 0.4874, 0.3704, 0.1530, 0.1261, 0.1524, 0.1244, 0.1333, 0.2429, 0.3386, 0.3521]
  GB       = [0.6230, 0.4687, 0.5343, 0.4117, 0.3363, 0.2204, 0.1443, 0.2258, 0.1118, 0.2999, 0.3568, 0.2894]
  GOM      = [0.4568, 0.4746, 0.3809, 0.2212, 0.2258, 0.0558, 0.0524, 0.1173, 0.0458, 0.1750, 0.2604, 0.2696]
     
  CASE AREA OF
    'NE_SHELF': PER = NE_SHELF
    'MAB':      PER = MAB
    'SNE':      PER = SNE
    'GB':       PER = GB
    'GOM':      PER = GOM
  ENDCASE
  OK = WHERE(MNAME EQ MONTHS OR MSHORT EQ MONTHS OR MNUM EQ MONTHS,COUNT)
  IF COUNT EQ 1 THEN MPER = PER[OK] ELSE MPER = MISSINGS(0.0)      
  RETURN, MPER   
  
  




	END; #####################  End of Routine ################################

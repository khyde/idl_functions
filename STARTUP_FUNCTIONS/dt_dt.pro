; $ID:	DT_DT.PRO,	2023-09-21-13,	USER-KJWH	$
;+
 PRO DT_DT, CALENDAR=CALENDAR
; 
; NAME:
;   DT_DT
;
; PURPOSE:
;   This Program Prints Local and GMT DATE TIME based on current settings in the Computers SYSTIME
;
; CATEGORY:
;   DATE
;
; CALLING SEQUENCE:
;   DT_DT
;
; INPUTS:
;   NONE
;
; OPTIONAL INPUTS:
;   NONE
;
; KEYWORD PARAMETERS:
;   CALENDAR.... Runs DT_CALENDAR
;
; OUTPUTS:
;   Printout of the current date
;
; OPTIONAL OUTPUTS:
;   Output from DT_CALENDAR
;
; COMMON BLOCKS:
;   NONE
;
; SIDE EFFECTS:
;   NONE
;
; EXAMPLE:
;   DT_DT
;   DT_DT, /CALENDAR
;
; NOTES:
;   
;
; COPYRIGHT:
; Copyright (C) 2003, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on September 21, 2003 by John E. O'Reilly, NOAA/NMFS/NEFSC Narragansett, RI 02882
;   Inquires regarding this program should be directed to kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;   Jul 01, 2020 - KJWH: Aded COMPILE_OPT IDL2
;                        Updated documentation
;-
; ###########################################################################################################
  
  ROUTINE_NAME ='DT_DT'
  COMPILE_OPT IDL2
  
  JULIAN_LOCAL	=	SYSTIME(/JULIAN)
  JULIAN_GMT		=	SYSTIME(/JULIAN,/UTC)
  S=SIGN(0) 
  
  date_local = STRING(julian_local,FORMAT='(C(CMoA3))')+ ' ' +$
          		 STRING(julian_local,FORMAT='(C(CDi2.2))')+','+$
          		 STRING(julian_local,FORMAT='(C(CYi4.4))')+ ' '+$
          		 STRING(julian_local,FORMAT='(C(CHi2.2))')+':'+$
          		 STRING(julian_local,FORMAT='(C(CMi2.2))')+' '+$
          		 STRING(julian_local,FORMAT='(C(CSi2.2))')

  date_GMT   = STRING(julian_GMT,FORMAT='(C(CMoA3))')+ ' ' +$
          		 STRING(julian_GMT,FORMAT='(C(CDi2.2))')+','+$
          		 STRING(julian_GMT,FORMAT='(C(CYi4.4))')+ ' '+$
          		 STRING(julian_GMT,FORMAT='(C(CHi2.2))')+':'+$
          		 STRING(julian_GMT,FORMAT='(C(CMi2.2))')+' '+$
          		 STRING(julian_GMT,FORMAT='(C(CSi2.2))')

  PRINT, DATE_LOCAL,JD_2DATE(JULIAN_LOCAL),	'LOCAL', FORMAT='(A20,5X,A14,2X, A)'
  PRINT, DATE_GMT, 	JD_2DATE(JULIAN_GMT), 	'GMT'	 , FORMAT='(A20,5X,A14,2X, A)'
  DIF_HOURS = ROUND((JULIAN_GMT - JULIAN_LOCAL)*24.0)

  IF SIGN(DIF_HOURS) GE 0 THEN BEGIN
 		PRINT,'GMT = LOCAL +',DIF_HOURS,' Hours', FORMAT='(A, I2,A)'
	ENDIF ELSE BEGIN
		PRINT,'GMT = LOCAL -',DIF_HOURS,' Hours', FORMAT='(A, I2,A)'
	ENDELSE
	
	IF KEYWORD_SET(CALENDAR) THEN DT_CALENDAR

END; End of Program

; $Id:	VARSOL.pro,	2003 Oct 06 10:49	$
;+
;NAME:
;   VARSOL
;
;PURPOSE:
;
;
;CATEGORY:
;
;CALLING SEQUENCE:
;		ROUTINE_NAME, Parameter1, Parameter2, Foobar
;		Result = FUNCTION_NAME(Parameter1, Parameter2, Foobar)
;
;INPUTS:
;		Parm1:	Describe the positional input parameters here. Note again
;		that positional parameters are shown with Initial Caps.
;
;KEYWORDS:
;
;OUTPUTS:
;
;EXAMPLE:
;
;RESTRICTIONS:
;
;HISTORY:
;		FROM: CALC_PAR.F (SEADAS, MSL12)
; subroutine varsol (jday,month,dsol)
;Subroutine from 6S package to get Earth-Sun distance correction
;CC
;CC	calculation of the variability of the solar constant during the year.
;CC	jday is the number of the day in the month
;CC	dsol is a multiplicative factor to apply to the mean value of
;CC	solar constant
; real dsol,pi,om
;      integer jday,month,j
;
;      if (month.le.2) goto 1
;      if (month.gt.8) goto 2
;      j=31*(month-1)-((month-1)/2)-2+jday
;      goto 3
;    1 j=31*(month-1)+jday
;      goto 3
;    2 j=31*(month-1)-((month-2)/2)-2+jday
;
;    3 pi=2.*acos (0.)
;      om=(.9856*float(j-4))*pi/180.
;      dsol=1./((1.-.01673*cos(om))**2)
;      return
;      end

; 	Oct 6, 2003,	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION VARSOL,DOY
  ROUTINE_NAME='VARSOL'
      om=(.9856*float(DOY-4))*!DPI/180.
      dsol=1./((1.-.01673*cos(om))^2)
      RETURN, DSOL

END; #####################  End of Routine ################################

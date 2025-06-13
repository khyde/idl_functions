; $Id:	jd_2satdate.pro,	April 18 2011	$
FUNCTION JD_2SATDATE, DATE, SATNAME=SATNAME

;+
; NAME:
;   JD_2SATDATE
;
; PURPOSE:
;   This procedure will convert DATES (or JDs) to SATDATE
;
; CATEGORY:
;   CATEGORY
;
; CALLING SEQUENCE:
;
; INPUTS:
;   JD date
;
; OPTIONAL INPUTS:
;   SATNAME: Will append the first letter of the SATNAME to the date
;
; OUTPUTS:
;   This function returns the SATDATE for the input DATE and SATNAME
;
; SIDE EFFECTS:  If no SATNAME is given, will just return YYYYDOY
;
; PROCEDURE:
;
; EXAMPLE: SATDATE = JD_2SATDATE(DATE_2JD('20020105'),SATNAME='SEAWIFS')
;          RETURNS: 'S2002005;
;
; NOTES:
;
; MODIFICATION HISTORY:
;     Written April 18, 2011 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'JD_2SATDATE'


; ENSURE JD IS DOUBLE
  SZ=SIZE(JD,/STRUCT)
  
  SATNAME = STRMID(SATNAME,0,1)
  DP = DATE_PARSE(JD)    
  SATDATE = SATNAME+DP.YEAR+DP.IDOY

  RETURN,SATDATE

END

; $ID:	DATE_2SATDATE.PRO,	2020-04-14-12,	USER-KJWH	$
FUNCTION DATE_2SATDATE, DATE, SATNAME=SATNAME

;+
; NAME:
;   DATE_2SATDATE
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
;   DATE: Either DATE (YYYYMMDDHHMMSS, YYYYMMDD) or JD
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
; EXAMPLE: SATDATE = DATE_2SATDATE('20020105',SATNAME='SEAWIFS')
;          RETURNS: 'S2002005;
;
; NOTES:
;
; MODIFICATION HISTORY:
;     Written April 18, 2011 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;     Mar 10, 2020 - KJWH: Added IF NONE(SATNAME) THEN MPSATNAME = '' ELSE MPSATNAME = STRMID(SATNAME,0,1) to just return the YYYYDOY value without the satellite prefix
;     Apr 14, 2020 - KJWH: Added MPSATNAME = GET_SENSOR_LETTER(SATNAME) to use the predefinied prefix.  If none found, then use first letter of the provided satname
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DATE_2SATDATE'


; ENSURE JD IS DOUBLE
  SZ=SIZE(DATE,/STRUCT)
  
  IF NONE(SATNAME) THEN MPSATNAME = '' ELSE BEGIN
    MPSATNAME = GET_SENSOR_LETTER(SATNAME)
    IF MPSATNAME EQ '' THEN MPSATNAME = STRMID(SATNAME,0,1)
  ENDELSE
  DP = DATE_PARSE(DATE)    
  SATDATE = MPSATNAME+DP.YEAR+DP.IDOY

  RETURN,SATDATE

END

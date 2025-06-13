; $ID:	READ_SHIP_FILE.PRO,	2020-06-30-17,	USER-KJWH	$
;+
; NAME:
;   READ_SHIP_FILE.PRO
;
; PURPOSE:
;   Read a SHIP csv file and return the data in an array.  Sets the input arguments to the appropriate values.   
;
; CATEGORY:
;   Utilities
;
; CALLING SEQUENCE:
;
; INPUTS:
;   SHIP_FILE
;   PROD
;
; OPTIONAL INPUTS:
;   ERROR=ERROR
;
; KEYWORD PARAMETERS:
;   NONE
;   
; OUTPUTS:
;   RETURNS the array of SHIP data, and modifies the following parameters:
;   JULIAN_SHIP
;   DATE_SHIP
;   SHIP_STRING
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; PROCEDURE:
;     This is usually a description of the method, or any data manipulations
;
; EXAMPLE:
;   SHIP = OC_READ_SHIP_FILE('SHIP.csv', JULIAN_SHIP, DATE_SHIP, SHIP_STRING, 'CHLOR_A', ERROR=ERROR)
;   
; NOTES:
;   Variables JULIAN_SHIP, DATE_SHIP, SHIP_STRING are intended to be modified by this routine.
;
; MODIFICATION HISTORY:
;     Written April 28, 2011 by D.W. Moonan, 28 Tarzwell Drive, NMFS, NOAA 02882 (daniel.moonan@noaa.gov)
;     06/09/2011 : Added structure elements for JULIAN and DATA to avoid disconnect between arrays.
;                  Remove JULIAN_SHIP and DATE_SHIP arguments.
;-
; ****************************************************************************************************

FUNCTION READ_SHIP_FILE, SHIP_FILE, ERROR=ERROR, ERR_MSG=ERR_MSG

ROUTINE_NAME='READ_SHIP_FILE'
ERROR = ''
; ************************************************
; *** Read SHIP_FILE  *************************
; ************************************************
  

  IF FILE_TEST(SHIP_FILE) EQ 0  THEN BEGIN
    ERROR = 1
    ERR_MSG = SHIP_FILE + ' does not exist'
    PRINT, ERR_MSG
    RETURN, []
  ENDIF
    
  SHIP = READALL(SHIP_FILE,ERROR=ERROR,ERR_MSG=ERR_MSG)
  IF ERROR EQ 1 THEN RETURN, []  
      
  JULIAN_SHIP = JULDAY(SHIP.MONTH,SHIP.DAY,SHIP.YEAR,SHIP.HOUR,SHIP.MINUTE,SHIP.SECOND)
  DATE_SHIP   = JD_2DATE(JULIAN_SHIP)
  TMPINFO = CREATE_STRUCT('DATE', DATE_SHIP[0],'JULIAN', JULIAN_SHIP[0])
  TMPINFO = REPLICATE(TMPINFO,N_ELEMENTS(SHIP))
  TMPINFO.JULIAN = JULIAN_SHIP
  TMPINFO.DATE = DATE_SHIP
  SHIP = TEMPORARY(STRUCT_MERGE(TMPINFO,SHIP))
  
  RETURN, SHIP


END

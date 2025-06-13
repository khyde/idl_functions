; $ID:	H5_IS_CORRUPT.PRO,	2019-08-07-22,	USER-KJWH	$

  FUNCTION H5_IS_CORRUPT, FILE, VERBOSE=VERBOSE

;+
; NAME:
;   H5_HAS_GROUP
;
; PURPOSE:
;   This function will check to see if a HDF5 file is corrupt
;
; CATEGORY:
;   HDF5
;
; CALLING SEQUENCE:
;   R = H5_IS_CORRUPT(FILE, VERBOSE=VERBOSE)
;
; INPUTS:
;   FILE:    Input file
;   
; OPTIONAL INPUTS:
;   NONE
;
; KEYWORD PARAMETERS:
;   VERBOSE: To print out the results of the program
;
; OUTPUTS:
;   Returns 1 if the file is corrupt, 0 if it is not
;
; OPTIONAL OUTPUTS:
;   
;
; MODIFICATION HISTORY:
;			Written:  August 06, 2019 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified: 
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'H5_IS_CORRUPT'
	
  IF NONE(FILE) EQ 1 THEN BEGIN
    IF KEY(VERBOSE) THEN PRINT, 'ERROR: Must provide FILE name'
    RETURN, 'ERROR: Must provide FILE name'
  ENDIF
  
  IF FILE_TEST(FILE) EQ 0 THEN BEGIN
    IF KEY(VERBOSE) THEN PRINT, 'ERROR: FILE does not exist'
    RETURN, 'ERROR: ' + FILE + ' does not exist'
  ENDIF
	
	IF H5F_IS_HDF5(FILE) EQ 0 THEN BEGIN
    IF KEY(VERBOSE) THEN PRINT, 'ERROR: FILE is not a HDF5 file'
    RETURN, 'ERROR: ' + FILE + ' is not a HDF5 file.'
  ENDIF
	
	CATCH, ERR_STATUS
	
	IF ERR_STATUS NE 0 THEN BEGIN
	  IF KEY(VERBOSE) THEN PRINT, 'ERROR: Unable to read ' + FILE
	  RETURN, 1
	ENDIF
	
	H5_LIST, FILE, OUTPUT=OUTPUT
	RETURN, 0
	

END; #####################  End of Routine ################################

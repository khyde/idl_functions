; $ID:	H5_ADD_ATTRIBUTE.PRO,	2016-08-24,	USER-KJWH	$

  FUNCTION H5_HAS_ATTRIBUTE, FILEID, ATTRIBUTE, VERBOSE=VERBOSE

;+
; NAME:
;   H5_HAS_ATTRIBUTE
;
; PURPOSE:
;   This function will determine if an attribute exists in a HDF5 file that is already open
;
; CATEGORY:
;   HDF5
;
; CALLING SEQUENCE:
;   R = H5_HAS_ATTRIBUTE(FILEID, ATTRIBUTE, VERBOSE=VERBOSE)
;
; INPUTS:
;   FILEID:  Identifier number of the input file or group
;   ATTRIBUTE: The case specific name of the attribute to add
;
; OPTIONAL INPUTS:
;   NONE
;
; KEYWORD PARAMETERS:
;   VERBOSE: To print out the results of the attribute search
;
; OUTPUTS:
;   Returns 1 if the attribute exists, 0 if it does not
;
; OPTIONAL OUTPUTS:
;   
;
; MODIFICATION HISTORY:
;			Written:  August 24, 2016 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified: 
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'H5_HAS_ATTRIBUTE'
	
  IF NONE(FILEID) EQ 1 OR NONE(ATTRIBUTE) EQ 1 THEN BEGIN
   IF KEY(VERBOSE) THEN PRINT, 'ERROR: Must provide FILEID and ATTRIBUTE name'
   RETURN, 'ERROR: Must provide FILEID and ATTRIBUTE name'
  ENDIF
	
	ATAGS = []
	NATT = H5A_GET_NUM_ATTRS(FILEID)                      ; Look for ATTRIBUTES within the GROUP
	FOR ATH=0, NATT-1 DO BEGIN                            ; Loop through ATTRIBUTES
	  ATTID = H5A_OPEN_IDX(FILEID,ATH)                    ; Get the ATTRIBUTE id
	  ATAGS = [ATAGS,H5A_GET_NAME(ATTID)]                 ; Get the ATTRIBUTE name
	  H5A_CLOSE, ATTID
	ENDFOR
	 
  OK = WHERE(ATAGS EQ ATTRIBUTE,COUNT)
  IF COUNT EQ 1 THEN BEGIN
   IF KEY(VERBOSE) THEN PRINT, 'ATTRIBUTE, "' + ATTRIBUTE + '" found in FILEID'
   RETURN, 1
  ENDIF
  
  IF KEY(VERBOSE) THEN PRINT, 'ATTRIBUTE, "' + ATTRIBUTE + '" NOT found in FILEID'
  RETURN, 0

  

END; #####################  End of Routine ################################

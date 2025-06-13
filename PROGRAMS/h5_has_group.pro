; $ID:	H5_HAS_GROUP.PRO,	2020-07-08-15,	USER-KJWH	$

  FUNCTION H5_HAS_GROUP, FILE, GROUP, VERBOSE=VERBOSE

;+
; NAME:
;   H5_HAS_GROUP
;
; PURPOSE:
;   This function will determine if an GROUP exists in a HDF5 file that is already open
;
; CATEGORY:
;   HDF5
;
; CALLING SEQUENCE:
;   R = H5_HAS_GROUP(FILEID, GROUP, VERBOSE=VERBOSE)
;
; INPUTS:
;   FILE:    Input file
;   GROUP:   The case specific name of the group to look for
;
; OPTIONAL INPUTS:
;   NONE
;
; KEYWORD PARAMETERS:
;   VERBOSE: To print out the results of the group search
;
; OUTPUTS:
;   Returns 1 if the group exists, 0 if it does not
;
; OPTIONAL OUTPUTS:
;   
;
; MODIFICATION HISTORY:
;			Written:  August 26, 2016 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified: 
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'H5_HAS_GROUP'
	
  IF NONE(FILE) EQ 1 OR NONE(GROUP) EQ 1 THEN BEGIN
   IF KEY(VERBOSE) THEN PRINT, 'ERROR: Must provide FILE and GROUP name'
   RETURN, 'ERROR: Must provide FILE and GROUP name'
  ENDIF
	
	GRPS = []
	H5_LIST, FILE, FILTER='group', OUTPUT=OUTPUT
	SZ = SIZE(OUTPUT,/DIMENSIONS)
	FOR N=0, SZ[1]-1 DO BEGIN                   ; Loop through ATTRIBUTES
	  G = OUTPUT(1,N)
	  GRPS = [GRPS,STRMID(G,STRPOS(G,'/',/REVERSE_SEARCH)+1)]
	ENDFOR
	 
  OK = WHERE(GRPS EQ GROUP,COUNT)
  IF COUNT EQ 1 THEN BEGIN
   IF KEY(VERBOSE) THEN PRINT, 'GROUP, "' + GROUP + '" found in FILE - ' + FILE
   RETURN, 1
  ENDIF
  
  IF KEY(VERBOSE) THEN PRINT, 'GROUP, "' + GROUP + '" NOT found in FILE - ' + FILE
  RETURN, 0

  

END; #####################  End of Routine ################################

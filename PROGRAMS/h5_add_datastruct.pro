; $ID:	H5_ADD_DATASTRUCT.PRO,	2016-11-14,	USER-KJWH	$

  PRO H5_ADD_DATASTRUCT, FILE, STRUCTURE, TAGS=TAGS, VERBOSE=VERBOSE

;+
; NAME:
;   H5_ADD_DATASTRUCT
;
; PURPOSE:
;   This procedure will add a data structure (with attributes) to a HDF5 file that is already open
;
; CATEGORY:
;   HDF5
;
; CALLING SEQUENCE:
;    H5_ADD_DATASTRUCT, FILEID, STRUCTURE VERBOSE=VERBOSE
;
; INPUTS:
;   FILE:  Identifier number of the input file or group
;   STRUCTURE: A structure with data and attributes to add to a group
;
; OPTIONAL INPUTS:
;   TAGS: The case specific names for the HDF5 attribute/tag names
;
; KEYWORD PARAMETERS:
;   VERBOSE: To print out the changes made to the attribute
;
; OUTPUTS:
;   This program edits the attribute information of a HDF5 file that is already open
;
; OPTIONAL OUTPUTS:
;   
;
; MODIFICATION HISTORY:
;			Written:  November 15, 2016 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified: Nov 15, 2016 - KJWH:
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'H5_ADD_DATASTRUCTURE'
	
  IF NONE(FILEID) EQ 1 OR NONE(STRUCTURE) EQ 1 THEN BEGIN
   PRINT, 'ERROR: Must provide FILEID and structure information'
   GOTO, DONE
  ENDIF
	
	STAGS = TAG_NAMES(STRUCTURE)
	FOR S=0, N_ELEMENTS(STAGS)-1 DO BEGIN
	 
	ENDFOR
	
;	H5_PUTDATA, FILE, 
	
stop	; THIS PROGRAM IS INCOMPLETE
  IF KEY(VERBOSE) THEN PRINT, 'Adding ATTRIBUTE: "' + ATTRIBUTE + '", ' + INFO + '"'
  
  DATATYPE_ID = H5T_IDL_CREATE(INFO)
  DATASPACE_ID = H5S_CREATE_SIMPLE(1,MAX_DIMENSIONS=-1)
  ATTID = H5A_CREATE(FILEID,ATTRIBUTE,DATATYPE_ID,DATASPACE_ID)
  H5A_WRITE,ATTID,INFO
  H5A_CLOSE, ATTID
  H5T_CLOSE,DATATYPE_ID
  H5S_CLOSE,DATASPACE_ID
	
  DONE:

END; #####################  End of Routine ################################

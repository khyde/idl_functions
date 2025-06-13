; $ID:	H5_ADD_ATTRIBUTE.PRO,	2016-11-14,	USER-KJWH	$

  PRO H5_ADD_ATTRIBUTE, FILEID, ATTRIBUTE, INFO, VERBOSE=VERBOSE

;+
; NAME:
;   H5_ADD_ATTRIBUTE
;
; PURPOSE:
;   This procedure will add an attribute to a HDF5 file that is already open
;
; CATEGORY:
;   HDF5
;
; CALLING SEQUENCE:
;    H5_ADD_ATTRIBUTE, FILEID, ATTRIBUTE, NEWDATA, VERBOSE=VERBOSE
;
; INPUTS:
;   FILEID:  Identifier number of the input file or group
;   ATTRIBUTE: The case specific name of the attribute to add
;   INFO: The information to add to the attribute
;
; OPTIONAL INPUTS:
;   NONE
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
;			Written:  August 24, 2016 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified: Nov 14, 2016 - KJWH: Corrected documenation errors
;			                               Added H5T_CLOSE,DATATYPE_ID and H5S_CLOSE,DATASPACE_ID
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'H5_ADD_ATTRIBUTE'
	
  IF NONE(FILEID) EQ 1 OR NONE(ATTRIBUTE) EQ 1 OR NONE(INFO) EQ 1 THEN BEGIN
   PRINT, 'ERROR: Must provide FILEID, ATTRIBUTE name and NEWDATA information'
   GOTO, DONE
  ENDIF
	
	ATAGS = []
	NATT = H5A_GET_NUM_ATTRS(FILEID)                      ; Look for ATTRIBUTES within the GROUP
	FOR ATH=0, NATT-1 DO BEGIN                            ; Loop through ATTRIBUTES
	  ATTID = H5A_OPEN_IDX(FILEID,ATH)                    ; Get the ATTRIBUTE id
	  ATAGS = [ATAGS,H5A_GET_NAME(ATTID)]                 ; Get the ATTRIBUTE name
	  H5A_CLOSE, ATTID
	ENDFOR
	 
  OK = WHERE(ATAGS EQ ATTRIBUTE,COUNT)
  IF COUNT GE 1 THEN BEGIN
   PRINT, 'ERROR: ATTRIBUTE already exists in the FILEID'
   GOTO, DONE
  ENDIF
  
  IF KEY(VERBOSE) THEN PRINT, 'Adding ATTRIBUTE: "' + ATTRIBUTE + '", ' + INFO + '"'
  
  DATATYPE_ID = H5T_IDL_CREATE(INFO)
  
  IF (N_ELEMENTS(INFO) EQ 1) && ~SIZE(INFO, /N_DIMENSIONS) THEN BEGIN
    DATASPACE_ID = H5S_CREATE_SCALAR()
    ATTID = H5A_CREATE(FILEID,ATTRIBUTE,DATATYPE_ID,DATASPACE_ID)
    H5A_WRITE,ATTID,INFO
    H5A_CLOSE, ATTID
  ENDIF ELSE BEGIN
    DATASPACE_ID = H5S_CREATE_SIMPLE(SIZE(INFO, /DIMENSIONS) > 1)
    DID = H5D_CREATE(FILEID,ATTRIBUTE,DATATYPE_ID,DATASPACE_ID)
    H5D_WRITE,DID,INFO
    H5D_CLOSE, DID
  ENDELSE
  
;  DATASPACE_ID = H5S_CREATE_SIMPLE(1,MAX_DIMENSIONS=-1)
  

  H5T_CLOSE,DATATYPE_ID
  H5S_CLOSE,DATASPACE_ID
	
  DONE:

END; #####################  End of Routine ################################

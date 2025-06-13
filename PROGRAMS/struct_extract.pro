; $ID:	STRUCT_EXTRACT.PRO,	2020-06-30-17,	USER-KJWH	$
	FUNCTION STRUCT_EXTRACT, STRUCT, TAGNAME, ERROR=error
;+
; NAME:
;		STRUCT_EXTRACT
;
; PURPOSE:
;		This function Extracts and returns the first instance of a single requested tagname from a structure

;
; CATEGORY:
;		Structure
;
; CALLING SEQUENCE:
;
;
;		Result = STRUCT_EXTRACT(Structure, Tagname)
;
; INPUTS:
;		Structure.. The IDL structure to extract from
;		Tagname.... The tagname to extract
; OPTIONAL INPUTS:
;		NONE
;
; KEYWORD PARAMETERS:
;		NONE
;
; OUTPUTS:
;		The data in the tagname which was requested
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;

; RESTRICTIONS:  Returns the first found tagname in the structure provided
;
;	PROCEDURE:
;			Recursively searches the structure for the requested tagname
;
; EXAMPLE:
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

;		Citations or any other useful notes
;
;
; MODIFICATION HISTORY:
;			Written July 9, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'STRUCT_EXTRACT'
	ERROR = ''
;	===> Determine the IDL Data Type
  TYPE = IDLTYPE(STRUCT,/CODE)
  COUNT = 0L

;	===> Is STRUCT a Structure ?
  IF TYPE EQ 8 THEN BEGIN
  	FOR NTH = 0L,N_ELEMENTS(TAG_NAMES(STRUCT))-1L DO BEGIN
  		SZ=SIZE(STRUCT.(NTH),/STRUCT)
  	  OK=WHERE(TAG_NAMES(STRUCT) EQ TAGNAME,COUNT)
  	  	IF COUNT EQ 1 THEN RETURN, STRUCT.(OK)
  			IF SZ.TYPE EQ 8 THEN BEGIN
  				DATA= STRUCT_EXTRACT(STRUCT.(NTH),TAGNAME)
  			ENDIF
  	ENDFOR
  ENDIF
  IF N_ELEMENTS(DATA) EQ 0 THEN ERROR = 'Not found'
  RETURN, DATA

END; #####################  End of Routine ################################

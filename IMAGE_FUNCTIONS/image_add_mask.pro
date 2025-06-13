; $ID:	IMAGE_ADD_MASK.PRO,	2020-07-08-15,	USER-KJWH	$

	FUNCTION IMAGE_ADD_MASK, IMAGE,MASK, COLOR_MASK=color_mask, COLOR_IMAGE=color_image,CAPTION=caption,ERROR=error, _EXTRA=_extra

;+
; NAME:
;		IMAGE_ADD_MASK
;
; PURPOSE:
;		This function adds a Mask to an image

;
; CATEGORY:
;		IMAGE
;
; CALLING SEQUENCE:
;
;		IMAGE_ADD_MASK, Parameter1, Parameter2, Foobar
;
;		Result = IMAGE_ADD_MASK(Image, Mask)
;
; INPUTS:
;		Image:	A 2-d image array
;		Mask:   A 2-d mask array
;
; OPTIONAL INPUTS:
;		Color:	The colors to find in the mask and applyDescribe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;		COLOR_MASK:	The color(s) in the mask to find
;		COLOR_IMAGE: The color(s) to apply to the image
;
; OUTPUTS:
;		This function returns an image
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
;			Written April  1, 2007 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'IMAGE_ADD_MASK'

	SZ_IMAGE=SIZE(IMAGE,/STRUCT)
	SZ_MASK =SIZE(MASK,/STRUCT)
	IF SZ_IMAGE.N_DIMENSIONS NE 2 OR SZ_IMAGE.DIMENSIONS[0] NE SZ_MASK.DIMENSIONS[0] OR SZ_IMAGE.DIMENSIONS[1] NE SZ_MASK.DIMENSIONS[1] THEN BEGIN
		ERROR='Image and Mask must be same size'
		RETURN,''
	ENDIF
  If N_ELEMENTS(COLOR_MASK)  EQ 0 THEN _COLOR_MASK  = 1 ELSE _COLOR_MASK = COLOR_MASK
  If N_ELEMENTS(COLOR_IMAGE) EQ 0 THEN _COLOR_IMAGE = 1 ELSE _COLOR_IMAGE = COLOR_IMAGE

	IF N_ELEMENTS(_COLOR_IMAGE) NE N_ELEMENTS(_COLOR_MASK) THEN BEGIN
		ERROR='COLOR_IMAGE MUST BE SAME SIZE AS COLOR_MASK'
		RETURN,''
	ENDIF

  NEW = IMAGE

; ===> Set the graphics device to the 'Z' device
  ZWIN,NEW


;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR NTH=0L,N_ELEMENTS(_COLOR_MASK)-1L DO BEGIN
		ACOLOR=_COLOR_MASK[NTH]
		OK=WHERE(MASK EQ ACOLOR,COUNT)
  	IF COUNT GE 1 THEN NEW[OK]=_COLOR_IMAGE[NTH]
  ENDFOR

	ZWIN
  RETURN, NEW

END; #####################  End of Routine ################################

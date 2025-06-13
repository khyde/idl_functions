; $ID:	IMAGE_FILTER.PRO,	2020-06-30-17,	USER-KJWH	$

  PRO IMAGE_FILTER,  Files,  FILTER = filter,  WIDTH=width, SIGMA=sigma, LANDMASK_FILE=landmask_file, MISSING=missing, OVERWRITE=overwrite, ERROR = error
;
; NAME:
;		IMAGE_FILTER
;
; PURPOSE:
;		This procedure applies various filters to images
;
; CATEGORY:
;		MATH
;
; CALLING SEQUENCE:
;
; INPUTS:
;		Files:  The full path and file names of the IDL 'Standard SAVE Files'
;
; KEYWORD PARAMETERS:
;   FILTER....  Filter(s) to apply to each input image
;		WIDTH.....  Width of filter to apply
;		SIGMA.....  Sigma is passed only to the Gaussian Filter
;		OVERWRITE. 	Overwrite the output file if it already exists (overwrite = 1)

;
; OUTPUTS:
;    A png  file of the filtered image is written to the hard drive.
;
; OPTIONAL OUTPUTS:
;    ERROR: '' = NO ERROR ;  'SOME ERROR MESSAGE' = ERROR

; RESTRICTIONS:
;    Assumes that the input save files are the NOAA, Narragansett Standard Satellite Image Save files'
;
; EXAMPLE:
;
; NOTES:
;
; MODIFICATION HISTORY:
;		Written Jan 30, 2007 by J.O'Reilly (NOAA) & I. Belkin (URI)
;
; ****************************************************************************************************
  ROUTINE_NAME = 'IMAGE_FILTER'
  ERROR = ''

  N_FILES = N_ELEMENTS(FILES)

;	===> Must provide either files or an image
  IF N_FILES EQ 0 THEN BEGIN
     ERROR = 'Must provide files'
     RETURN
  ENDIF



	IF N_ELEMENTS(FILTER) EQ 0 THEN _FILTER = 'RAW' ELSE _FILTER 	= FILTER
	IF N_ELEMENTS(WIDTH)  EQ 0 THEN _WIDTH  = 5 		ELSE _WIDTH 	= WIDTH
	IF N_ELEMENTS(SIGMA)  EQ 0 THEN _SIGMA  = 1  		ELSE _SIGMA 	= SIGMA



; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR _file = 0L, N_FILES-1L DO BEGIN
  	AFILE = FILES(_file)
    FN = FILE_PARSE(AFILE)
    FI = FILE_ALL(AFILE)
    MAP = FI.MAP
    APROD = FI.PROD



		IF STRUPCASE(FN.EXT) EQ 'PNG' THEN DATA=READ_PNG(AFILE,R,G,B)
		IF STRUPCASE(FN.EXT) EQ 'GIF' THEN READ_GIF, AFILE,DATA,R,G,B
		IF STRUPCASE(FN.EXT) EQ 'SAVE' THEN BEGIN
;   	===> Read the file and get the geophysical data
    	data = STRUCT_SD_READ(AFILE,STRUCT=STRUCT,SUBS=SUBS)
;   	===> Determine the product PROD from the structure
    	APROD = STRUCT.(0)
		ENDIF

		IF N_ELEMENTS(MISSING) NE 1 THEN _MISSING = MISSINGS(DATA)


;		*********************
;		*** Get Landmask ****
;		*********************
 		IF N_ELEMENTS(landmask_file) EQ 1 THEN BEGIN
    	LANDMASK = READ_LANDMASK(LANDMASK_FILE,/LAND)
    ENDIF ELSE BEGIN
    	LANDMASK = BYTE(DATA) ; make a dummy landmask with nothing masked (all zeros)
    	LANDMASK(*) = 0b
    ENDELSE
		ok_land = WHERE(LANDMASK EQ 1,COUNT_LAND)



;		*************************************************************
;		*** IF one of the filters is 'RAW' then process only once ***
;		*************************************************************
		OK=WHERE(STRUPCASE(_FILTER) EQ 'RAW',COUNT)
		IF COUNT GE 1 THEN BEGIN
			Image = Data
			BIMAGE=SD_SCALES(IMAGE,PROD=APROD,/DATA2BIN)

;			===> Mask Land
			IF COUNT_LAND GE 1 THEN BIMAGE(ok_land) = 253

			LABEL_IMAGE = FN.FIRST_NAME+'!CRAW'
			LABEL_PNG   = FN.FIRST_NAME+'-RAW'

;			===> Add LABEL to the image
			ZWIN,BIMAGE & FONTS,'TIMES' &  TV,BIMAGE & XYOUTS,0.02,0.97,/NORMAL,LABEL_IMAGE,CHARSIZE=2.5,COLOR=0 & BIMAGE=TVRD() & ZWIN

			PNG_FILE= !DIR_BROWSE + LABEL_PNG + '.PNG'
			PAL_SW3,R,G,B
			WRITE_PNG,PNG_FILE, BIMAGE,R,G,B
		ENDIF




;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR filt = 0L,N_ELEMENTS(_FILTER)-1 DO BEGIN
			AFILTER = _FILTER(filt)

			IF AFILTER EQ 'RAW' THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>>> ALREADY DID RAW ABOVE SO SKIP



;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
			FOR wid = 0,N_ELEMENTS(_WIDTH)-1 DO BEGIN
				AWIDTH = _WIDTH(wid)
				TXT_WIDTH = STRTRIM(AWIDTH,2)

;				===> Change any infinity to nan (except median_fill)
				IF AFILTER EQ 'TRICUBE' 		THEN Image = FILTER_TRICUBE(INFINITY_2NAN(DATA), 	 WIDTH= AWIDTH,									ERROR=error)
				IF AFILTER EQ 'GAUSSIAN' 		THEN Image = FILTER_GAUSSIAN(INFINITY_2NAN(DATA), 	WIDTH= AWIDTH,	SIGMA= _SIGMA, 	ERROR=error)
				IF AFILTER EQ 'MEDIAN' 			THEN Image = MEDIAN(INFINITY_2NAN(DATA), AWIDTH)


; $$$$$$$$$$$$$$$$$$1
;	$$$ IGOR CREATE ANOTHER FUNCTION COPIED FROM FILTER_TRICUBE.PRO AND AT THE END RETURN THE MEDIAN FILTERED INPUT DATA
 				IF AFILTER EQ 'MEDIAN_IGOR' 		THEN Image = FILTER_MEDIAN_IGOR(INFINITY_2NAN(DATA), WIDTH= AWIDTH,	ERROR=error)

;				===> Do not change infinities to nan for MEDIAN_FILL, pass in data
				IF AFILTER EQ 'MEDIAN_FILL' THEN Image = MEDIAN_FILL(DATA,BOX=[3,AWIDTH],MISSING= _MISSING,MIN_FRACT=MIN_FRACT, MASK=LANDMASK,ERROR=ERROR)

				IF AFILTER EQ 'GAUSSIAN' 		THEN TXT_SIGMA =   'SIGMA_'+ REPLACE(ROUNDS(STRTRIM(SIGMA,2),1),'.','_') ELSE TXT_SIGMA = ''

;				===> Scale to byte range using the product type (aprod)
				BIMAGE=SD_SCALES(IMAGE,PROD=APROD,/DATA2BIN)

;				===> Mask Land
				IF COUNT_LAND GE 1 THEN BIMAGE(ok_land) = 253

				LABEL_IMAGE = FN.FIRST_NAME+'!C'+AFILTER+'!C'+'Width_'+TXT_WIDTH+'!C'+ TXT_SIGMA
				LABEL_PNG 	= FN.FIRST_NAME+'-'+AFILTER+'-'+'Width_'+TXT_WIDTH+'-'+TXT_SIGMA

;				===> Add LABEL to the image
				ZWIN,BIMAGE & FONTS,'TIMES' &  TV,BIMAGE & XYOUTS,0.02,0.97,/NORMAL,LABEL_IMAGE,CHARSIZE=2.5,COLOR=0 & BIMAGE=TVRD() & ZWIN

;				===> Make a name for the PNG_FILE
				PNG_FILE= !DIR_BROWSE + LABEL_PNG +'.PNG'
				PAL_SW3,R,G,B
				WRITE_PNG,PNG_FILE, BIMAGE,R,G,B
			ENDFOR ; FOR _width = 0,N_ELEMENTS(WIDTHS)-1 DO BEGIN
		ENDFOR ; 	FOR _filter = 0L,N_ELEMENTS(FILTERS)-1 DO BEGIN
	ENDFOR ; FOR _files = 0L, NFILES-1L DO BEGIN

;

  END; #####################  End of Routine ################################

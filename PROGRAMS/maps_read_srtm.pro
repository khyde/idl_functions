; $ID:	MAPS_READ_SRTM.PRO,	2020-06-30-17,	USER-KJWH	$
 ;############################################################################## 
  FUNCTION MAPS_READ_SRTM,FILE
; PURPOSE: THIS FUNCTION READS AN SRTM30 PLUS VERSION 9 FILE
;          AND RETURNS AN ARRAY OF THE TOPOGRAPHY [IN METERS]
;
; CATEGORY: MAPS
;
; CALLING SEQUENCE: RESULT = MAPS_READ_SRTM(MAPP)
;
; INPUTS:
;      FILE:  THE NAME OF THE SRTM30PLUS FILE

; OPTIONAL INPUTS:
;   NONE:
;
; KEYWORD PARAMETERS: NONE
;   
; OUTPUTS: A SIGNED INTEGER ARRAY WITH LAND > 0 AND WATER < 0
;

; MODIFICATION HISTORY:
; 
; WRITTEN BY J.O'REILLY, NOAA,NMFS,NARRAGANSETT,RI
; MAR 19,2012,JOR,REPLACED:  NEW = REPLACE(NAME,'S60','') WITH OK = WHERE_STRING(NAME,'S60',COUNT)
; APR 15,2014,JOR COPIED FROM TOPO_SRTM30_READ AND UPDATED AND UPDATED NOTES 
;                OK = WHERE_STRING(STRUPCASE(NAME),'S60',COUNT)



;===>NOTES:

; SRTM30_PLUS V9.0 - DECEMBER 19, 2013
; DAVID T. SANDWELL DSANDWELL@UCSD.EDU
; CHRIS OLSON <CJOLSON@UCSD.EDU>
; AMBER JACKSON <AMBERLEAJACKSON@GMAIL.COM>
; JOSEPH J. BECKER <JOSEPH.BECKER.CTR@NRLSSC.NAVY.MIL>
; 2) SRTM30 FORMAT
; THE DIRECTORY CALLED SRTM30 HAS THE SAME DATA IN
; ORIGINAL SRTM30 FORMAT CONSISTING OF 33 TILES
;  OF SIGNED 2-BYTE INTEGERS FOR GLOBAL ELEVATION(> 0) AND DEPTH (<0)
;  
; VERSION 9.0 HAS THE IDENTICAL FORMAT AS PREVIOUS VERSIONS. ENHANCEMENTS FROM V8.0
; 1) THE PREDICTED DEPTH IS BASED ON THE NEW V22 GRAVITY MODEL WHICH INCLUDES ALL NEW DATA FROM CRYOSAT-2, JASON-1, AND ENVISAT RESULTING IN ABOUT A FACTOR OF 2 IMPROVEMENT IN GRAVITY ACCURACY.  IN ADDITION BOTH THE GRAVITY AND THE PREDICTED DEPTH HAVE A FILTER WAVELENGTH THAT IS ABOUT 2 KM SHORTER THAN PREVIOUS VERSIONS (I.E., 14 KM WAVELENGTH INSTEAD OF 16 KM).
; 2) THERE HAS BEEN A LOT OF EDITING OF BAD SOUNDINGS 
; ESPECIALLY ON THE CONTINENTAL MARGINS WHERE THE DEEP HOLES WERE ELIMINATED.

; ;
; NOTE  THE FILES ARE 57600000 AND DATA ARE INTEGER (2BYTES) AND 
;  COVER A 40DEG BY 50N DEG SPAN,EXCEPT SOUTH OF 60 DEGREES WHERE THE FILES ARE
;  60 DEG BY 30.
;  FILES ABOVE 60 SOUTH  ARE 40 X 50 AND 57600000 BYTES:
;  PRINT, 57600000./(40*50*(120*120.)); = 2 (BYTE INTEGER)
;  
;  FILES BELOW 60 SOUTH ARE  60 X 30 AND 51840000 BYTES:
;  PRINT, 51840000./(60*30*(120*120.)); = 2 (BYTE INTEGER)

; SEE: !S.BATHY + 'SRTM30_TILES.PNG' FOR A GRAPHIC MAP OF THE TILES


;******************************
ROUTINE_NAME = 'MAPS_READ_SRTM'
;******************************
; ===> DEFINE X AND Y GRID SIZE FOR THE ARRAY
  XGRID= 40UL * 120
  YGRID= 50UL * 120

	FN=FILE_PARSE(FILE)
	NAME = STRTRIM(FN.FIRST_NAME,2)
	
; ===> REDEFINE X AND Y GRID SIZE FOR THE ARRAY IF CAN FIND 'S60' IN NAME
  OK = WHERE_STRING(STRUPCASE(NAME),'S60',COUNT)
	IF COUNT EQ 1 THEN BEGIN
		XGRID= 60UL * 120
  	YGRID= 30UL * 120
	ENDIF;IF COUNT EQ 1 THEN BEGIN

; ===> CREATE AND DIMENSION AN INTEGER ARRAY
  ITOPO =  INTARR (XGRID, YGRID)

; ====================>
; OPEN AND READ INTEGER ARRAY
  OPENR,LUN,FILE,/GET_LUN
  FS=FSTAT(LUN)
  IF FLOAT(FS.SIZE)/ (N_ELEMENTS(ITOPO)* SIZE_BYTES(ITOPO[0])) NE 1.0 THEN MESSAGE,'ERROR:FILE SIZE IS INCORRECT'
  READU,LUN,ITOPO
  CLOSE,LUN
  FREE_LUN,LUN

;	===> SWAP ENDIAN
	ITOPO = SWAP_ENDIAN(ITOPO)


; ===> ROTATE (FLIP) ARRAY SO BOTTOM = S AND TOP = N
  RETURN, ROTATE(ITOPO,7)

END; #####################  END OF ROUTINE ################################

; $ID:	PPY.PRO,	2020-06-30-17,	USER-KJWH	$

	PRO PPY, FILES, IN_PROD=in_prod, OUT_PROD=out_prod, PERIOD_CODE_IN=period_code_in, PERIOD_CODE_OUT=period_code_out, DATE_RANGE=date_range, ERROR = error

;+
; NAME:
;		PPY
;
; PURPOSE:
;		This function will integrate daily or monthly data to get summed annual production
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE:
;
; INPUTS:
;		FILES:						Input files
;		PERIOD_CODE_IN:		Period code of the input data
;		PERIOD_CODE_OUT:	Period code of the desired output data
;
; OPTIONAL INPUTS:
;		DATE_RANGE:				Can specify a DATE_RANGE to interpolate and save data
;
; KEYWORD PARAMETERS:
;		KEY1:
;
; OUTPUTS:
;		This function returns the summed annual production
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; EXAMPLE:
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)
;
;
; MODIFICATION HISTORY:
;			Written July 17, 2009 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'PPY'


; Create structure for the arrays

	FP = PARSE_IT(FILES,/ALL)
	PX = FP[0].PX & PY = FP[0].PY
	MAP = FP[0].MAP
	IF PX EQ '' OR PY EQ '' THEN BEGIN
		M = MAPS_SIZE(MAP)
		PX = M.PX
		PY = M.PY
	ENDIF
	IF PX EQ '' OR PY EQ '' THEN STOP
	STRUCT = FLTARR(N_ELEMENTS(FILES),PX,PY)
	FOR FTH = 0L, N_ELEMENTS(FILES)-1 DO BEGIN
		IM = STRUCT_SD_READ(FILES(FTH))
		STRUCT(FTH,*,*) = IM
	ENDFOR
	DATES = PERIOD_2JD(FP.PERIOD)
	MINJD = JD_2DATE(MIN(JDS))
	MAXJD = JD_2DATE(MAX(JDS))

	DATES = CREATE_DATE(MINDATE,MAXDATE)
	NDATES = N_ELEMENTS(DATES)
	NEWJDS = DATE_2JD(DATES)
	NEWARR = FLTARR(NDATES,PX,PY)
	FOR NTH=0L, N_ELEMENTS(DATES)-1 DO BEGIN
		OK = WHERE(JDS EQ NEWJDS[NTH],COUNT)
		IF COUNT EQ 1 THEN NEWARR(NTH,*,*) = STRUCT(OK,*,*) ELSE NEWARR(NTH,*,*) = MISSINGS(0.0)
	ENDFOR
	PER = N_ELEMENTS(FILES) * 0.2	; A pixel should have valid data at least 20% of the time (~ 73 dates per year)
	Y_MISSING = MISSINGS(0.0)
	FOR XTH = 0L, PX-1 DO BEGIN
		FOR YTH = 0L, PY-1 DO BEGIN
			ARR = NEWARR(*,XTH,YTH)
			DATA = VALID_DATA(ARR, PROD=IN_PROD,SUBS=SUBS)
			IF COUNT GE PER THEN BEGIN
				X = NEWJDS(SUBS)
				Y = ARR(SUBS)
				XX = NEWJDS
				YY = INTERP_XTEND(X,Y,XX,X_MISSING=X_MISSING,Y_MISSING=Y_MISSING,ERROR=ERROR)
				NEWARR(*,XTH,YTH) = YY.Y
			ENDIF
		ENDFOR
	ENDFOR


	JDS = NEWJDS
	NEWYEARS = STRMID(JD_2DATE(JDS),0,4)
	OK = WHERE(NEWYEARS GE MINYR AND NEWYEARS LE MAXYR,COUNT)
	IF COUNT GE 1 THEN BEGIN
		YRARR = FLTARR(PX,PY)
		YRARR(*,*) = MISSINGS(0.0)
		FOR XTH = 0L, PX-1 DO BEGIN
			FOR YTH = 0L, PY-1 DO BEGIN
				ARR = NEWARR(OK,XTH,YTH)
				AOK = WHERE(ARR NE MISSINGS(0.0),ACOUNT)
				IF ACOUNT GE 2 THEN BEGIN
					YRARR(XTH,YTH) = TOTAL(ARR(AOK))
				ENDIF
			ENDFOR
		ENDFOR
		OK_ALL = WHERE(YRARR NE MISSINGS(0.0),COUNT)
		IF COUNT GE 1 THEN YRARR[OK] = YRARR[OK]
	ENDIF


STOP





	END; #####################  End of Routine ################################

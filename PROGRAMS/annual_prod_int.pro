; $ID:	ANNUAL_PROD_INT.PRO,	2020-06-30-17,	USER-KJWH	$
;

 PRO ANNUAL_PROD_INT, IMAGES=IMAGES, MAP=MAP, OVERWRITE=OVERWRITE,$
 									YEARS=YEARS, ALLYEARS=ALLYEARS, SEASONS=SEASONS
;+
; NAME:
;       ANNUAL_PROD_INT.PRO
;
; PURPOSE:
;       Function to calculate the annual production for a given region by interpolating daily production values
;
; MODIFICATION HISTORY:
;       Written by:  K. Hyde January 10, 2006

	ROUTINE_NAME='AVE_SEAWIFS_INT.PRO'


; INPUTS:
;   	IMAGES:				List of images to read in and average
;
;
;
;	KEYWORDS


; OUTPUTS:
;

	PAL_SW3 ,R,G,B

	IF N_ELEMENTS(MAP)  LT 1 THEN _MAP  = 'MASS_BAY' ELSE _MAP = MAP
	IF N_ELEMENTS(OVERWRITE) EQ 0 THEN OVERWRITE = 0 ELSE OVERWRITE = OVERWRITE

	LAND_MASK = READ_LANDMASK(MAP = _MAP,/LAND)
	OK_LAND = WHERE(LAND_MASK GE 1 ,COUNT_LAND)
	INFO = MAPS_SIZE(_MAP)
	PX = uLONG(INFO.PX)
	PY = uLONG(INFO.PY)

	IF N_ELEMENTS(ALLYEARS) LT 1 THEN _ALL = YEARS ELSE _ALL = ALLYEARS
	MINYR = MIN(_ALL)
	MAXYR = MAX(_ALL)

	FILES = IMAGES
	NFILES = N_ELEMENTS(FILES)
	FP = PARSE_IT(FILES,/ALL)
	SENSOR='PP'
  SATELLITE='Z'
	DIR_ANNUAL = FP[0].DIR + 'ANNUAL\'
	DIR_BROWSE = DIR_ANNUAL + 'BROWSE\'
	IF FILE_TEST(DIR_ANNUAL,/DIRECTORY) NE 1 THEN FILE_MKDIR,DIR_ANNUAL
	IF FILE_TEST(DIR_BROWSE,/DIRECTORY) NE 1 THEN FILE_MKDIR,DIR_BROWSE
	STRUCT = FLTARR(NFILES,PX,PY)
	DATES = STRMID(JD_2DATE(PERIOD_2JD(FP.PERIOD)),0,8)
	JDS = DATE_2JD(DATES)
	DATES = JD_2DATE(JDS)
	MINDATE = JD_2DATE(MIN(JDS))
	MAXDATE = JD_2DATE(MAX(JDS))
	FOR FTH = 0L, NFILES -1 DO BEGIN
		IM = STRUCT_SD_READ(FILES(FTH))
		STRUCT(FTH,*,*) = IM
	ENDFOR

	IF FP[0].PERIOD_CODE EQ '!S' THEN BEGIN
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
				OK = WHERE(ARR NE MISSINGS(0.0) AND ARR GT 0.1,COUNT)
				IF COUNT GE PER THEN BEGIN
					X = NEWJDS[OK]
					Y = ARR[OK]
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

			SAVEFILE 		 = DIR_ANNUAL + STRTRIM(STRING(MINYR),2) + '_' + STRTRIM(STRING(MAXYR),2) + '-PPD.SAVE'										; Name of data file
			IF FILE_TEST(SAVEFILE) EQ 1 AND OVERWRITE EQ 0 THEN GOTO, SKIP_SAVE

	;   =====> Make Mask for Savefile
	    IF _MAP NE 'L3B9' THEN BEGIN

	;      	===> NOT_MASK (good data , 0b)
	      CODE_NAME = 'NOT_MASK'
	    	MASK=BYTE(YRARR) & MASK(*,*)=0B
	  	  CODE_MASK     =          [0B]
		    CODE_NAME_MASK=[CODE_NAME]

	;		    ===> LAND
	      CODE_NAME='LAND'
	      ACODE = MAX(CODE_MASK)+1B
	      CODE_MASK     =[CODE_MASK,ACODE]
	      CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
	      IF COUNT_LAND GE 1 THEN MASK(OK_LAND)  = ACODE

	;;      	===> OUTLIERS
	;        CODE_NAME='OUTLIERS'
	;        ACODE = MAX(CODE_MASK)+1B
	;        CODE_MASK     =[CODE_MASK,ACODE]
	;        CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
	;        IF COUNT_OUTLIERS GE 1 THEN MASK(OK_OUTLIERS)  = ACODE
	    ENDIF

	;	    ===> Encode PPD data to integer type and Write Structure
			DATA_UNITS=UNITS('')

	  ; IMAGE=FIX(YRARR) & IMAGE(*,*)= MISSINGS(IMAGE)
	  ; IMAGE(OK_ALL) = SD_SCALES(YRARR(OK_ALL),PROD='PPD',/DATA2INT,SCALING=SCALING,INTERCEPT=INTERCEPT,SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION)

	    STRUCT_SD_WRITE,SAVEFILE,PROD='ANN_PPD',  ASTAT='DATA',$
	                IMAGE=YRARR,      MISSING_CODE=MISSINGS(IMAGE), $
	                MASK=MASK,        CODE_MASK=CODE_MASK,    CODE_NAME_MASK=CODE_NAME_MASK, $
	                SCALING=SCALING,  INTERCEPT=INTERCEPT,  SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION,$
	                DATA_UNITS=DATA_UNITS,PERIOD=PERIOD_TXT, $
	                SENSOR=SENSOR,$
	                SATELLITE=SATELLITE,$
	                SAT_EXTRA='',$
	                METHOD=METHOD,$
	                INFILE=INFILES,$
	                NOTES=NOTES_RANGE,       ERROR=ERROR

		ENDIF
		SKIP_SAVE:

		FOR RTH=0L, N_ELEMENTS(YEARS)-1 DO BEGIN
			YEAR = YEARS(RTH)
			OK = WHERE(NEWYEARS EQ YEAR, COUNT)
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
	;			IF COUNT GE 1 THEN YRARR[OK] = YRARR[OK]

				YRMEAN = YRARR
				YRMEAN(OK_ALL) = YRARR(OK_ALL)/DATE_DAYS_YEAR(YEAR)

				SAVEFILE = DIR_ANNUAL + STRTRIM(STRING(YEAR),2) + '-PPD.SAVE'										; Name of data file
				SAVEMEAN = DIR_ANNUAL + '!Y-'+ STRTRIM(STRING(YEAR),2) + '-PPD-MEAN.SAVE'
				IF FILE_TEST(SAVEFILE) EQ 1 AND OVERWRITE EQ 0 THEN CONTINUE

	;     =====> Make Mask for Savefile
	      IF _MAP NE 'L3B9' THEN BEGIN

	;      	===> NOT_MASK (good data , 0b)
	        CODE_NAME = 'NOT_MASK'
	      	MASK=BYTE(YRARR) & MASK(*,*)=0B
	    	  CODE_MASK     =          [0B]
	  	    CODE_NAME_MASK=[CODE_NAME]

	;		    ===> LAND
	        CODE_NAME='LAND'
	        ACODE = MAX(CODE_MASK)+1B
	        CODE_MASK     =[CODE_MASK,ACODE]
	        CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
	        IF COUNT_LAND GE 1 THEN MASK(OK_LAND)  = ACODE

	;;      	===> OUTLIERS
	;        CODE_NAME='OUTLIERS'
	;        ACODE = MAX(CODE_MASK)+1B
	;        CODE_MASK     =[CODE_MASK,ACODE]
	;        CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
	;        IF COUNT_OUTLIERS GE 1 THEN MASK(OK_OUTLIERS)  = ACODE
	      ENDIF

	;	    ===> Encode PPD data to integer type and Write Structure
	 			DATA_UNITS=UNITS('')

	;      IMAGE=FIX(YRARR) & IMAGE(*,*)= MISSINGS(IMAGE)
	;      IMAGE(OK_ALL) = SD_SCALES(YRARR(OK_ALL),PROD='PPD',/DATA2INT,SCALING=SCALING,INTERCEPT=INTERCEPT,SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION)
	;      IM=FIX(YRMEAN) & IM(*,*)= MISSINGS(IM)
	;      IM(OK_ALL) = SD_SCALES(YRMEAN(OK_ALL),PROD='PPD',/DATA2INT,SCALING=SCALING,INTERCEPT=INTERCEPT,SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION)

	      STRUCT_SD_WRITE,SAVEFILE,PROD='ANN_PPD',  ASTAT='DATA',$
	                  IMAGE=YRARR,      MISSING_CODE=MISSINGS(IMAGE), $
	                  MASK=MASK,        CODE_MASK=CODE_MASK,    CODE_NAME_MASK=CODE_NAME_MASK, $
	                  SCALING=SCALING,  INTERCEPT=INTERCEPT,  SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION,$
	                  DATA_UNITS=DATA_UNITS,PERIOD=PERIOD_TXT, $
	                  SENSOR=SENSOR,$
	                  SATELLITE=SATELLITE,$
	                  SAT_EXTRA='',$
	                  METHOD=METHOD,$
	                  INFILE=INFILES,$
	                  NOTES=NOTES_RANGE,       ERROR=ERROR

				STRUCT_SD_WRITE,SAVEMEAN,PROD='ANN_PPD',  ASTAT='DATA',$
	                  IMAGE=YRMEAN,      MISSING_CODE=MISSINGS(IMAGE), $
	                  MASK=MASK,        CODE_MASK=CODE_MASK,    CODE_NAME_MASK=CODE_NAME_MASK, $
	                  SCALING=SCALING,  INTERCEPT=INTERCEPT,  SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION,$
	                  DATA_UNITS=DATA_UNITS,PERIOD=PERIOD_TXT, $
	                  SENSOR=SENSOR,$
	                  SATELLITE=SATELLITE,$
	                  SAT_EXTRA='',$
	                  METHOD=METHOD,$
	                  INFILE=INFILES,$
	                  NOTES=NOTES_RANGE,       ERROR=ERROR

			ENDIF
		ENDFOR

		FOR YYTH=0L, N_ELEMENTS(YEARS)-1 DO BEGIN
			YEAR = YEARS(YYTH)
			FOR STH=0L, N_ELEMENTS(SEASONS)-1 DO BEGIN
				SEA = SEASONS(STH)
				IF SEA EQ 'WSP' THEN BEGIN & MINSEA = STRING(YEAR)+'0101' & MAXSEA = STRING(YEAR)+'0531' & ENDIF
				IF SEA EQ 'WIN' THEN BEGIN & MINSEA = STRING(YEAR)+'0101' & MAXSEA = STRING(YEAR)+'0228' & ENDIF
				IF SEA EQ 'SPR' THEN BEGIN & MINSEA = STRING(YEAR)+'0301' & MAXSEA = STRING(YEAR)+'0531' & ENDIF
				IF SEA EQ 'SUM' THEN BEGIN & MINSEA = STRING(YEAR)+'0601' & MAXSEA = STRING(YEAR)+'0831' & ENDIF
				IF SEA EQ 'FAL' THEN BEGIN & MINSEA = STRING(YEAR)+'0901' & MAXSEA = STRING(YEAR)+'1231' & ENDIF
				OK = WHERE(STRING(STRMID(DATES,0,8)) GE STRTRIM(MINSEA,2) AND STRING(STRMID(DATES,0,8)) LE STRTRIM(MAXSEA,2),COUNT)

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

					OK = WHERE(YRARR NE MISSINGS(0.0),COUNT)
					IF COUNT GE 1 THEN YRARR[OK] = YRARR[OK]

					SAVEFILE = DIR_ANNUAL + STRTRIM(STRING(YEAR),2) + '_' + SEA + '-PPD.SAVE'										; Name of data file
					IF FILE_TEST(SAVEFILE) EQ 1 AND OVERWRITE EQ 0 THEN CONTINUE

	;	     	=====> Make Mask for Savefile
		      IF _MAP NE 'L3B9' THEN BEGIN

	;      		===> NOT_MASK (good data , 0b)
		        CODE_NAME = 'NOT_MASK'
		      	MASK=BYTE(YRARR) & MASK(*,*)=0B
		    	  CODE_MASK     =          [0B]
		  	    CODE_NAME_MASK=[CODE_NAME]

	;			    ===> LAND
		        CODE_NAME='LAND'
		        ACODE = MAX(CODE_MASK)+1B
		        CODE_MASK     =[CODE_MASK,ACODE]
		        CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
		        IF COUNT_LAND GE 1 THEN MASK(OK_LAND)  = ACODE

	; 	     	===> OUTLIERS
	;	        CODE_NAME='OUTLIERS'
	;	        ACODE = MAX(CODE_MASK)+1B
	;	        CODE_MASK     =[CODE_MASK,ACODE]
	;	        CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
	;	        IF COUNT_OUTLIERS GE 1 THEN MASK(OK_OUTLIERS)  = ACODE
		      ENDIF

		;	    ===> Encode PPD data to integer type and Write Structure
		 			DATA_UNITS=UNITS('')

	;	      IMAGE=FIX(YRARR) & IMAGE(*,*)= MISSINGS(IMAGE)
	;	      IMAGE(OK_ALL) = SD_SCALES(YRARR(OK_ALL),PROD='PPD',/DATA2INT,SCALING=SCALING,INTERCEPT=INTERCEPT,SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION)

		      STRUCT_SD_WRITE,SAVEFILE,PROD='ANN_PPD',  ASTAT='DATA',$
		                  IMAGE=YRARR,      MISSING_CODE=MISSINGS(IMAGE), $
		                  MASK=MASK,        CODE_MASK=CODE_MASK,    CODE_NAME_MASK=CODE_NAME_MASK, $
		                  SCALING=SCALING,  INTERCEPT=INTERCEPT,  SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION,$
		                  DATA_UNITS=DATA_UNITS,PERIOD=PERIOD_TXT, $
		                  SENSOR=SENSOR,$
		                  SATELLITE=SATELLITE,$
		                  SAT_EXTRA='',$
		                  METHOD=METHOD,$
		                  INFILE=INFILES,$
		                  NOTES=NOTES_RANGE,       ERROR=ERROR


				ENDIF
			ENDFOR
		ENDFOR
		GONE, NEWARR

	ENDIF ELSE BEGIN

		NEWYEARS = STRMID(JD_2DATE(JDS),0,4)
		OK = WHERE(NEWYEARS GE MINYR AND NEWYEARS LE MAXYR,COUNT)
		IF COUNT GE 1 THEN BEGIN
			YRARR = FLTARR(PX,PY)
			YRARR(*,*) = MISSINGS(0.0)
			FOR XTH = 0L, PX-1 DO BEGIN
				FOR YTH = 0L, PY-1 DO BEGIN
					ARR = STRUCT(OK,XTH,YTH)
					AOK = WHERE(ARR NE MISSINGS(0.0),ACOUNT)
					IF ACOUNT GE 2 THEN BEGIN
						YRARR(XTH,YTH) = TOTAL(ARR(AOK))
					ENDIF
				ENDFOR
			ENDFOR
			OK_ALL = WHERE(YRARR NE MISSINGS(0.0),COUNT)
			IF COUNT GE 1 THEN YRARR[OK] = YRARR[OK]

			SAVEFILE 		 = DIR_ANNUAL + STRTRIM(STRING(MINYR),2) + '_' + STRTRIM(STRING(MAXYR),2) + '-PPD.SAVE'										; Name of data file
			IF FILE_TEST(SAVEFILE) EQ 1 AND OVERWRITE EQ 0 THEN GOTO, SKIP_SAVE2

	;   =====> Make Mask for Savefile
	    IF _MAP NE 'L3B9' THEN BEGIN

	;      	===> NOT_MASK (good data , 0b)
	      CODE_NAME = 'NOT_MASK'
	    	MASK=BYTE(YRARR) & MASK(*,*)=0B
	  	  CODE_MASK     =          [0B]
		    CODE_NAME_MASK=[CODE_NAME]

	;		    ===> LAND
	      CODE_NAME='LAND'
	      ACODE = MAX(CODE_MASK)+1B
	      CODE_MASK     =[CODE_MASK,ACODE]
	      CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
	      IF COUNT_LAND GE 1 THEN MASK(OK_LAND)  = ACODE

	;;      	===> OUTLIERS
	;        CODE_NAME='OUTLIERS'
	;        ACODE = MAX(CODE_MASK)+1B
	;        CODE_MASK     =[CODE_MASK,ACODE]
	;        CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
	;        IF COUNT_OUTLIERS GE 1 THEN MASK(OK_OUTLIERS)  = ACODE
	    ENDIF

	;	    ===> Encode PPD data to integer type and Write Structure
			DATA_UNITS=UNITS('')

	  ; IMAGE=FIX(YRARR) & IMAGE(*,*)= MISSINGS(IMAGE)
	  ; IMAGE(OK_ALL) = SD_SCALES(YRARR(OK_ALL),PROD='PPD',/DATA2INT,SCALING=SCALING,INTERCEPT=INTERCEPT,SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION)

	    STRUCT_SD_WRITE,SAVEFILE,PROD='ANN_PPD',  ASTAT='DATA',$
	                IMAGE=YRARR,      MISSING_CODE=MISSINGS(IMAGE), $
	                MASK=MASK,        CODE_MASK=CODE_MASK,    CODE_NAME_MASK=CODE_NAME_MASK, $
	                SCALING=SCALING,  INTERCEPT=INTERCEPT,  SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION,$
	                DATA_UNITS=DATA_UNITS,PERIOD=PERIOD_TXT, $
	                SENSOR=SENSOR,$
	                SATELLITE=SATELLITE,$
	                SAT_EXTRA='',$
	                METHOD=METHOD,$
	                INFILE=INFILES,$
	                NOTES=NOTES_RANGE,       ERROR=ERROR

		ENDIF
		SKIP_SAVE2:

		FOR RTH=0L, N_ELEMENTS(YEARS)-1 DO BEGIN
			YEAR = YEARS(RTH)
			OK = WHERE(NEWYEARS EQ YEAR, COUNT)
			IF COUNT GE 1 THEN BEGIN
				YRARR = FLTARR(PX,PY)
				YRARR(*,*) = MISSINGS(0.0)
				FOR XTH = 0L, PX-1 DO BEGIN
					FOR YTH = 0L, PY-1 DO BEGIN
						ARR = STRUCT(OK,XTH,YTH)
						AOK = WHERE(ARR NE MISSINGS(0.0),ACOUNT)
						IF ACOUNT GE 2 THEN BEGIN
							YRARR(XTH,YTH) = TOTAL(ARR(AOK))
						ENDIF
					ENDFOR
				ENDFOR

				OK_ALL = WHERE(YRARR NE MISSINGS(0.0),COUNT)
	;			IF COUNT GE 1 THEN YRARR[OK] = YRARR[OK]

				YRMEAN = YRARR
				YRMEAN(OK_ALL) = YRARR(OK_ALL)/DATE_DAYS_YEAR(YEAR)

				SAVEFILE = DIR_ANNUAL + STRTRIM(STRING(YEAR),2) + '-PPD.SAVE'										; Name of data file
				SAVEMEAN = DIR_ANNUAL + '!Y-'+ STRTRIM(STRING(YEAR),2) + '-PPD-MEAN.SAVE'
				IF FILE_TEST(SAVEFILE) EQ 1 AND OVERWRITE EQ 0 THEN CONTINUE

	;     =====> Make Mask for Savefile
	      IF _MAP NE 'L3B9' THEN BEGIN

	;      	===> NOT_MASK (good data , 0b)
	        CODE_NAME = 'NOT_MASK'
	      	MASK=BYTE(YRARR) & MASK(*,*)=0B
	    	  CODE_MASK     =          [0B]
	  	    CODE_NAME_MASK=[CODE_NAME]

	;		    ===> LAND
	        CODE_NAME='LAND'
	        ACODE = MAX(CODE_MASK)+1B
	        CODE_MASK     =[CODE_MASK,ACODE]
	        CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
	        IF COUNT_LAND GE 1 THEN MASK(OK_LAND)  = ACODE

	;;      	===> OUTLIERS
	;        CODE_NAME='OUTLIERS'
	;        ACODE = MAX(CODE_MASK)+1B
	;        CODE_MASK     =[CODE_MASK,ACODE]
	;        CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
	;        IF COUNT_OUTLIERS GE 1 THEN MASK(OK_OUTLIERS)  = ACODE
	      ENDIF

	;	    ===> Encode PPD data to integer type and Write Structure
	 			DATA_UNITS=UNITS('')

	;      IMAGE=FIX(YRARR) & IMAGE(*,*)= MISSINGS(IMAGE)
	;      IMAGE(OK_ALL) = SD_SCALES(YRARR(OK_ALL),PROD='PPD',/DATA2INT,SCALING=SCALING,INTERCEPT=INTERCEPT,SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION)
	;      IM=FIX(YRMEAN) & IM(*,*)= MISSINGS(IM)
	;      IM(OK_ALL) = SD_SCALES(YRMEAN(OK_ALL),PROD='PPD',/DATA2INT,SCALING=SCALING,INTERCEPT=INTERCEPT,SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION)

	      STRUCT_SD_WRITE,SAVEFILE,PROD='ANN_PPD',  ASTAT='DATA',$
	                  IMAGE=YRARR,      MISSING_CODE=MISSINGS(IMAGE), $
	                  MASK=MASK,        CODE_MASK=CODE_MASK,    CODE_NAME_MASK=CODE_NAME_MASK, $
	                  SCALING=SCALING,  INTERCEPT=INTERCEPT,  SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION,$
	                  DATA_UNITS=DATA_UNITS,PERIOD=PERIOD_TXT, $
	                  SENSOR=SENSOR,$
	                  SATELLITE=SATELLITE,$
	                  SAT_EXTRA='',$
	                  METHOD=METHOD,$
	                  INFILE=INFILES,$
	                  NOTES=NOTES_RANGE,       ERROR=ERROR

				STRUCT_SD_WRITE,SAVEMEAN,PROD='ANN_PPD',  ASTAT='DATA',$
	                  IMAGE=YRMEAN,      MISSING_CODE=MISSINGS(IMAGE), $
	                  MASK=MASK,        CODE_MASK=CODE_MASK,    CODE_NAME_MASK=CODE_NAME_MASK, $
	                  SCALING=SCALING,  INTERCEPT=INTERCEPT,  SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION,$
	                  DATA_UNITS=DATA_UNITS,PERIOD=PERIOD_TXT, $
	                  SENSOR=SENSOR,$
	                  SATELLITE=SATELLITE,$
	                  SAT_EXTRA='',$
	                  METHOD=METHOD,$
	                  INFILE=INFILES,$
	                  NOTES=NOTES_RANGE,       ERROR=ERROR

			ENDIF
		ENDFOR

		FOR YYTH=0L, N_ELEMENTS(YEARS)-1 DO BEGIN
			YEAR = YEARS(YYTH)
			FOR STH=0L, N_ELEMENTS(SEASONS)-1 DO BEGIN
				SEA = SEASONS(STH)
				IF SEA EQ 'WSP' THEN BEGIN & MINSEA = STRING(YEAR)+'0101' & MAXSEA = STRING(YEAR)+'0531' & ENDIF
				IF SEA EQ 'WIN' THEN BEGIN & MINSEA = STRING(YEAR)+'0101' & MAXSEA = STRING(YEAR)+'0228' & ENDIF
				IF SEA EQ 'SPR' THEN BEGIN & MINSEA = STRING(YEAR)+'0301' & MAXSEA = STRING(YEAR)+'0531' & ENDIF
				IF SEA EQ 'SUM' THEN BEGIN & MINSEA = STRING(YEAR)+'0601' & MAXSEA = STRING(YEAR)+'0831' & ENDIF
				IF SEA EQ 'FAL' THEN BEGIN & MINSEA = STRING(YEAR)+'0901' & MAXSEA = STRING(YEAR)+'1231' & ENDIF
				OK = WHERE(STRING(STRMID(DATES,0,8)) GE STRTRIM(MINSEA,2) AND STRING(STRMID(DATES,0,8)) LE STRTRIM(MAXSEA,2),COUNT)

				IF COUNT GE 1 THEN BEGIN
					YRARR = FLTARR(PX,PY)
					YRARR(*,*) = MISSINGS(0.0)
					FOR XTH = 0L, PX-1 DO BEGIN
						FOR YTH = 0L, PY-1 DO BEGIN
							ARR = STRUCT(OK,XTH,YTH)
							AOK = WHERE(ARR NE MISSINGS(0.0),ACOUNT)
							IF ACOUNT GE 2 THEN BEGIN
								YRARR(XTH,YTH) = TOTAL(ARR(AOK))
							ENDIF
						ENDFOR
					ENDFOR

					OK = WHERE(YRARR NE MISSINGS(0.0),COUNT)
					IF COUNT GE 1 THEN YRARR[OK] = YRARR[OK]

					SAVEFILE = DIR_ANNUAL + STRTRIM(STRING(YEAR),2) + '_' + SEA + '-PPD.SAVE'										; Name of data file
					IF FILE_TEST(SAVEFILE) EQ 1 AND OVERWRITE EQ 0 THEN CONTINUE

	;	     	=====> Make Mask for Savefile
		      IF _MAP NE 'L3B9' THEN BEGIN

	;      		===> NOT_MASK (good data , 0b)
		        CODE_NAME = 'NOT_MASK'
		      	MASK=BYTE(YRARR) & MASK(*,*)=0B
		    	  CODE_MASK     =          [0B]
		  	    CODE_NAME_MASK=[CODE_NAME]

	;			    ===> LAND
		        CODE_NAME='LAND'
		        ACODE = MAX(CODE_MASK)+1B
		        CODE_MASK     =[CODE_MASK,ACODE]
		        CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
		        IF COUNT_LAND GE 1 THEN MASK(OK_LAND)  = ACODE

	; 	     	===> OUTLIERS
	;	        CODE_NAME='OUTLIERS'
	;	        ACODE = MAX(CODE_MASK)+1B
	;	        CODE_MASK     =[CODE_MASK,ACODE]
	;	        CODE_NAME_MASK=[CODE_NAME_MASK,CODE_NAME]
	;	        IF COUNT_OUTLIERS GE 1 THEN MASK(OK_OUTLIERS)  = ACODE
		      ENDIF

		;	    ===> Encode PPD data to integer type and Write Structure
		 			DATA_UNITS=UNITS('')

	;	      IMAGE=FIX(YRARR) & IMAGE(*,*)= MISSINGS(IMAGE)
	;	      IMAGE(OK_ALL) = SD_SCALES(YRARR(OK_ALL),PROD='PPD',/DATA2INT,SCALING=SCALING,INTERCEPT=INTERCEPT,SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION)

		      STRUCT_SD_WRITE,SAVEFILE,PROD='ANN_PPD',  ASTAT='DATA',$
		                  IMAGE=YRARR,      MISSING_CODE=MISSINGS(IMAGE), $
		                  MASK=MASK,        CODE_MASK=CODE_MASK,    CODE_NAME_MASK=CODE_NAME_MASK, $
		                  SCALING=SCALING,  INTERCEPT=INTERCEPT,  SLOPE=SLOPE,TRANSFORMATION=TRANSFORMATION,$
		                  DATA_UNITS=DATA_UNITS,PERIOD=PERIOD_TXT, $
		                  SENSOR=SENSOR,$
		                  SATELLITE=SATELLITE,$
		                  SAT_EXTRA='',$
		                  METHOD=METHOD,$
		                  INFILE=INFILES,$
		                  NOTES=NOTES_RANGE,       ERROR=ERROR


				ENDIF
			ENDFOR
		ENDFOR
		GONE, STRUCT
	ENDELSE
END		; END OF PROGRAM

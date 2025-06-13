; $ID:	PLOT_SPECTRA.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO PLOT_SPECTRA,WL,DATA,  $
  								WL2,DATA2, $
  								          RATIO=RATIO, R_BAND=r_band,LABEL=label,LAB_CHARSIZE=lab_charsize,$
 														MED=MED,spectra_median=spectra_median,spectra_std=spectra_std, $
                            ALL=all,EACH=each,$
                            LWN=lwn,QUIET=quiet,$
                            PAUSE=pause,$
                            SORT_DATA=sort_data,$
                            COLOR=COLOR,$
                            GRID=grid,$
                            PAL=pal,$
                            arr_color=arr_color,$
                            arr2_color=arr2_color,$
                            _EXTRA=_extra
;+
; NAME:
;       PLOT_SPECTRA
;
; PURPOSE:
;       Plot Rrs or Lw Spectra
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;    plot_spectra,[412,443,490,510,555],[[10,8,5,3,2],[10.5,8.5,5.5,3.5,2.5]]
;    plot_spectra,[412,443,490,510,555],[[10,8,5,3,2],[10.5,8.5,5.5,3.5,2.5]],/MED

;   plot_spectra,[412,443,490,510,555],[[10,8,5,3,2],[10.5,8.5,5.5,3.5,2.5]],/RATIO
;   plot_spectra,[412,443,490,510,555],[[10,8,5,3,2],[10.5,8.5,5.5,3.5,2.5]],/RATIO,/MED
;
; INPUTS:
;       WL:  Wavelengths (nm)
;       DATA: ARRAY with columns matching number of elements in WL
;
; KEYWORD PARAMETERS:
;       RATIO:  The nth wavelength to divide all
;
; OUTPUTS:
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Sept 23,1999
;-

; ====================>
; Must provide LW, AND DATA
  IF N_PARAMS() LT 2 THEN STOP
  IF N_ELEMENTS(PAUSE) NE 1 THEN PAUSE = 0.0

  N_WL = N_ELEMENTS(WL)
  N_WL2 = N_ELEMENTS(WL2)

  IF N_ELEMENTS(PAL) EQ 0 THEN PAL = 'PAL_SW3'
  CALL_PROCEDURE,PAL,R,G,B

; ===================>
; Number of rows in DATA must equal number of elements in WL
  ARRAY=DATA
  IF N_ELEMENTS(DATA2) GE 2 THEN BEGIN
  	ARRAY2=DATA2
  ENDIF ELSE BEGIN
  	ARRAY2=ARRAY
  	WL2=WL
  ENDELSE

  S=SIZE(ARRAY,/STRUCT)
  IF S.N_DIMENSIONS EQ 2 THEN BEGIN
    N_BANDS = S.DIMENSIONS[0]
    N_ROWS  = S.DIMENSIONS[1]
  ENDIF
  IF S.N_DIMENSIONS EQ 1 THEN BEGIN
    N_BANDS = S.DIMENSIONS[0]
    N_ROWS  = 1
  ENDIF

  S=SIZE(ARRAY2,/STRUCT)
  IF S.N_DIMENSIONS EQ 2 THEN BEGIN
    N_BANDS2 = S.DIMENSIONS[0]
    N_ROWS2  = S.DIMENSIONS[1]
  ENDIF
  IF S.N_DIMENSIONS EQ 1 THEN BEGIN
    N_BANDS2 = S.DIMENSIONS[0]
    N_ROWS2  = 1
  ENDIF

  IF N_BANDS NE N_WL THEN STOP
  IF N_BANDS2 NE N_WL2 THEN STOP

; =============> Merge array array2
	N_BANDS3 = N_BANDS+N_BANDS2
	N_ROWS3 = N_ROWS
	N_WL3= N_WL +N_WL2
	WL3 = [WL,WL2]
	sort_3= SORT(WL3)
  array3 = REPLICATE(array[0],N_BANDS3,N_ROWS3)
  array3(*,*)=MISSINGS(array3)
  array3(0:N_BANDS-1,*) = array
  array3(N_BANDS:N_BANDS3-1,*) = array2

  IF N_ELEMENTS(ORIENTATION) NE 1 THEN ORIENTATION = -45
  IF N_ELEMENTS(COLOR) EQ 0 THEN COLOR=0

	IF N_ELEMENTS(arr_color) EQ 1 THEN _arr_color = arr_color else _arr_color = 0
	IF N_ELEMENTS(arr2_color) EQ 1 THEN _arr2_color = arr2_color else _arr2_color = 0
  color2=0

  IF N_ELEMENTS(BACKGROUND) EQ 0 THEN BACKGROUND =  254

  IF N_ELEMENTS(LAB_CHARSIZE) EQ 0 THEN LAB_CHARSIZE = 1.7

; ====================>
  IF N_ELEMENTS(SORT_DATA) EQ N_ROWS THEN BEGIN
    S=SORT(SORT_DATA)
    SORT_DATA = SORT_DATA(S)
    FOR BANDS = 0,N_BANDS-1 DO BEGIN
      ARRAY(BANDS,*) = ARRAY(BANDS,S)
    ENDFOR
    FOR BANDS = 0,N_ELEMENTS(WL2)-1 DO BEGIN
      ARRAY2(BANDS,*) = ARRAY2(BANDS,S)
    ENDFOR
		FOR BANDS = 0,N_ELEMENTS(WL3)-1 DO BEGIN
      ARRAY3(BANDS,*) = ARRAY3(BANDS,S)
    ENDFOR
    SORTED = 1
  ENDIF ELSE BEGIN
    SORTED = 0
  ENDELSE


  IF KEYWORD_SET(RATIO) OR N_ELEMENTS(R_BAND) EQ 1 THEN BEGIN
    IF N_ELEMENTS(r_band) NE 1 THEN BEGIN
       _r_band = LAST(INDGEN(N_ELEMENTS(WL)))
    ENDIF ELSE BEGIN
      ok = WHERE(STRTRIM(NUM2STR(WL),2) EQ STRTRIM(NUM2STR(R_BAND),2),COUNT)
      IF COUNT EQ 1 THEN _r_band=ok[0] ELSE  _r_band = LAST(INDGEN(N_ELEMENTS(WL)))
    ENDELSE


		FOR nth = 0,N_ROWS-1L DO BEGIN
		  bottom = array(_r_band,NTH)
      ARRAY(*,NTH) = ARRAY(*,NTH)/bottom
      ARRAY2(*,NTH) = ARRAY2(*,NTH)/bottom
      ARRAY3(*,NTH) = ARRAY3(*,NTH)/bottom
    ENDFOR


    YTITLE = 'Band Ratio (to '+NUM2STR(WL(_r_band))+')'
    IF KEYWORD_SET(LWN) THEN YTITLE = 'nLw '+ ytitle ELSE YTITLE = 'Rrs '+ ytitle
  ENDIF ELSE BEGIN
    IF KEYWORD_SET(LWN) THEN YTITLE = 'Lwn' ELSE  YTITLE = 'Rrs'
  ENDELSE


  IF N_ELEMENTS(WL3) GE 1 THEN BEGIN
     _WL_ = WL3
     S=SORT(_WL_)
     _WL_= _WL_(S)
     U=UNIQ(_WL_)
     _WL_ = _WL_(U)
     & NN=N_ELEMENTS(_WL_)
  ENDIF


   XTICKS = N_ELEMENTS(_WL_)-1
   XTICKV = _WL_
   XTICKNAME = NUM2STR(_WL_)

    OK = WHERE(FINITE(ARRAY))

    _MAX = MAX(ARRAY[OK])
    _MIN = MIN(ARRAY[OK])

    _XTICKNAME=REPLICATE(' ',N_ELEMENTS(XTICKNAME))
    IF NOT KEYWORD_SET(QUIET) THEN BEGIN
      PLOT,  _WL_, [REPLICATE(_MIN,NN/2), REPLICATE(_MAX,NN/2)],$
            XTITLE='Wavelength (nm)', Ytitle = ytitle, $
            /NODATA,XTICKS=XTICKS,XTICKV=XTICKV,XTICKNAME=_XTICKNAME, $
            XTICK_GET=XTICK_GET,YTICK_GET=YTICK_GET,BACKGROUND=BACKGROUND,_EXTRA=_extra
            IF KEYWORD_SET(GRID) THEN GRIDS,WL,COLOR=253
 						YPOS = !Y.CRANGE[0] -0.02* (TOTAL(ABS(!Y.CRANGE)))
 						IF !Y.TYPE EQ 1 THEN YPOS = 10^YPOS
            XYOUTS,XTICK_GET,YPOS,XTICKNAME,$
                   ORIENTATION= ORIENTATION
     ENDIF


    IF NOT KEYWORD_SET(QUIET) AND KEYWORD_SET(ALL) THEN BEGIN
      FOR nth = 0, N_ROWS-1L DO BEGIN
        SPECTRUM3 = ARRAY3(*,NTH)
        OPLOT, WL3(sort_3),SPECTRUM3(sort_3),color=color
        SPECTRUM  = ARRAY(*,NTH)
       	OPLOT, WL,SPECTRUM, COLOR=_arr_color,thick=2,PSYM=1,SYMSIZE=0.5
        SPECTRUM2 = ARRAY2(*,NTH)
       	OPLOT, WL2,SPECTRUM2, COLOR=_arr2_color,thick=2,PSYM=1,SYMSIZE=0.5
      ENDFOR

    ENDIF

   IF NOT KEYWORD_SET(QUIET) AND KEYWORD_SET(EACH) THEN BEGIN
      FOR nth = 0,N_ROWS-1L DO BEGIN
        SPECTRUM = ARRAY(*,NTH)
        OPLOT, WL,SPECTRUM, COLOR=COLOR,thick=2
        OPLOT, WL,SPECTRUM, COLOR=COLOR,thick=2,PSYM=1
        SPECTRUM2 = ARRAY2(*,NTH)
        OPLOT, WL2,SPECTRUM2, COLOR=COLOR2,thick=2,PSYM=1
        XYOUTS,MAX(WL),0.92*_MAX,LABEL,/DATA,ALIGN=1.04,CHARSIZE=LAB_CHARSIZE,COLOR=COLOR
        IF SORTED EQ 1 THEN  XYOUTS,0.1,0.9,NUM2STR(SORT_DATA(nth)),/normal
        WAIT,PAUSE

        OPLOT, WL,SPECTRUM, COLOR=!P.BACKGROUND,thick=2
        OPLOT, WL,SPECTRUM, COLOR=!P.BACKGROUND,thick=2,PSYM=1
        OPLOT, WL2,SPECTRUM2, COLOR=!P.BACKGROUND,thick=2,PSYM=1
        XYOUTS,MAX(WL),0.92*_MAX,LABEL,/DATA,ALIGN=1.04,CHARSIZE=LAB_CHARSIZE,COLOR=!P.BACKGROUND
        IF SORTED EQ 1 THEN  XYOUTS,0.1,0.9,NUM2STR(SORT_DATA(nth)),/normal,COLOR=!P.BACKGROUND
      ENDFOR
    ENDIF

    IF KEYWORD_SET(MED) THEN BEGIN

      SPECTRUM = REPLICATE(0.0, N_ELEMENTS(WL))
      spectrum_std =  REPLICATE(0.0, N_ELEMENTS(WL))
      FOR N=0,N_ELEMENTS(WL)-1L DO BEGIN
       IF KEYWORD_SET(RATIO) THEN  _DATA = REFORM(ARRAY(N,*))/ARRAY(RATIO,*) ELSE _DATA = REFORM(ARRAY(N,*))
       S=STATS(_DATA,/EVEN,/QUIET)
       SPECTRUM(N) = S.MED
       spectrum_std(N) = S.STD
      ENDFOR


      IF N_ELEMENTS(_EXTRA) GE 1 THEN BEGIN
        TAGS = TAG_NAMES(_EXTRA)
        OK = WHERE(TAGS EQ 'COLOR',COUNT)
        IF COUNT EQ 1 THEN COLOR = _EXTRA.COLOR ELSE COLOR = 22
      ENDIF ELSE BEGIN
        COLOR = 22
      ENDELSE


      IF N_ELEMENTS(_EXTRA) GE 1 THEN BEGIN
        TAGS = TAG_NAMES(_EXTRA)
        OK = WHERE(TAGS EQ 'THICK',COUNT)
        IF COUNT EQ 1 THEN THICK = _EXTRA.THICK ELSE THICK = 3
      ENDIF ELSE BEGIN
        THICK = 3
      ENDELSE

      IF NOT KEYWORD_SET(QUIET) THEN OPLOT, WL, SPECTRUM,COLOR=COLOR,THICK=THICK,LINESTYLE=0
      spectra_median = SPECTRUM
      spectra_std    = spectrum_std
   ENDIF

    IF N_ELEMENTS(LABEL) EQ 1 THEN $
       XYOUTS,MAX(WL),0.92*_MAX,LABEL,/DATA,ALIGN=1.04,CHARSIZE=LAB_CHARSIZE

  END

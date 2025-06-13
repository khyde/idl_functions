; $ID:	CLEAR_WATER.PRO,	2020-06-30-17,	USER-KJWH	$
;+

  FUNCTION CLEAR_WATER, LAMBDA, RES=res,QUIET=quiet, CSV=csv

; NAME:
;       CLEAR_WATER
;
; PURPOSE:
;       Compute, interpolate Clear Water Absorption and Kw values for pure seawater
;       according to several references.
;
; CATEGORY:
;       Light
;
; CALLING SEQUENCE:
;       Result = CLEAR_WATER()
;       Result = CLEAR_WATER([412])
;       Result = CLEAR_WATER([412,443,490,510,555],method='sb81')
;
; INPUTS:
;       None Required
;
; KEYWORD PARAMETERS:
;       METHOD:  May be "SB81" (Smith and Baker, 1981)
;                    or "P93'  (Pope 1993)
;                    or "PF97" (Pope and Fry, 1997)
;                    ;
;       LAMBDA:  Wavelength or array of wavelengths (nm)
;
; OUTPUTS:
;
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       Input wavelengths must range beteen 400 and 700nm.
;       Values of LAMBDA outside this range will return floating infiniy values
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       June 8,1999 Program Written by  S. Maritorena
;
;                   Stephane Mariorena provided Kw values for
;                   Smith & Baker (1981), Pope 93 and Pope & Fry 1997
;                   These were in S. Maritorena's program: AM_hyp2.pro
;
;-
;**************************************************************************************************


  IF N_ELEMENTS(RES) NE 1 THEN RES = 0.5
; Ensure that specified resolution is less than or equal to 0.5 (for this program to work properly)
  IF RES GT 0.5 THEN RES = 0.5

  dir = 'D:\IDL\data\'
  file = dir + 'clear_water.csv'
  d = READ_CSV(file)
;  
;  file = dir + 'clear_water.dbf'
;  d = READ_DB(file)


; ====================>
; Generate a Wavelength Array to Desired Resolution
  min_lambda = 200
  max_lambda = 800
  WL = INTERVAL([min_lambda,max_lambda],RES)
  WL = (ROUND(10.0*WL))/10.0


; ====================>
; Make a structure to hold all interpolated and calculated data
  _MISSING = MISSINGS(0.0)
  BASE = CREATE_STRUCT('WL','','AW_SB81',_MISSING,'AW_P93',_MISSING,'AW_PF97',_MISSING,$
                                'BW_SB81',_MISSING,'BBW_SB81',_MISSING,$
                                'BW_B94',_MISSING, 'BBW_B94',_MISSING,$
                                'BW_M74',_MISSING, 'BBW_M74',_MISSING, $
                                'KW_SB81',_MISSING,'KW_P93',_MISSING,'KW_PF97',_MISSING  )

  ARR = REPLICATE(BASE,N_ELEMENTS(WL))
  ARR.WL = WL

; ====================>
; Linearly Interpolate AW_P93 only for wavelengths with non missing AW_p93 data
  OK     = WHERE(D.AW_P93 NE MISSINGS(D.AW_P93))
  _WL    = D[OK].WL_PF
  data   = D[OK].AW_P93
  min_wl = min(_wl)
  max_wl = max(_wl)
  I_WL   =  (INTERVAL([min_WL,max_WL],RES))
  i_data = INTERPOL(data, _wl, I_WL)
  OK = WHERE(WL GE min_wl AND WL LE max_wl,COUNT)
  IF COUNT EQ N_ELEMENTS(i_DATA) THEN BEGIN
   arr(ok).aw_p93 = i_data
  ENDIF ELSE BEGIN
    PRINT, 'ERROR'
    STOP
  ENDELSE

; ===> Linearly Interpolate AW_PF97 only for wavelengths with non missing AW_PF97 data
  OK     = WHERE(D.AW_PF97 NE MISSINGS(D.AW_PF97))
  _WL    = D[OK].WL_PF
  data   = D[OK].AW_PF97
  min_wl = min(_wl)
  max_wl = max(_wl)
  I_WL   = INTERVAL([min_WL,max_WL],RES)
  i_data = INTERPOL(data, _wl, I_WL)
  OK = WHERE(WL GE min_wl AND WL LE max_wl,COUNT)
  IF COUNT EQ N_ELEMENTS(i_DATA) THEN BEGIN
   arr(ok).AW_PF97 = i_data
  ENDIF ELSE BEGIN
    PRINT, 'ERROR'
    STOP
  ENDELSE

; ====================>
; Linearly Interpolate AW_SB81 only for wavelengths with non missing AW_SB81 data
  OK     = WHERE(D.AW_SB81 NE MISSINGS(D.AW_SB81))
  _WL    = D[OK].WL_SB81
  data   = D[OK].AW_SB81
  min_wl = min(_wl)
  max_wl = max(_wl)
  I_WL   = INTERVAL([min_WL,max_WL],RES)
  i_data = INTERPOL(data, _wl, I_WL)
  OK = WHERE(WL GE min_wl AND WL LE max_wl,COUNT)
  IF COUNT EQ N_ELEMENTS(i_DATA) THEN BEGIN
   arr(ok).AW_SB81 = i_data
  ENDIF ELSE BEGIN
    PRINT, 'ERROR'
    STOP
  ENDELSE
  
; ====================>
; Linearly Interpolate BW_B94 only for wavelengths with non missing BW_B94 data
  OK     = WHERE(D.BW_B94 NE MISSINGS(D.BW_B94))
  _WL    = D[OK].WL_B94
  data   = D[OK].BW_B94
  min_wl = min(_wl)
  max_wl = max(_wl)
  I_WL   = INTERVAL([min_WL,max_WL],RES)
  i_data = INTERPOL(data, _wl, I_WL)
  OK = WHERE(WL GE min_wl AND WL LE max_wl,COUNT)
  IF COUNT EQ N_ELEMENTS(i_DATA) THEN BEGIN
   arr(ok).BW_B94 = i_data
  ENDIF ELSE BEGIN
    PRINT, 'ERROR'
    STOP
  ENDELSE

; ====================>
; Linearly Interpolate BW_M74 only for wavelengths with non missing BW_M74 data
  OK     = WHERE(D.BW_M74 NE MISSINGS(D.BW_M74))
  _WL    = D[OK].WL_M74
  data   = D[OK].BW_M74
  min_wl = min(_wl)
  max_wl = max(_wl)
  I_WL   = INTERVAL([min_WL,max_WL],RES)
  i_data = INTERPOL(data, _wl, I_WL)
  OK = WHERE(WL GE min_wl AND WL LE max_wl,COUNT)
  IF COUNT EQ N_ELEMENTS(i_DATA) THEN BEGIN
   arr(ok).BW_M74 = i_data
  ENDIF ELSE BEGIN
    PRINT, 'ERROR'
    STOP
  ENDELSE

; ====================>
; Compute bbw
  ok = WHERE(arr.bw_sb81 NE _missing)
  arr(ok).bbw_sb81 = 0.5 * arr(ok).bw_sb81

  ok = WHERE(arr.bw_b94 NE _missing)
  arr(ok).bbw_b94 = 0.5 * arr(ok).bw_b94
  
  ok = WHERE(arr.bw_m74 NE _missing)
  arr(ok).bbw_m74 = 0.5 * arr(ok).bw_m74


; ====================>
; Compute Kw values for Pope 93, Pope & Fry 97 and Smith & Baker 81
  ok = WHERE(arr.aw_p93 NE _missing AND arr.bbw NE _missing)
  arr(ok).kw_p93  = arr(ok).aw_p93  + arr(ok).bbw

  ok = WHERE(arr.aw_pf97 NE _missing AND arr.bbw NE _missing)
  arr(ok).kw_pf97 = arr(ok).aw_pf97 + arr(ok).bbw

  ok = WHERE(arr.aw_sb81 NE _missing AND arr.bbw NE _missing)
  arr(ok).kw_sb81 = arr(ok).aw_sb81 + arr(ok).bbw

  IF N_ELEMENTS(LAMBDA) GE 1 THEN BEGIN
      COPY = BASE
     FOR N=0L,N_ELEMENTS(LAMBDA)-1L DO BEGIN
       OK = WHERE(ARR.WL EQ LAMBDA(N),COUNT)
       IF COUNT GE 1 THEN BEGIN
         copy = [COPY,arr(ok[0])]
       ENDIF ELSE BEGIN
         copy = [COPY, BASE]
       ENDELSE
     ENDFOR
     COPY = COPY(1:*)
     RETURN, COPY
  ENDIF ELSE BEGIN
;		===> Write a CSV file
		IF KEYWORD_SET(CSV) THEN STRUCT_2CSV,'CLEAR_WATER.CSV',ARR
    RETURN, ARR
  ENDELSE


END ; END OF PROGRAM

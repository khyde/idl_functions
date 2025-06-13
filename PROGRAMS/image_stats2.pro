; $ID:	IMAGE_STATS2.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO IMAGE_STATS2, FILE=FILE, ARRAY=array, RANGE=range, $

                   OUTFILE=outfile,$

                   QUIET= quiet
;+
; NAME:
;       IMAGE_STATS2
;
; PURPOSE:
;       Reads output from IMAGE_STATS.PRO (*.his) and computes univariate statistics
;       on the grey-scale frequency data which is within the user-specified RANGE
;
; CATEGORY:
;
;
; CALLING SEQUENCE:

;       IMAGE_STATS2, FILE='c:\idl\*.his'
;       IMAGE_STATS2, FILE='c:\idl\*.his', range=[1,249]
;       IMAGE_STATS2, FILE='c:\idl\*.his', range=[1,249], output = 'c:\idl\test.txt'

; INPUTS:
;       FILES       HIS FILE (Output from IMAGE_STATS.PRO)
;
; KEYWORD PARAMETERS:
;
;       OUTPUT		The name of an output file (default is IMAGE_STATS.TXT

;       QUIET		Prevents printing of program progress
;
;
; OUTPUTS:
;      ARRAY  : Contains the histogram as well as the univariate statistics
;               based on the grey scale data within the allowable range
;
;      A text file containing computed statistics
;
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
;       Written by:  J.E.O'Reilly, September 12, 1997
;       Modified                   February   3, 1998
;-


; **********************************************************
  IF N_ELEMENTS(FILE) EQ 0 THEN BEGIN
    file = PICKFILE(TITLE='Pick an Image File',FILTER='*.his')
  ENDIF


; ==================>
; Range Must be provided
; Usually range is specified to ignore 0's and 255's
; (e.g. RANGE = [1,254]  or RANGE = [1,249]

  AGAIN:
  IF N_ELEMENTS(RANGE) NE 2 THEN BEGIN
    YN = DIALOG_MESSAGE('You Must Provide Allowable Grey-Scale Range e.g. range = 1,249',/INFORMATION)
    RANGE =[0L,0L]
    READ,RANGE, PROMPT='ENTER ALLOWABLE GREY-SCALE RANGE e.g. 1,249'
  ENDIF

  IF N_ELEMENTS(RANGE) NE 2 OR RANGE[0] LT 0 OR RANGE[1] GT 255 THEN BEGIN
   RANGE = 0L
   GOTO, AGAIN
  ENDIF


  c = ","

; **********************************************************
; M A I N           P R O G R A M        L O O P
; **********************************************************

; ==============>
; Read the data written by IMAGE_STATS_WRITE.PRO

  img_stats = READALL(file,/quiet,TYPE='his')
  N = N_ELEMENTS(img_stats)


; ================>
; Create an array to hold all statistics of the frequency histo data
  _stats = REPLICATE(STATS([1,2,3.],/QUIET),N)

  sequence = INDGEN(N_ELEMENTS(img_stats[0].hist))

; =================>
  FOR nth = 0, N-1 DO BEGIN
   iname = img_stats(nth).iname
   color = img_stats(nth).color
    hist  = img_stats(nth).hist
    values = !VALUES.F_INFINITY
    txt = STRING(iname,FORMAT='(A80)') + c + STRING(color,format='(i4)') + c

;   ====================>
;   Find nonzero elemens of hist within allowable range
    ok = WHERE(hist GT 0 AND (sequence GE range[0] AND sequence LE range[1]),count)

;   ===================>
;   For each of the valid grey scale bins reconstruct the population of values
    FOR _ok = 0, count-1 DO BEGIN
      datum = ok(_ok)
      freq = hist(ok(_ok))
      values = [values,REPLICATE(datum, freq )]
    ENDFOR
    IF count GE 1 THEN values = values(1:*)  ; eliminate dummy first value

;   ================>
;   Compute univariate statistics
    s = STATS(values)
    FOR i = 0,11 DO BEGIN
     _stats(nth).(I) = s[0].(I)
    ENDFOR

  ENDFOR ; FOR nth = 0, N_ELEMENTS(image_stats) -1 DO BEGIN


; ==================>
; Create a structure containing image stats (frequencies)
; as well as univariate statistics for data within user-specified range
;
; First add range to img_stats structure
  _range = STRTRIM(STRING(range[0]),2) + '_' + STRTRIM(STRING(range[1]),2)

  R = CREATE_STRUCT("range",_range)
  R = REPLICATE(R,N)

; ==============>
; Merge img_stats with _stats structures
  array = MERGE_STRUCT(img_stats,r)

; ==============>
; Merge r with array structures
  array = MERGE_STRUCT(array,_stats)

  NAMES = TAG_NAMES(array)
  tags  = INDGEN(N_ELEMENTS(names))
  ok  = WHERE(names NE 'HIST' AND names NE 'STATSTRING')
  names = names(ok)
  tags  =  tags(ok)

  IF N_ELEMENTS(OUTFILE) EQ 1 THEN BEGIN

;   ==============>
;   Print the statistical results
    OPENW,LUN,OUTFILE,/GET_LUN
    comma = ","
    TXT = ''

;   ================>
;   Print the Column Headings for the Tag Names
    FOR nth = 0, N_ELEMENTS(names)-1 DO BEGIN
     txt = txt + STRTRIM(STRING(names(nth)),2) + comma
    ENDFOR
    PRINTF, LUN, txt


    FOR nth = 0, N-1 DO BEGIN
      txt = ''
      FOR _tag = 0, N_ELEMENTS(tags) -1 DO BEGIN
        atag = tags(_tag)
        IF atag NE 2 THEN txt = txt + STRTRIM(STRING(array(nth).(atag)),2) + comma
      ENDFOR
      PRINTF, lun, txt
    ENDFOR
    CLOSE, lun
    FREE_LUN,LUN
  ENDIF

; ====================>
; Print program statistics
  IF NOT KEYWORD_SET(QUIET) THEN BEGIN
    PRINT, ''
    PRINT, ' IMAGE_STATS2 IS DONE >>>>>>>>>>>>>>>>>>>>'
  ENDIF

; ************************************************************
  END  ; END OF PROGRAAM
; ************************************************************

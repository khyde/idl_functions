; $ID:	IMAGE_STATS_READ.PRO,	2020-07-08-15,	USER-KJWH	$

 PRO IMAGE_STATS_READ, FILE=FILE, ARRAY=array, RANGE=range, $

                   OUTPUT = output,$

                   QUIET= quiet
;+
; NAME:
;       IMAGE_STATS_READ
;
; PURPOSE:
;       Reads output from IMAGE_STATS.PRO (*.his) and computes univariate statistics
;       on the grey-scale frequency data which is within the user-specified RANGE
;
; CATEGORY:
;
;
; CALLING SEQUENCE:

;       IMAGE_STATS_READ, FILE='c:\idl\*.his'
;       IMAGE_STATS_READ, FILE='c:\idl\*.his', output = 'c:\idl\test.txt'

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
;      A file containing the statistics of data in the HIS file
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
    file = PICKFILE(TITLE='Pick an Image File',FILTER='his')
  ENDIF


; ==================>
; Range Must be provided
; Usually range is specified to ignore 0's and 255's
; (e.g. RANGE = [1,254]  or RANGE = [1,249]

  AGAIN:
  IF N_ELEMENTS(RANGE) NE 2 THEN BEGIN
    YN = DIALOG_MESSAGE('You Must Provide Allowable Grey-Scale Range e.g. range = 1,249',/INFORMATION)
    RANGE =[0,0]
    READ,RANGE, PROMPT='ENTER ALLOWABLE GREY-SCALE RANGE e.g. 1,249'
  ENDIF

  IF N_ELEMENTS(RANGE) NE 2 OR RANGE[0] LT 0 OR RANGE[1] GT 255 THEN BEGIN
   RANGE = 0
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

    ok = WHERE(hist GT 0 AND (sequence GE range[0] AND sequence LE range[1]),count)


    FOR i = 0, count-1 DO BEGIN
      datum = ok(i)
      freq = hist(ok(i))
      values = [values,REPLICATE(datum, freq )]
    ENDFOR

    IF count GE 1 THEN values = values(1:*)  ; eliminate dummy first value



    s = STATS(values)
    FOR i = 0,11 DO BEGIN
     _stats(nth).(I) = s[0].(I)
    ENDFOR


;     ===============>
;     Add stats structure to image_stats structure

    ENDFOR ; FOR nth = 0, N_ELEMENTS(image_stats) -1 DO BEGIN


; ==================>
; Create a structure containing image stats (frequencies)
; as well as univariate statistics for data within user-specified range


  array = MERGE_STRUCT(img_stats,_stats)

 ;     IF N_ELEMENTS(output) GE 1 THEN BEGIN
 ;      s = STATS(data,file='C:\IDL\JAY\image_stats_write.txt',/append,notes = txt)
 ;     ENDIF ELSE BEGIN
 ;      s = STATS(data)
  ;    ENDELSE
; ====================>
; Print program statistics
  IF NOT KEYWORD_SET(QUIET) THEN BEGIN
    PRINT, ''
    PRINT, ' IMAGE_STATS_READ IS DONE >>>>>>>>>>>>>>>>>>>>'


  ENDIF

; ************************************************************
  END  ; END OF PROGRAAM
; ************************************************************

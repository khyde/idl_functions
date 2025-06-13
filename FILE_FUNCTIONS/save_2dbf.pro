; $ID:	SAVE_2DBF.PRO,	2020-06-30-17,	USER-KJWH	$
  PRO  SAVE_2DBF, FILES, FIELDS=FIELDS, OUTPUT=OUTPUT
;+
; NAME:
;       SAVE_2DBF.PRO
;
; PURPOSE:
;       Read an IDL simple SAVE data set and output a DBF file
;
; CATEGORY:
;       READ/WRITE
;
; CALLING SEQUENCE:
;       SAVE_2DBF
;       SAVE_2DBF,'*.SAVE'
;
; INPUTS:
;       FILES:  IDL SAVE FILES (SIMPLE, ONE-LAYER STRUCTURES, ETC)
;
; KEYWORD PARAMETERS:
;        FIELDS:  Variables to translate into dbf
;                 (if fields is not provided then all fields in save will be written to the dbf file)
; OUTPUTS:
;        A DBF FILE
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       ASSUMES THAT THE SAVE FILES ARE SIMPLE ARRAYS AND CAN BE TURNED INTO SPREADSHEET ROW VS COLUMN
;
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Sept 26,2000
;-


  PRO_NAME='SAVE_2DBF'

; ====================>
; Check if files provided
  IF N_ELEMENTS(FILES) EQ 0 THEN FILES = DIALOG_PICKFILE(TITLE='Pick SAVE files',FILTER='*.SAVE',/MULTIPLE_FILES)

  FILES = FILELIST(FILES,/SORT)

  FOR NTH = 0,N_ELEMENTS(FILES)-1L DO BEGIN
    AFILE = FILES[NTH]
    FN=PARSE_IT(AFILE)
    NAME = FN.NAME
    save=IDL_RESTORE(AFILE)


    TYPE = IDLTYPE(SAVE,/CODE)
    S=SIZE(SAVE,/STRUCT)
    IF TYPE EQ 8 THEN BEGIN ; STRUCTURE
      IF S.N_DIMENSIONS EQ 1 THEN BEGIN
        IF N_ELEMENTS(OUTPUT) NE 1 THEN DBFFILE=FN.DIR+FN.NAME+'_.DBF' ELSE DBFFILE=OUTPUT
        WRITE_DB,DBFFILE,SAVE
      ENDIF ELSE BEGIN
        PRINT, 'ERROR: Too complex to make into a simple spreadsheet row vs col dbf file'
      ENDELSE
    ENDIF

  ENDFOR


  END ; end of program

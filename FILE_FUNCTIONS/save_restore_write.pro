;
  PRO  SAVE_RESTORE_WRITE, FILES
;+
; NAME:
;       SAVE_RESTORE_WRITE.PRO
;
; PURPOSE:
;       READ SAVE FILE & SAVE IT, KEEP FILENAME THE SAME.
;            (Original files had more than 1 variable saved)
;
; CATEGORY:
;       file
;
; CALLING SEQUENCE:
;       save_restore_write()
;
; INPUTS:
;
;
; KEYWORD PARAMETERS:
;        Files:  input *.SAVE files
; OUTPUTS:
;        *.SAVE files
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       ASSUMES THAT THE RESTORED VARIABLES ARE IN A STRUCTURE CALLED 'S'.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;
; ====================>
; Check if files provided

; provide full path to the folder/folders where save files are located
  FOLDERS_PATH = [$
  'E:\CZCS\GEES\mean_Test\',$
  'H:\CZCS\GEHS\mean_Test\' $
  ]

 ; FILES = FILELIST('E:\CZCS\GEES\MEAN_NEW\*.SAVE')

  FOR N_PATHS = 0,N_ELEMENTS(FOLDERS_PATH) -1L DO BEGIN
    _PATH = FOLDERS_PATH(N_PATHS)
    FILES = FILELIST(_PATH + '*.save')
    IF N_ELEMENTS(FILES) EQ 0 THEN BEGIN
      FILES = DIALOG_PICKFILE(TITLE='Pick SAVE files',FILTER='*.SAVE',/MULTIPLE_FILES)
    ENDIF
    TARGET_FILES = FILES
    FOR N_TARGETS = 0,N_ELEMENTS(TARGET_FILES)-1L DO BEGIN
      TARGET_FILE = TARGET_FILES(N_TARGETS)
      EXIST = FILE_TEST(TARGET_FILE)
      IF EXIST EQ 0 THEN CONTINUE
      PRINT, 'RESTORING FILE:  ',TARGET_FILE
      RESTORE,TARGET_FILE
      PRINT, 'SAVING FILE:  ',TARGET_FILE
      SAVE,FILENAME=TARGET_FILE,/COMPRESS, S
    ENDFOR  ;FOR N_TARGETS
  ENDFOR ; FOR PATHS
  END ; end of program

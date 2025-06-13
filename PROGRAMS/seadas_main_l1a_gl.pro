; $ID:	SEADAS_MAIN_L1A_GL.PRO,	2020-06-30-17,	USER-KJWH	$
;
; Main program to run SeaDAS processing
;
PRO SEADAS_MAIN_L1a_GL
;
;
;  Program calls SD_SEADAS_L1_2_MAP.PRO
;  This program combines input seawifs l1a files with sd_seadas_l1a_to_l1b.pro
;  and feeds it to seadas
;
;  WRITTEN:
;  Oct 19, 2006	K.J.W.Hyde:
;
;  MODIFICATIONS:
;  Mar 7,  2007   K.J.W.Hyde: Changed the make inventory step
;                             Made compatible to run either SeaWiFS or MODIS
;  Apr 27, 2007   K.J.W.Hyde: Updated the make inventory and check what needs to be processed steps
;                             Added period plot step
;  May 11, 2007   K.J.W.Hyde: Added subset option
;                             Added L0 processing capabilities
;
  ROUTINE_NAME = 'SEADAS_MAIN_L1a_GL'
;
;  To run,
;  1) At the Linux prompt type 'idl'
;  2) Type '.r seadas_main' to compile the main program
;  3) Type 'seadas_main' to execute the program
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; *****************************************************************************************************
;	USER INPUTS AND SWITCHES
; *****************************************************************************************************

; ***** Establish the directory for the input files (MODIS_L1A) *****
  DIR_L1A         = '/projects/APS/MODIS/GL_l1a/'

; ***** Establish the directory for the output files (MODIS_L1B) *****
	DIR_L1B         = '/projects/APS/MODIS/GL_l1b/'

; ***** Establish the directory for the geolocation files (GEOLOCATION) *****
	DIR_GEO         = '/projects/APS/MODIS/GL_geo/'

; ***** Establish the directory for the log files (LOG) *****
	DIR_LOG         = '/projects/APS/MODIS/GL_log/'

; ***** Create a search string for files that need to be processed (e.g. '*2007*', 'S*' - SeaWiFS, 'A*' - Aqua, 'A*L0*' - High Res MODIS) *****
  FILES_IN_TARGET = 'A2002*'

; ***** To run the files in reverse order, set REVERSE_FILES = 1 else REVERSE_FILES = 0 *****
  REVERSE_FILES = 0

; ***** Set OVERWRITE = '1' if all new files are to be created, else only unprocessed files will be run *****
  OVERWRITE     = '0'         ; OVERWRITE keyword
	SENSOR        = 'MODIS'
  METHOD        = 'COLL5'
  SATELLITE     = 'AQU'
  COVERAGE      = 'LAC'
  LEVEL         = 'L1A'
  RESOLUTION    = '-1'

  FILES = FILE_SEARCH(DIR_L1A + FILES_IN_TARGET) ; Find files

  IF FILES[0] EQ ''  THEN BEGIN
    PRINT, 'ERROR: NO FILES FOUND'
    GOTO, DONE
  ENDIF

  IF KEYWORD_SET(REVERSE_FILES) THEN FILES = REVERSE(FILES)

; ***** Loop through each file *****
  FOR _FILE=0,N_ELEMENTS(FILES)-1L DO BEGIN
    AFILE=FILES(_FILE)
    NAMES = STRSPLIT(AFILE,'/',/EXTRACT)
    INAME = NAMES(N_ELEMENTS(NAMES)-1)
    YEAR  = STRMID(INAME,1,4)
    DOY   = STRMID(INAME,5,3)
    TIME  = STRMID(INAME,8,6)
    DATE  = STRMID(YDOY_2DATE(YEAR, DOY),4,4)
    FILE_LABEL = 'A' + YEAR + DOY + '.' + DATE + '.' + TIME

    _OVERWRITE = STRING(OVERWRITE)

		PRINT, ''
    PRINT, 'Working on ' + INAME + ' (' + STRTRIM(STRING(_FILE),2) + ' of ' + STRTRIM(STRING(N_ELEMENTS(FILES)),2) + ' total files to be processed)'
    PRINT, ''

;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

    cmd = 'sd_seadas_l1a_to_l1b, files='  + "'" + afile      + "'"             ; List of input files
    cmd = cmd + ', iname='           + "'" + iname           + "'"             ; Iname of input file
;    cmd = cmd + ', dir_l1a='         + "'" + dir_l1a         + "'"             ; L1A working directory
;    cmd = cmd + ', dir_l1b='         + "'" + dir_l1b         + "'"             ; L1B working directory
;    cmd = cmd + ', dir_geo='         + "'" + dir_geo         + "'"             ; GEOLOCATION working directory
;    cmd = cmd + ', dir_log='         + "'" + dir_log         + "'"             ; LOG working directory
;    cmd = cmd + ', file_label='      + "'" + file_label      + "'"             ; Output file names
;    cmd = cmd + ', sensor='          + "'" + sensor          + "'"             ; SeaWiFS or MODIS
;    cmd = cmd + ', method='          + "'" + method          + "'"             ; Valid method (REPRO5)
;    cmd = cmd + ', coverage='        + "'" + coverage        + "'"             ; Valid coverage (MLAC, LAC) or HRPT site
;    cmd = cmd + ', resolution='      + "'" + resolution      + "'"             ; For High Res MODIS processing
;    cmd = cmd + ', level='           + "'" + level           + "'"             ; Input file LEVEL (L1A, L2, etc.)
;    cmd = cmd + ', overwrite='       + "'" + _overwrite      + "'"             ; Overwrite previous files

    CMD_FILE = '/software/idl/noaa/nmfs/seadas_main_batch'
    LOG_FILE = DIR_LOG+'seadas.log'
    OPENW,LUN,CMD_FILE,/GET_LUN
    PRINTF,LUN,CMD
    PRINTF,LUN,'exit'
    FREE_LUN,LUN
stop
    SPAWN, 'seadas -b ' + CMD_FILE +' >>'+LOG_FILE

  ENDFOR; FOR _FILE

;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

  DONE:
  PRINT,'DONE WITH  seadas_main.pro'
END

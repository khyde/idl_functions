 $Id: debug_level_set.pro, May 10 2011 $

PRO DEBUG_LEVEL_SET, LEVEL=LEVEL

;+
; NAME:
;   DEBUG_LEVEL_SET
;
; PURPOSE:
;   Set or show the current NMFS / IDL system debug level.
;
; CATEGORY:
;   Debugging
;
; CALLING SEQUENCE:
;
;   DEBUG_LEVEL_SET, LEVEL=DESIRED_LEVEL
;   
;
; INPUTS:
;
; OPTIONAL INPUTS:
;   LEVEL  := level of debugging to set.
;             If NOT specified, simply print the current debug level, if any.
;             If !DEBUG = 1,2,3, etc. DEBUG_(functions) test against this value.
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   Prints out the state of the debugging system variable.
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; PROCEDURE:
;
; EXAMPLE:
;   Set the current debug level to 2.
;   (Debug functions should execute routines triggered at this level or higher):
;   DEBUG_LEVEL_SET, LEVEL=2
;   Print the current debugging level
;   DEBUG_LEVEL_SET
;   
; NOTES:
;   Debugging functions execute if level >= current debug level set in !DEBUG
;   Debugging level may be up to any number, but suggest a reasonable maximum.
;   Generally, the higher the debug level, the more information/debugging should occur.
;   User should write functions and insert statements in code reflecting the level
;   of debug processing they wish to do.  For example, at level 1, simple print statements
;   may occur, while at level 3, 4, etc. printing of every variable and saving of additional
;   debug data may occur.
;   
; References:
;   DEBUG_PRINT
;
; MODIFICATION HISTORY:
;     Written:  June 9, 2011 by D.W. Moonan, 28 Tarzwell Drive, NMFS, NOAA 02882 (daniel.moonan@noaa.gov)
;     Modified:  
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DEBUG_LEVEL_SET'
  
  DEFSYSV, '!DEBUG', exists=exists
  IF EXISTS NE 1 THEN BEGIN
    IF N_ELEMENTS(LEVEL) THEN BEGIN
      DEFSYSV,'!DEBUG', LEVEL
      PRINT, 'Debugging has been turned on and is set to level ' + STRING(!DEBUG)
    ENDIF ELSE BEGIN
      PRINT, 'Debugging is not turned on.'
    ENDELSE
  ENDIF
  IF EXISTS EQ 1 THEN BEGIN
    IF N_ELEMENTS(LEVEL) THEN BEGIN
      !DEBUG = LEVEL
      PRINT, 'Debug level set to ' + STRING(LEVEL)
    ENDIF ELSE BEGIN
      PRINT, 'Debug level is currently at level ' + STRING(!DEBUG)
    ENDELSE
  ENDIF

END; #####################  End of Routine ################################

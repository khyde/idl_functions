 $Id: debug_print.pro, May 10 2011 $

  PRO DEBUG_PRINT, LEVEL, STRING

;+
; NAME:
;   DEBUG_PRINT
;
; PURPOSE:
;   Print out the string if !DEBUG >= level, else do nothing.
;
; CATEGORY:
;   Debugging
;
; CALLING SEQUENCE:
;
;   DEBUG_PRINT, level, string
;   
;
; INPUTS:
;   level  := level of debugging at which to print.  if !DEBUG = 1,2,3, etc. and !DEBUG >= level, then print. 
;   string := message string to print if debugging is turned on
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   prints out a debug message
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; PROCEDURE:
;
; EXAMPLE:
;   DEBUG_PRINT, 2, 'ERROR at debug level 2'
;   
; NOTES:
;   Debugging printout occurs if level >= current debug level set in !DEBUG
;   Debugging level may be up to any number, but suggest a certain maximum. 
;
; MODIFICATION HISTORY:
;     Written:  May 10, 2011 by D.W. Moonan, 28 Tarzwell Drive, NMFS, NOAA 02882 (daniel.moonan@noaa.gov)
;     Modified:  
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DEBUG_PRINT'
  
  DEFSYSV, '!DEBUG', exists=exists
  IF EXISTS EQ 1 THEN BEGIN
    IF !DEBUG GE LEVEL THEN PRINT, STRING
  ENDIF

END; #####################  End of Routine ################################

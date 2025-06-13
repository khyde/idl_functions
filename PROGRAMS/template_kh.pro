; $ID:	TEMPLATE_KH.PRO,	2020-07-01-12,	USER-KJWH	$

  PRO TEMPLATE_KH

;+
; NAME:
;   TEMPLATE
;
; PURPOSE:
;   This procedure/function
;
; CATEGORY:
;   CATEGORY
;
; CALLING SEQUENCE:
;
;   TEMPLATE, Parameter1, Parameter2, Foobar
;
;   Result = TEMPLATE(Parameter1, Parameter2, Foobar)
;
; INPUTS:
;   Parm1:  Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;   Parm2:  Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1: Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   This function returns the
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; COMMON BLOCKS: If no common blocks then delete this line
; SIDE EFFECTS:  If no side effects then delete this line
; RESTRICTIONS:  If no restrictions then delete this line
;
; PROCEDURE:
;
; EXAMPLE:
;
; NOTES:
;   This routine will display better if you set your tab to 2 spaces:
;   (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)
;
;   Citations or any other useful notes
;
;   
; COPYRIGHT: 
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          with assistance from John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;    
;
; MODIFICATION HISTORY:
;			Written:  April 18, 2011 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;			Modified: Dec 29, 2015 - KJWH: Added SWITCHES information 
;			          Aug 01, 2018 - KJWH: Added COPYRIGHT
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'TEMPLATE'
	
	;===> #####   SWITCHES
	DO_STEP_1       = 'YORFSV'


	;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


; *****************************
	IF KEY(DO_STEP_1) THEN BEGIN
; *****************************
	  SNAME = 'DO_STEP_1'
    SWITCHES,DO_STEP_1,STOPP=STOPP,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE,INIT=INIT,R_FILES=R_FILES,R_DATASETS=R_DATASETS,R_MAPS=R_MAPS,DATERANGE=DATERANGE
    IF VERBOSE THEN PRINT, 'Running: ' + SNAME
	  IF KEY(STOPP) THEN STOP
	  
	  FILES = FILE_SEARCH(' ',COUNT=COUNT_FILES); FILL IN THE BLANKS
	  FILES = DATE_SELECT(FILES,DATERANGE)
	  IF KEY(R_FILES) THEN FILES = REVERSE(FILES)
	  
	  FOR NTH = 0,N_ELEMENTS(FILES)-1 DO BEGIN
	    FILE = FILES[NTH]
	    IF VERBOSE THEN PFILE,FILE,/U
	    IF VERBOSE THEN POF,NTH,FILES
	  ENDFOR;FOR NTH = 0,N_ELEMENTS(FILES)-1 DO BEGIN
	 
	  IF VERBOSE THEN , 'DO_STEP_1'
	ENDIF ; IF DO_STEP_1 GE 1 THEN BEGIN
	


END; #####################  End of Routine ################################

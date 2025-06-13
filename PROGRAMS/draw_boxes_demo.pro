; $ID:	DRAW_BOXES_DEMO.PRO,	2014-12-18	$

	PRO DRAW_BOXES_DEMO,IMAGE=IMAGE,XP=XP,YP=YP, ERROR = error

;+
; NAME:
;		DRAW_BOXES_DEMO
;
; PURPOSE:
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE:
;
; INPUTS:
;		Parm1:	Describe the positional input parameters here. Note again that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
;		Parm2:	Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;		KEY1:	Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;		This function returns the
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; COMMON BLOCKS: If no common blocks then delete this line
; SIDE EFFECTS:	 If no side effects then delete this line
; RESTRICTIONS:  If no restrictions then delete this line
;
;	PROCEDURE:
;			This is usually a description of the method, or any data manipulations
;
; EXAMPLE:
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

;		Citations or any other useful notes
;
;
; MODIFICATION HISTORY:
;			Written ~2006  J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (jay.oreilly@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'DRAW_BOXES_DEMO'
  SZ=SIZE(IMAGE,/STRUCT)
  IMAGE = BYTARR(500,500)
;    IMAGE = BYTARR(21,21)
  
  IMAGE(*,*)=255b
  XP =[50,150,200,300,400]
  YP=XP
 
  WIDTH=[10,5,11,23,22]
  
  COLOR = [21,10,18,5,1]
 
  NEW=DRAW_BOXES(IMAGE=IMAGE,WIDTH=WIDTH, COLOR=COLOR, XP=XP,YP=YP,ERROR = error)
  
  CALL_PROCEDURE,'PAL_36',R,G,B
  WRITE_PNG,'D:\IDL\DEMO\JUNK.PNG',NEW,R,G,B
;    WRITE_PNG,'C:\IDL\PROGRAMS\JUNK.PNG',NEW,R,G,B
  
  
	END; #####################  End of Routine ################################

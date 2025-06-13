; $Id:	image_edges_main_igor.pro,	February 13 2007	$

  PRO IMAGE_EDGES_MAIN
;
; NAME:
;      IMAGE_EDGES_MAIN
;
; PURPOSE:
;         This procedure is a MAIN routine for running IMAGE_EDGES
;
; CATEGORY:
;          Edge Detection
;
; CALLING SEQUENCE:
;                  IMAGE_EDGES_MAIN
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;                    None
;
; OUTPUTS:
;         Outputs from IMAGE_EDGES
;
; OPTIONAL OUTPUTS:
;
; RESTRICTIONS:
;  Assumes that the input files are the NOAA, Narragansett Standard Satellite Image Save files'
;
; PROCEDURE:
;
; EXAMPLE:
;
; NOTES:
;
; MODIFICATION HISTORY:
;                       Written Jan 17, 2007 by J.O'Reilly (NOAA)
;
; ****************************************************************************************************
        ROUTINE_NAME = 'IMAGE_EDGES_MAIN'

; ****************************************
; *** P R O G R A M   D E F A U L T S  ***
; ****************************************
; ===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;      The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
  ERROR = ''

; **************************************************************************************
; ** USER EDITED PARAMETERS FOR THE WORKING FOLDERS AND SUBFOLDERS FOR THIS PROJECT  ***
; **************************************************************************************
  DISK = 'C:'

  COMPUTER=GET_COMPUTER()
	PRINT, COMPUTER


  IF COMPUTER EQ 'BELKIN2' THEN DISK = 'C:'
  IF COMPUTER EQ 'LOLIGO' or COMPUTER EQ 'LAPSANG' THEN DISK = 'D:'
  DELIM= PATH_SEP()



; ***************************************************************
; *** Create the project folders if they do not already exist ***
; ***************************************************************
	PROJECT = 'EDGES'
  FOLDERS = ['FILES','DATA','DOC','BROWSE','PLOTS','SAVE']

  FILE_PROJECT, DISK=DISK, PROJECT=PROJECT, FOLDERS=FOLDERS
; ===> Now there should be the right subfolders in PROJECT
; and the subfolders (paths) are subsequently referered to as;
; !DIR_BROWSE,  !DIR_DATA,   !DIR_DOC,   !DIR_PLOTS,  !DIR_SAVE

; ********************************************************************************
; ***** U S E R    S W I T C H E S  Controlling which Processing STEPS to do *****
; ********************************************************************************
; 0 (Do not do the step)
; 1 (Do the step)
; 2 (Do the step and OVERWRITE any output if it alread exists)

; ===> Switches controlling which Processing STEPS to do
  DO_IMAGE_EDGES = 2

  DO_NEXT_STEP = 0

; **************************************************************
  IF DO_IMAGE_EDGES GE 1 THEN BEGIN
; **************************************************************
    OVERWRITE = DO_IMAGE_EDGES GE 2
    PRINT, 'S T E P:    DO_IMAGE_EDGES'
;   ===> Get the files to process

;	  TYPE = 'PNG'
 	  TYPE = 'SAVE'
;		TYPE = 'GIF'

    FILES=FILE_SEARCH(!DIR_FILES+'*.'+TYPE)
    FILTER = 'CANNY'
;    FILTER = 'SOBEL'

;    LIST,FILES
;	  PARSE FILE INFO

		FI=FILE_PARSE(FILES)
;;;		FILES=FILES(2)

;		LOW = 0.4
;		HIGH = 0.8
;   SIGMA = 4.0
;		IMAGE_EDGES,FILES,FILTER= FILTER,LOW=low,HIGH=high,SIGMA=sigma,OVERWRITE=overwrite

    SIGMA_ARRAY = [0.2, 1.0, 2.0, 3.0, 4.0]
    FOR i=0,4,1 DO BEGIN
      SIGMA=SIGMA_ARRAY(i)
      FOR LOW  = 0.0, 0.75, 0.1 DO BEGIN
  			FOR DIFF = 0.2, (0.95-LOW), 0.1	DO BEGIN
        	HIGH = LOW + DIFF
        	IMAGE_EDGES,FILES,FILTER=FILTER,LOW=low,HIGH=high,SIGMA=sigma,OVERWRITE=overwrite
		 		ENDFOR
			ENDFOR
		ENDFOR
  ENDIF ; IF DO_IMAGE_EDGES GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||

; **************************************************************
  IF DO_NEXT_STEP GE 1 THEN BEGIN
; **************************************************************
    OVERWRITE = DO_NEXT_STEP GE 2
    PRINT, 'S T E P:    DO_NEXT_STEP'

  ENDIF ; IF DO_NEXT_STEP GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||

END; #####################  End of Routine ################################

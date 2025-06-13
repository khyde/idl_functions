; $ID:	FILE_MAKE.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION FILE_MAKE,IN,OUT,OVERWRITE=OVERWRITE,VERBOSE=VERBOSE
;
;
;
; PURPOSE: THIS FUNCTION DETERMINES IF A FILE SHOULD BE MADE OR OVERWRITTEN, 
;          DEPENDING ON MTIMES 
; 
; CATEGORY:	LOGICAL;		 
;
; CALLING SEQUENCE: RESULT = FILE_MAKE(IN,OUT)
;
; INPUTS: IN THE NAMES OF INPUT FILE(S)
;         OUT THE NAME OF THE OUTPUT FILE(S)

; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;
;   OVERWRITE REWRITE THE OUT FILE
;   VERBOSE EXECUTES PRINT COMMANDS

; OUTPUTS: 
;		
;; EXAMPLES:
;           P,FILE_MAKE()
;           P,FILE_MAKE('FILE_MAKE.PRO')
;           ;===> SINCE JUNK.TXT IS NEWLY MADE, IT IS MORE RECENT THAN FILE_MAKE.PRO - SO MAKE = 0 AND SKIP IT
;           WRITE_TXT,'JUNK.TXT','JUNK' & P ,FILE_MAKE('FILE_MAKE.PRO','JUNK.TXT',/VERBOSE)
;           ;===> NOW USE KEY OVERWRITE
;           WRITE_TXT,'JUNK.TXT','JUNK' & P ,FILE_MAKE('FILE_MAKE.PRO','JUNK.TXT',/OVERWRITE,/VERBOSE)
;	NOTES:

;		
;
;
; MODIFICATION HISTORY:[ADAPTED FROM K.HYDE'S UPDATE_CHECK.PRO]
;			 MAR 23, 2014 - WRITTEN BY J.O'REILLY 
;			 DEC 12, 2014 - JOR:  ADDED NEW FUNCTIONS
;			 DEC 15, 2014 - JOR:  CHANGED QUIET TO VERBOSE
;			                      MADE IN,OUT PARAMETERS
;		   DEC 16, 2014 - JOR:  IF IN EQ [] OR OUT EQ [] THEN RETURN,0
;      DEC 17, 2014 - JOR:  ADDED EXAMPLES
;      DEC 30, 2014 - KJWH: ADDED SCENARIOS FOR BLANK ('') FILES 
;                           PROGRAM CAN REPLACE UPDATE_CHECK

;			            
;#################################################################################
;-
;**************************
  ROUTINE_NAME  = 'FILE_MAKE'
;**************************
  
  IF KEY(OVERWRITE) THEN RETURN, 1                         ; Overwrite is set so MAKE = 1
  
  IF OUT EQ [] THEN RETURN,1                               ; No output file so MAKE = 1  
  IF N_ELEMENTS(OUT) EQ 1 AND OUT[0] EQ '' THEN RETURN, 1  ; Output file is blank
  IF MIN(FILE_TEST(OUT)) EQ 0 THEN RETURN,1                ; At least one output does not exist so MAKE = 1
  
  IF IN EQ [] THEN RETURN,[]                               ; No input files
  IF N_ELEMENTS(IN) EQ 1 AND IN[0] EQ '' THEN RETURN, []   ; No input files
  
  
  
  IF MIN(GET_MTIME(OUT)) GT MAX(GET_MTIME(IN)) THEN MAKE = 0 ELSE MAKE= 1 ; Check MTIMES of existing in and out files
  
  IF MAKE EQ 0 AND  KEY(VERBOSE) THEN PFILE,OUT,/K
  IF MAKE EQ 1 AND  KEY(VERBOSE) THEN PFILE,OUT,/M
  RETURN,MAKE         

END; #####################  END OF ROUTINE ################################

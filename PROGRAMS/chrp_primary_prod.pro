; $ID:	CHRP_PRIMARY_PROD.PRO,	2014-12-18	$


 PRO CHRP_PRIMARY_PROD
;+
; NAME:
;       CHRP_PRIMARY_PROD
;
; PURPOSE:
;          Main routine for calculating primary productivity from C-14 and Oxygen measurements for the CHRP study
;						1) PI_FIT - Run Platt Model to calculate productivity parameters for both C-14 and Oxygen data
;						2) CHRP_EXT_COEF - Merge the profile and light data & run the extinction coefficient program to determine Zeu
;						3) Calculate DAILY productivity
;						4) Calculate AREAL productivity
;						5) PLOT PI curves and profile data
;						6)
;
;
; MODIFICATION HISTORY:
;       Written by: Kimberly J.W. Hyde, July 6, 2006
;				Modified:		Kimberly J.W. Hyde, August 11, 2006
;														Completed productivity programs and plotting
;-

	ROUTINE_NAME='CHRP_PRIMARY_PROD'

	PAL_36, R,G,B

; **************************************************
; ***** SWITCHES CONTROLLING PROCESSING STEPS  *****
; **************************************************
;		Switch	Operation
;		1  			Do not do Step
; 	2     	Do Step (make output file from step and overwrite output if it already exists)

		DO_PIFIT				= 2
		DO_DAILY				= 2


;	INPUT DESIRED CRUISE NAME
	CRUISE = 'CH0715'

; DIRECTORY
	IN_DIR					= !S.PROJECTS + 'MERL/INPUT_DATA/'
	OUT_DIR 				= !S.PROJECTS + 'MERL/OUTPUT_DATA/' & DIR_TEST, OUT_DIR


	IF DO_PIFIT GE 2 THEN CHRP_PIFIT, CRUISE=CRUISE, IN_DIR=IN_DIR, OUT_DIR=OUT_DIR, DO_DAILY=DO_DAILY


END

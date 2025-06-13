; $ID:	IMAGE_ADD_MASK_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$

	PRO IMAGE_ADD_MASK_DEMO, ERROR = error

;+
; NAME:
;		IMAGE_ADD_MASK_DEMO
;
; PURPOSE:

;		This procedure is a DEMO for IMAGE_ADD_MASK_DEMO
;

;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

;		Citations or any other useful notes
;
;
; MODIFICATION HISTORY:
;			Written Nov 21, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'IMAGE_ADD_MASK_DEMO'
;		files=FILELIST('E:\SST_GEQ-NEC\ts_images\browse\NJ_COAST\!D_*-N4ATG-NJ_COAST-PXY_500_500-SST-INTERP-TS_IMAGES-LEG.PNG')
;		DIR_OUT = 'E:\SST_GEQ-NEC\ts_images\browse\NJ_COAST\ANNO\'

	files=FILELIST('E:\SEAWIFS-NEC\ts_images\browse\NJ_COAST\!D_*-REPRO5-NJ_COAST-PXY_500_500-CHLOR_A-INTERP-TS_IMAGES-LEG.PNG')
		DIR_OUT = 'E:\SEAWIFS-NEC\ts_images\browse\NJ_COAST\ANNO\'


STOP
		HELP, FILES
		MASK=READ_PNG('D:\IDL\IMAGES\MASK-NJ_COAST-UPWELLING_LINES.PNG')

		COLOR_MASK  = 1
		COLOR_IMAGE = 251


		FOR NTH=0,N_ELEMENTS(FILES)-1 DO BEGIN
			AFILE=FILES[NTH]
			FN=FILE_PARSE(AFILE)
			PNGFILE = DIR_OUT+FN.FIRST_NAME+'-ANNO.PNG'
			IMAGE=READ_PNG(AFILE,R,G,B)
			NEW=IMAGE_ADD_MASK(IMAGE,MASK, COLOR_MASK=COLOR_MASK, COLOR_IMAGE=COLOR_IMAGE)
			WRITE_PNG,PNGFILE,NEW,R,G,B
		ENDFOR







	END; #####################  End of Routine ################################

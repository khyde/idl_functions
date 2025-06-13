; $ID:	COMPOSITE_PP_INPUTS.PRO,	2020-06-02-16,	USER-KJWH	$

  PRO COMPOSITE_PP_INPUTS, DATASETS, DATERANGE=DATERANGE, MP=MP, PP_ALG=PP_ALG, DIR_OUT=DIR_OUT, BUFFER=BUFFER

;+
; NAME:
;   COMPOSITE_PP_INPUTS
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
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
;          with assistance from John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
; ;   
;
; MODIFICATION HISTORY:
;			Written:  April 18, 2011 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;			Modified: Dec 29, 2015 - KJWH: Added SWITCHES information 
;			          Aug 01, 2018 - KJWH: Added COPYRIGHT
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'COMPOSITE_PP_INPUTS'
	
	SL = PATH_SEP()
	IF NONE(BUFFER) THEN BUFFER = 1
	IF NONE(MP) THEN OMAP = 'NEC' ELSE OMAP = STRUPCASE(MP)
	IF NONE(PP_ALG) THEN APROD = 'PPD-VGPM2' ELSE APROD = 'PPD-' + PP_ALG
	
	FOR S=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
	  DATASET = DATASETS(S)
	  INTERP_CHL = 1
	  INTERP_PAR = 0
	  PERIOD = 'D'
	  TXT_TAGS = 'DATE_CREATED'
	  CHL_ALG='OCI'
	  PPD_ALG='VGPM2'
	  
	  FOR P=0, N_ELEMENTS(CHL_ALG)-1 DO BEGIN
	    PDAT = REPLACE(DATASET,'_PAN','')
	    CHL_PROD = []
	    CASE CHL_ALG(P) OF
	      'OCI': BEGIN & SPROD = 'CHLOR_A-OCI' & NPROD = 'CHL' & CHL_PROD = 'chlor_a' & END
	      'OCX': BEGIN & SPROD = 'CHLOR_A-OCX' & NPROD = 'CHL' & CHL_PROD = 'chl_ocx' & END
	      'PAN': BEGIN & SPROD = 'CHLOR_A-PAN' & NPROD = 'CHL_PAN' & END
	    ENDCASE

      IF DATASET EQ 'OCCCI' THEN AMAP = 'L3B4' ELSE AMAP = 'L3B2'

	    DIR_NC     = !S.OC  + DATASET + SL + AMAP + SL + 'NC' + SL
	    DIR_SAV    = !S.OC  + DATASET + SL + AMAP + SL + 'SAVE' + SL
	    DIR_INTERP = !S.OC  + DATASET + SL + AMAP + SL + 'INTERP_SAVE' + SL
	    DIR_PP     = !S.PP + DATASET + SL + AMAP + SL + 'SAVE' + SL + APROD + SL
	    IF NONE(DIR_OUT) THEN PNG_OUT    = !S.PP + DATASET + SL + OMAP + SL + 'INPUT_DATA_COMPOSITES' + SL + APROD + SL ELSE PNG_OUT=DIR_OUT & DIR_TEST, PNG_OUT
	    DIR        = DIR_NC ; DEFAULTS

	    VFILES = FLS(DIR_PP + 'D_*.SAV',DATERANGE=DATERANGE,COUNT=VNUM)

	    IF VNUM EQ 0 THEN CONTINUE

	    FOR FTH=0L, N_ELEMENTS(VFILES)-1 DO BEGIN
	      VFILE  = VFILES(FTH)
	      FP_PPD = PARSE_IT(VFILE,/ALL)
	      INFILES = STRUCT_READ(VFILE,TAG='INFILE')

	      FP_IN = PARSE_IT(INFILES,/ALL)
	      CFILE = INFILES[WHERE(FP_IN.PROD EQ 'CHLOR_A')]
	      RFILE = INFILES[WHERE(FP_IN.PROD EQ 'PAR')]
	      SFILE = INFILES[WHERE(FP_IN.PROD EQ 'SST')]

	      IF MIN(FILE_TEST(INFILES)) EQ 0 THEN STOP

	      PNGFILE = PNG_OUT+REPLACE(FP_PPD.NAME,FP_PPD.MAP,OMAP)+'-INFILES.PNG'
	      IF FILE_MAKE([VFILE,CFILE,RFILE,SFILE],PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE

	      W = WINDOW(DIMENSIONS=[800,800],BUFFER=BUFFER)
	      PRODS_2PNG,VFILE,MAPP=OMAP,PROD='PPD',    TXT_TAGS=TXT_TAGS,/ADD_NAME,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[0,0.5,0.5,1],/ADD_CB
	      PRODS_2PNG,CFILE,MAPP=OMAP,PROD='CHLOR_A',TXT_TAGS=TXT_TAGS,/ADD_NAME,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[0.5,0.5,1,1],/ADD_CB
	      PRODS_2PNG,SFILE,MAPP=OMAP,PROD='SST',    TXT_TAGS=TXT_TAGS,/ADD_NAME,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[0,0,0.5,0.5],/ADD_CB
	      PRODS_2PNG,RFILE,MAPP=OMAP,PROD='PAR',    TXT_TAGS=TXT_TAGS,/ADD_NAME,VERBOSE=VERBOSE,/CURRENT,IMG_POS=[0.5,0,1,0.5],/ADD_CB
	      W.SAVE, PNGFILE
	      W.CLOSE
	      PFILE, PNGFILE
	    ENDFOR ; VFILES
	  ENDFOR ; CHL_ALG
	ENDFOR ; DATASET  
	
	


END; #####################  End of Routine ################################

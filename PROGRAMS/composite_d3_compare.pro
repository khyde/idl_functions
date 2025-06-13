; $ID:	COMPOSITE_D3_COMPARE.PRO,	2020-04-14-13,	USER-KJWH	$

  PRO COMPOSITE_D3_COMPARE, DATASETS, DATERANGE=DATERANGE, MP=MP, PROD=PROD, IMG_SCALE=IMG_SCALE, DIR_OUT=DIR_OUT, BUFFER=BUFFER

;+
; NAME:
;   COMPOSITE_D3_COMPARE
;
; PURPOSE:
;   This procedure plots the input and interp save files for a given product to easily compare
;
; CATEGORY:
;   COMPOSITES
;
; CALLING SEQUENCE:
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
;    
;
; MODIFICATION HISTORY:
;			Written:  Feb 21, 2019 by K.J.W. Hyde, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 (kimberly.hyde@noaa.gov)
;			Modified: Feb 21, 2019 - KJWH: Adapted from COMPOSITE_PP_INPUTS
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'COMPOSITE_D3_COMPARE'
	
	SL = PATH_SEP()
	IF NONE(BUFFER) THEN BUFFER = 1
	IF NONE(MP) THEN OMAP = 'NEC' ELSE OMAP = MP
	IF NONE(PROD) THEN PRODS = 'CHLOR_A-OCI' ELSE PRODS = PROD
	IF NONE(IMG_SCALE) THEN SCL = 2 ELSE SCL = IMG_SCALE
	MS = MAPS_SIZE(OMAP,PX=PX,PY=PY)
	PX = PX/SCL*2 
	PY = PY/SCL
	TXT_SZ = 12/SCL*2
	
	FOR S=0, N_ELEMENTS(DATASETS)-1 DO BEGIN
	  DATASET = DATASETS(S)
	  LET = GET_SENSOR_LETTER(DATASET) & IF N_ELEMENTS(LET) NE 1 THEN LET = ''
	  IF NONE(DATERANGE) THEN DR = SENSOR_DATES(DATASET) ELSE DR = DATERANGE
	  TXT_TAGS = 'DATE_CREATED'
	  
	  IF DATASET EQ 'OCCCI' THEN AMAP = 'L3B4' ELSE AMAP = 'L3B2'
	  
	  FOR P=0, N_ELEMENTS(PRODS)-1 DO BEGIN
	    APROD = VALIDS('PRODS',PRODS(P))
	    AALG  = VALIDS('ALGS',PRODS(P))
	    
	    DIR_NC     = !S.OC  + DATASET + SL + AMAP + SL + 'NC' + SL
	    DIR_SAV    = !S.OC  + DATASET + SL + AMAP + SL + 'SAVE' + SL
	    DIR_INTERP = !S.OC  + DATASET + SL + AMAP + SL + 'INTERP_SAVE' + SL
	    IF NONE(DIR_OUT) THEN DIR_OUT = !S.OC + DATASET + SL + OMAP + SL + 'D3_COMPARE_COMPOSITE' + SL + PRODS(P) + SL & DIR_TEST, DIR_OUT
	    
	    CASE PRODS(P) OF
	      'CHLOR_A-OCI': BEGIN & SPROD = 'CHLOR_A-OCI' & NPROD = 'CHL' & ODIR = DIR_NC & END
	      'CHLOR_A-OCX': BEGIN & SPROD = 'CHLOR_A-OCX' & NPROD = 'CHL' & ODIR = DIR_NC & END
	      'CHLOR_A-PAN': BEGIN & SPROD = 'CHLOR_A-PAN' & NPROD = 'CHLOR_A-PAN' & ODIR = DIR_SAV & END
	      'PAR': BEGIN & SPROD = 'PAR' & NPROD = 'PAR' & ODIR = DIR_NC & END
	      'SST': BEGIN & SPROD = 'SST' & NPROD = 'SST' & ODIR = DIR_SAV & END
	      ELSE: MESSAGE, 'ERROR: ' + PRODS(P) + ' needs to be added to the CASE statement'
	    ENDCASE      

	    DIR        = DIR_NC ; DEFAULTS

	    OFILES = FLS(ODIR + NPROD + SL + '*.*',DATERANGE=DR)
	    IFILES = FLS(DIR_INTERP + SPROD + SL + 'D_*.*',DATERANGE=DR) & IP = PARSE_IT(IFILES,/ALL)

	    FOR N=0, NOF(OFILES)-1 DO BEGIN
	      OFILE = OFILES(N)
	      FP = PARSE_IT(OFILE,/ALL)
	      I = IP[WHERE(IP.PERIOD EQ FP.PERIOD,/NULL)]
	      IFILE = I.FULLNAME
	      
        PNGFILE = DIR_OUT+REPLACE(I.NAME,I.MAP,OMAP)+'_COMPARE.PNG'
	      IF FILE_MAKE([OFILE,IFILE],PNGFILE,OVERWRITE=OVERWRITE) EQ 0 THEN CONTINUE
	      
	      W = WINDOW(DIMENSIONS=[PX,PY],BUFFER=BUFFER)
	      PRODS_2PNG, OFILE, PROD=APROD, /CURRENT, IMG_POS=[0,0,.5,1], MAPP=OMAP, /ADD_NAME, /ADD_CB, /CB_RELATIVE, CB_SIZE=TXT_SZ, TXT_SIZE=TXT_SZ
	      PRODS_2PNG, IFILE, PROD=APROD, /CURRENT, IMG_POS=[.5,0,1,1], MAPP=OMAP, /ADD_NAME, /ADD_CB, /CB_RELATIVE, CB_SIZE=TXT_SZ, TXT_SIZE=TXT_SZ
        W.SAVE, PNGFILE
        W.CLOSE
        PFILE, PNGFILE
	    ENDFOR
    ENDFOR
  ENDFOR
END; #####################  End of Routine ################################

; $ID:	L2_2SAVE_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$

  PRO L2_2SAVE_DEMO

;+
; NAME:
;   TEMPLATE
;
; PURPOSE:
;   This procedure is a DEMO for the L2_2SAVE program
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
; MODIFICATION HISTORY:
;			Written:  January 23, 2014 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified:  
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'L2_2SAVE_DEMO'
	
	PRINT, 'Running: DO_L2_2SAVE step'
	
	SL = DELIMITER(/PATH)
	DISK=!S.DATASETS
	DATASETS = []
	
	DATERANGE=['19970101','20201231']
	REVERSE_FILES = 0
	RUN_AGAIN_NUM = 0	
	REVERSE_DATASETS = 0
	REVERSE_FILES = 0
	
	DO_OC_SEAWIFS_MLAC = 0 & IF DO_OC_SEAWIFS_MLAC EQ 1 THEN DATASETS = [DATASETS,'OC-SEAWIFS-MLAC']
	DO_OC_MODIS_LAC    = 1 & IF DO_OC_MODIS_LAC    EQ 1 THEN DATASETS = [DATASETS,'OC-MODIS-LAC']
	DO_OC_CZCS_MLAC    = 0 & IF DO_OC_CZCS_MLAC    EQ 1 THEN DATASETS = [DATASETS,'OC-CZCS-MLAC']
	DO_SST_MODIS_LAC   = 0 & IF DO_SST_MODIS_LAC   EQ 1 THEN DATASETS = [DATASETS,'SST-MODIS-LAC']
	
	IF KEYWORD_SET(REVERSE_DATASETS) THEN DATASETS = REVERSE(DATASETS)	
	DP = DATE_PARSE(DATERANGE)
	AYEARS = YEAR_RANGE(MIN(DP.YEAR),MAX(DP.YEAR),/STRING)
	
	FOR N=0,N_ELEMENTS(DATASETS)-1 DO BEGIN
	  DATASET = DATASETS(N)
	  SUITES = []
	  PRODS  = []
	  IF DATASET EQ 'OC-SEAWIFS-MLAC' THEN BEGIN DIR = 'L2A' & MAPS=['NEC','NAFO','EC','NENA'] & SUITES=['SEAWIFS_MINIMUM']    & ENDIF
	  IF DATASET EQ 'OC-MODIS-LAC'    THEN BEGIN DIR = 'L2A' & MAPS=['NEC','NAFO','EC','NENA'] & SUITES=['MODIS_MINIMUM']      & ENDIF	  
	  IF DATASET EQ 'OC-CZCS-MLAC'    THEN BEGIN DIR = 'L2'  & MAPS=['NEC','EC'] & SUITES=['CZCS_FULL']      & ENDIF
	  IF DATASET EQ 'SST-MODIS-LAC'   THEN BEGIN DIR = 'L2'  & MAPS=['NEC','EC'] & PRODS='SST'               & ENDIF
	  
	  FOR S=0,N_ELEMENTS(SUITES)-1L DO BEGIN
	    VPRODS = VALID_SUITES(SUITES(S),/PRODUCTS)
	    CASE SUITES(S) OF
	      'HDF_ADD_ONS'     : PRODS = [PRODS,'ADG_412_GSM','A_CDOM_355_MANNINO','POC_STRAMSKI','POC_MANNINO','DOC_MANNINO','DOC_MANNINO_WINTER','DOC_MANNINO_SUMMER','DOC_MANNINO_GOM','DOC_MANNINO_SMAB','DOC_MANNINO_NYB']
	      'PIGMENTS'        : PRODS = [PRODS,'CHLOR_A_PAN','PIGMENTS_ALLO_PAN','PIGMENTS_CARO_PAN','PIGMENTS_CHLA_PAN','PIGMENTS_CHLB_PAN','PIGMENTS_CHLC_PAN','PIGMENTS_DIA_PAN','PIGMENTS_FUCO_PAN','PIGMENTS_LUT_PAN','PIGMENTS_NEO_PAN','PIGMENTS_PERID_PAN','PIGMENTS_VIOLA_PAN']
	      'ACDOM'           : PRODS = [PRODS,'ADG_412_GSM','A_CDOM_355_MANNINO']
	      'CHLOR'           : PRODS = [PRODS,'CHLOR_A_PAN']
	      'PAR'             : PRODS = [PRODS,'PAR']
	      'SEAWIFS_STD'     : PRODS = [PRODS,'CHLOR_A','CHLOR_A_PAN','PAR']
	      'SEAWIFS_MINIMUM' : PRODS = [PRODS,VPRODS.SUITE_PRODS]
	      'SEAWIFS_FULL'    : PRODS = [PRODS,VPRODS.SUITE_PRODS]
	      'MODIS_STD'       : PRODS = [PRODS,'CHLOR_A','CHLOR_A_PAN','PAR']
	      'MODIS_MINIMUM'   : PRODS = [PRODS,VPRODS.SUITE_PRODS]
	      'MODIS_FULL'      : PRODS = [PRODS,VPRODS.SUITE_PRODS]
	      'CZCS_FULL'       : PRODS = [PRODS,VPRODS.SUITE_PRODS]
	      ELSE: PRODS=PRODS
	    ENDCASE
	  ENDFOR
	  	  
	  FILES = FILE_SEARCH(DISK + DATASET + SL  + DIR + SL + 'S_' + [AYEARS]+'*.hdf')
	  BFILES = FILES
	  IF PRODS[0] EQ [] OR FILES[0] EQ [] THEN CONTINUE
	  DIR_OUT = DISK + DATASET + SL
	  
	  L2_2SAVE,FILES=FILES,PRODS=PRODS,DIR_OUT=DIR_OUT,NO_EXCLUDE=NO_EXCLUDE,N_EXCLUDE=N_EXCLUDE,DIR_EXCLUDE=DIR_EXCLUDE,$
	    MAP_OUT=MAPS,PX_OUT=PX_OUT,PY_OUT=PY_OUT,FLAG_BITS=FLAG_BITS,METHOD=METHOD,REVERSE_FILES=REVERSE_FILES,$
	    DATE_RANGE=DATERANGE,/KEEP_HDF,OVERWRITE=OVERWRITE,_EXTRA=_EXTRA
	    	  
	ENDFOR


END; #####################  End of Routine ################################



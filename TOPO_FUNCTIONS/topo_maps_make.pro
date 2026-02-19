; $ID:	TOPO_MAPS_MAKE.PRO,	2021-03-15-16,	USER-KJWH	$

  PRO TOPO_MAPS_MAKE, MAPP, PX=PX, PY=PY, VERBOSE=VERBOSE, OVERWRITE=OVERWRITE

;+
; NAME:
;   TOPO_MAPS_MAKE
;
; PURPOSE:
;   This procedure creates new TOPO maps
;
; CATEGORY:
;   MAPS, TOPO
;
; CALLING SEQUENCE:
;   TOPO_MAPS_MAKE
;   TOPO_MAPS_MAKE,'NEC',/OVERWRITE;
;   TOPO_MAPS_MAKE,'NEC' ; WILL SKIP OVER WHEN OUTPUT FILES ALREADY EXISTS
;   TOPO_MAPS_MAKE,'EQ_NWA',/OVERWRITE
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
;
; MODIFICATION HISTORY:
;			Written:  Mar 29, 2016 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified: MAR 30, 2016 - KJWH: Testing and updates
;			                               Added VERBOSE keyword
;-
; #############################################################################################################

;********************************
	ROUTINE_NAME = 'TOPO_MAPS_MAKE'
;********************************	
	
; ===> CONSTANTS
  TOPO_VERSION = 'SRTM30_PLUS V11.0 - NOVEMBER 29, 2014'
  PAL_BATHY, R,G,B	
	
; ===> GET MAP NAME
	IF NONE(MAPP) THEN MAPP = '' ELSE MAPP = STRUPCASE(MAPP)
	IF VALIDS('MAPS',MAPP) EQ '' THEN READ,MAPP,PROMPT = 'ENTER VALID MAP PROJECTION [NO QUOTES]:  ' 
	IF VALIDS('MAPS',MAPP) EQ '' THEN MESSAGE, 'ERROR: Must provide valid map.
	
; ===> GET MAP INFO
  SZ = MAPS_SIZE(MAPP)
  IF NONE(PX) THEN PX=SZ.PX
  IF NONE(PY) THEN PY=SZ.PY
  
; ===> GET LANDMASK
  MASK = READ_LANDMASK(MAPP,/STRUCT)  
  BACKGROUND_COLOR = RGBS(254)
  LAND_COLOR  = 253
  COAST_COLOR = 0
  MISS_COLOR  = 255
  RES = 600; FOR PNG
  
; ===> MAKE THE DIRECTORIES & ALL OUTPUT FILE NAMES
  DIR_BROWSE = !S.IDL_TOPO +'BROWSE'+ PATH_SEP()
  DIR_SAV    = !S.IDL_TOPO +'SAV'+ PATH_SEP()
  DIR_TEST,[DIR_SAV,DIR_BROWSE]
  BATHY_PNG     = DIR_BROWSE +'TOPO-'  +MAPP+'-PXY_'+ROUNDS(PX)+'_'+ROUNDS(PY)+'-BATHY.PNG'
  TOPO_SAV      = DIR_SAV    +'TOPO-'  +MAPP+'-PXY_'+ROUNDS(PX)+'_'+ROUNDS(PY)+'-TOPO.SAV'
  
; ===> GET THE TOPO FILES FOR THIS MAPP
  TOPO_FILES = TOPO_MAP(MAPP,/TOPO_FILES)
  
; ===> SKIP THIS MAPP IF OUTPUT ALREADY EXISTS
  IF FILE_MAKE(TOPO_FILES,[BATHY_PNG,TOPO_SAV],OVERWRITE=OVERWRITE,VERBOSE=VERBOSE) EQ 0 THEN GOTO, DONE ; >>>>>>>>>
  
  IF KEY(VERBOSE) THEN PFILE,TOPO_SAV,/M
  ITOPO = TOPO_MAP(MAPP, PX=PX, PY=PY)
  STRUCT_WRITE, ITOPO, FILE=TOPO_SAV, PROD='TOPO',IMAGE=IMG, MISSING_CODE=MISSINGS(ITOPO), DATA_UNITS='METERS', INFILE=TOPO_FILES, MAP=MAPP, NOTES=TOPO_VERSION

; ===> MAKE A BATHY PNG AND ADD LANDMASK        
  BYT = PRODS_2BYTE(-ITOPO,PROD='DEPTH')
  BYT(MASK.LAND) = LAND_COLOR
  BYT(MASK.COAST) = COAST_COLOR
  WRITE_PNG, BATHY_PNG, BYT, R, G, B 
  IF KEY(VERBOSE) THEN PFILE, BATHY_PNG

  DONE:

END; #####################  End of Routine ################################

; $ID:	D3_READ.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;;#############################################################################################################
	FUNCTION D3_READ, D3_FILE, XP=XP, YP=YP, LON=LON, LAT=LAT, DATE=DATE, NUM=NUM,$ ;INPUTS
	                 JDS=JDS, I_JDS=I_JDS, MAPP=MAPP, PROD=PROD ;OUTPUTS
;
;
; PURPOSE: 
;   This function reads specified information from a D3_FILE data file
;
; CATEGORY:	
;   D3 Family		 
;
; CALLING SEQUENCE: 
;   RESULT = D3_READ(D3_FILE)
;
; INPUTS: 
;   D3_FILE.... File generated from D3_MAKE
;
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;   XP.......... XP coordinate location to extract from the D3_FILE
;   YP.......... YP coordinate location to extract from the D3_FILE
;   LON......... Longitude value to extract from the D3_FILE
;   LAT......... Latitude value to extract from the D3_FILE
;   DATE........ Date to extact an imae from the D3_FILE
;   
; OPTIONAL OUTPUTS: 
;   NUM......... The number of data arrays in the d3 structure
;   JDS......... The julian days array from the d3 db
;   I_JDS....... The interpolated julian days array from the d3 db [no missing days] 
;   MAPP........ The name of the MAP parsed from the d3_file name 
;   PROD........ The name of the PROD parsed from the d3_file name 
;   
; OUTPUTS: A PSERIES OR A 2-D IMAGE ARRAY [DEPENDING ON KEYWORDS USED]
;		
; EXAMPLES:
;     S = D3_READ(D3_FILE,LON = -66.25,LAT =41.25) & PRINT,MM(S)
;     S = D3_READ(D3_FILE,XP = 763,YP =628)        & PRINT,MM(S)
;     S = D3_READ(D3_FILE,DATE = '20040122') & HELP,S & PRINT,MM(S)
;     NUM = D3_READ(D3_FILE,/NUM) & HELP,NUM 
;     ALSO SEE: D3_READ_DEMO

;	NOTES:
;
; COPYRIGHT:
; Copyright (C) 2018, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
;   This program was written by John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;          with assistance from Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov.  Inquiries should be directed to kimberly.hyde@noaa.gov.
;
;
; MODIFICATION HISTORY:
;			Written:  February 15, 2014 by John E. O'Reilly, NOAA/NEFSC/Narragansett Laboratory, 28 Tarzwell Drive, 02882 
;     Modified:
;     MAR 29, 2015 - JEOR: Revised to deal with the new D3_FILE SHMMAP instead of a D3_STRUCT
;     MAR 31, 2015 - JEOR: Added COMMON BLOCK for the D3 array
;     APR 02, 2015 - JEOR: Greatly simplified    
;     FEB 22, 2019 - KJWH: Updated formatting and removed unused code (e.g. IF NONE[NTH] THEN NTH=0 - NTH was not defined anywhere in the program)
;                          Changed D3_DB_FILE = REPLACE(D3_FILE,'-DATA.FLT','-DB.SAV') to D3_DB_FILE = REPLACE(D3_FILE,'-DAT.FLT','-DB.SAV')
;                          Changed KEY(XP) and KEY(YP) to ANY(XP) and ANY(YP) because the coordinate locations could be 0,0
;                          Changed KEY(LON) and KEY(LAT) to ANY(LON) and ANY(LAT) because the coordinate locations could be 0,0
;                          Added D3FILE to the COMMON block and a check to make sure you are using the correct D3 dataset
;                          NUM is now an optional output and no longer returned as the result if the keyword is set
;                          Now will return the full D3 array if LON/LAT, XP/YP, or DATE are not provided
;                          Updated documentation
;                          
;#################################################################################
;-
;*************************
  ROUTINE_NAME  = 'D3_READ'
;*************************
  COMMON _D3_READ, D3, D3FILE
  IF NONE(D3_FILE) THEN MESSAGE,'ERROR: D3_FILE IS REQUIRED'
  
  IF ANY(D3FILE) THEN BEGIN
    IF D3_FILE NE D3FILE THEN D3 = []
  ENDIF

;===> GET DIMENSIONS,MAPP AND PROD FROM THE D3_FILE
  FA = FILE_ALL(D3_FILE) & PX = FA.PX & PY = FA.PY & PZ = FA.PZ  & MAPP = FA.MAP & PROD = FA.PROD
  MS = MAPS_SIZE(MAPP)
  
  REPLACENAME = '-DAT.FLT'
  IF HAS(D3_FILE,'-MED_FILL') THEN REPLACENAME = '-MED_FILL.FLT'
  IF HAS(D3_FILE,'-INTERP')   THEN REPLACENAME = '-INTERP.FLT'
  D3_DB_FILE   = REPLACE(D3_FILE,REPLACENAME,'-DB.SAV')
  D3_BINS_FILE = REPLACE(D3_FILE,REPLACENAME,'-BINS.SAV')
  DB = STRUCT_READ(D3_DB_FILE)
  
  ; ===> CHECK TO SEE IF THE FILE IS A L3B_MAP SUBSET
  IF HAS(D3_FILE,'L3B') THEN BINS = IDL_RESTORE(D3_BINS_FILE) ELSE BINS = []

;===> GET N_FILES FROM THE DB
  N_FILES = NOF(DB) & NUM = N_FILES 
  JDS = PERIOD_2JD(DB.PERIOD)
  MIN_JD = ULONG(MIN(JDS))
  MAX_JD = ULONG(MAX(JDS))
  I_JDS = ULONG(INTERVAL([MIN_JD,MAX_JD],1))

;###################################################################
  IF NONE(D3) THEN BEGIN
    D3FILE = D3_FILE
    
    ;===> OPEN THE D3_FILE FOR READING AND WRITING
    OPENR, D3_LUN, D3_FILE, /GET_LUN  
    
    ;===> MEMORY-MAP THE D3 ARRAY TO THE D3_FILE
    SHMMAP ,'D3',/FLOAT,DIMENSION= [PX,PY,N_FILES], FILENAME=D3_FILE
    ;===> GET THE D3 ARR
    D3 = SHMVAR('D3')
    
    ;===> CHECK THAT THE DIMENSIONS PARSED FROM THE D3_FILE NAME AGREE WITH THOSE IN THE D3 ARRAY
    S = SIZEXYZ(D3) & _PX = S.PX & _PY = S.PY & _N_FILES = S.PZ
    IF PX NE _PX OR PY NE _PY OR N_FILES NE _N_FILES THEN MESSAGE,'ERROR: DIMENSIONS DO NOT MATCH'
  
  ENDIF;IF NONE(D3) THEN BEGIN
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

;===> TRANSLATE LON,LAT TO XP,YP
  IF ANY(LON) AND ANY(LAT) AND KEY(MAPP) THEN BEGIN
   XY= MAPS_LONLAT_2XYP(MAPP,PX=PX,PY=PY,LON=LON,LAT=LAT) 
   XP = XY[0]
   YP = XY[1]  
  ENDIF;IF KEY(LON) AND KEY(LAT) AND KEY(MAPP) THEN BEGIN

;===> EXTRACT A PSERIES AT XP,YP
  IF ANY(XP) AND ANY(YP) THEN BEGIN
    IF IS_L3B(MAPP) THEN BEGIN 
      IF N_ELEMENTS(BINS) NE MS.PY THEN BEGIN ; Check to see if the number of BINS in the D3 file are the same as the full map
        OK = WHERE(BINS EQ YP,COUNT)
        IF COUNT GT 1 THEN PRINT, 'CAUTION: More than one subscript found matching the LON/LAT values.  Returning only the first subscript.'
        IF COUNT EQ 0 THEN RETURN, []
        RETURN, REFORM(D3(XP[0],OK[0],*))
      ENDIF
    ENDIF
    IF XP LT 0 OR XP GT PX OR YP LT 0 OR YP GT PY THEN RETURN,[]
    RETURN,REFORM(D3(XP,YP,*))
  ENDIF;IF KEY(XP) AND KEY(YP) THEN BEGIN

;===> EXTRACT A 2-D IMAGE ARRAY FOR A DATE
  IF KEY(DATE) THEN BEGIN; 
    SEQ = WHERE(STRMID(PERIOD_2DATE(DB.PERIOD),0,8) EQ DATE,COUNT)
    IF COUNT EQ 0 THEN RETURN,[]
    IF COUNT EQ 1 THEN RETURN,D3(*,*,SEQ)
  ENDIF;IF KEY(DATE) THEN BEGIN

  RETURN,D3(*,*,*)
 
  DONE:          
END; #####################  END OF ROUTINE ################################

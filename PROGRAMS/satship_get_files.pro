; $ID:	SATSHIP_GET_FILES.PRO,	2020-06-30-17,	USER-KJWH	$

FUNCTION SATSHIP_GET_FILES, SATFILES, SHIPDATES=SHIPDATES, SHIP_STRUCT=SHIP_STRUCT, HOURS=HOURS, ERROR=ERROR, ERR_MSG=ERR_MSG

;+
; NAME:
;   SATSHIP_GET_FILES.PRO
;
; PURPOSE:
;   Look at dates of the ship stations and determine which L2 files should be looked at for valid data.  
;
; CATEGORY:
;   HDF Utilities
;
; CALLING SEQUENCE:
;
; INPUTS:
;   INFILES:   SEAWIFS, MODIS or other L1/l2 data netcdf file
;   SHIPDATES: Array of DATES for comparing with satellite times.  Dates (yyyymmdd) should include time (hhmmss) in GMT time.  If no time provided, then assume noon
;   HOURS:     Acceptable difference in time from the point in the SAT file from that in the SHIP RECORD
;   
; OPTIONAL INPUTS:
;   
;   GMT:       The GMT time difference for the given location 
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   This function returns a list of files to consider for SATSHIP_HDF_EXTRACT
;
; OPTIONAL OUTPUTS:
;   ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; PROCEDURE:
;     This is usually a description of the method, or any data manipulations
;
; EXAMPLES:
;     PIXS = SATSHIP_GET_FILES(SATFILES, SHIPFILE, HOURS=24, ERROR=ERROR, ERR_MSG=ERR_MSG)
;   
; NOTES:
;   This routine works for either single lat/lon points or arrays of lat[]/lon[]
;
;
; MODIFICATION HISTORY:
;     Written May 1, 2015 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov) 
;                                         Adapted from SD_HDF_SAT_SHIP
;     Modified:
;        Jul 24, 2015 - KJWH: Now looking for files that match up in time and space
;                             Can work with both PERIODS and SATDATES.  However, can only do the spatial search on .nc or .hdf satellite files with either GLOBAL or LON/LAT info 
;        Mar 18, 2016 - KJWH: Changed DATATYPE to IDLTYPE
;-
; ****************************************************************************************************

  ROUTINE_NAME='SATSHIP_GET_FILES'
  ERROR = 0
  ERR_MSG = ''
  AS=DELIMITER(/ASTER)
  DASH=DELIMITER(/DASH)
  UL=DELIMITER(/UL)
  SL = PATH_SEP()
  DECIMAL_DAYS = FLOAT(HOURS) / 24.0    
  
  IF N_ELEMENTS(SATFILES)    LT 1 OR N_ELEMENTS(SHIPDATES) LT 1 THEN STOP
  IF N_ELEMENTS(SATFILES)    LT 1 THEN SATFILES     = DIALOG_PICKFILE(TITLE='Pick save files') 
  IF N_ELEMENTS(OVERWRITE)   NE 1 THEN _OVERWRITE    = 0               ELSE _OVERWRITE = OVERWRITE
  IF N_ELEMENTS(HOURS)       NE 1 THEN _HOURS        = 48.1            ELSE _HOURS = HOURS
  
  JDDIFF = _HOURS / 24.0
    
  FP = PARSE_IT(SATFILES)
  IF FP[0].FULLNAME EQ '' THEN BEGIN
    ERROR = 0
    ERR_MSG = 'No input files provided'
    PRINT, ERR_MSG
    RETURN, []
  ENDIF 
  
; ===> FIRST FIND FILES WITHIN THE SHIPDATES
  JDSHIP = DATE_2JD(SHIPDATES)
  JDSAT  = DATE_2JD(FP.DATE_START)
  OK     = WHERE_NEAREST(JDSHIP,JDSAT,NEAR=JDDIFF,COUNT,VALID=VALID,INVALID=INVALID)   
  IF COUNT EQ 0 THEN RETURN, []
  
  ALLFILES = SATFILES              ; Variable containing the list of all input files
  SATFILES = SATFILES(VALID)
  CHECKED_FILES = SATFILES         ; Variable containg the list of files within the shipdates that the coordinates have been checked
  
; ===> CHECK TO MAKE SURE THE SHIP_STRUCT IS A STRUCTURE, IF NOT, RETURN JUST THE DATE SELECTED SATFILES
  IF IDLTYPE(SHIP_STRUCT) NE 'STRUCT' THEN RETURN, SATFILES
    
; ===> THEN FIND FILES WITH COORDINATES WITHIN THE SHIP COORDINATES
  SFILES = []
  FOR N=0, N_ELEMENTS(SATFILES)-1 DO BEGIN
    AFILE = SATFILES(N)
    REMOVE_FILE = []
    FA = FILE_PARSE(AFILE)
    DGLOBAL = REPLACE(FA.DIR,FA.SUB,'GLOBAL') & DIR_TEST, DGLOBAL
    JD_SAT = DATE_2JD(SATDATE_2DATE(FA.NAME))
    
    LX = WHERE(ABS(JDSHIP - JD_SAT) LE DECIMAL_DAYS, COUNT)  ; LX now contains the indices into *either* SHIP or LON,LAT which are in acceptable time range.
    IF COUNT EQ 0 THEN CONTINUE
    SHIP = SHIP_STRUCT(LX)  ; SHIP is now containing only the elements within the acceptable time range
    LON = FLOAT(SHIP.LON)
    LAT = FLOAT(SHIP.LAT)  
  
    DATA = []
    
    GLOBAL = DGLOBAL + FA.NAME_EXT + '-GLOBAL.SAV'
    
    IF FILE_MAKE(AFILE,GLOBAL) EQ 0 THEN DAT = IDL_RESTORE(GLOBAL) ELSE BEGIN
      IF H5F_IS_HDF5(AFILE) EQ 1 THEN DAT = READ_NC(AFILE,PRODS='GLOBAL')
      IF HDF_ISHDF(AFILE)   EQ 1 THEN DAT = READ_HDF_2STRUCT(AFILE,PRODUCTS='GLOBAL')
      SAVE, DAT, FILENAME=GLOBAL, /COMPRESS
    ENDELSE
      
    IF IDLTYPE(DATA) EQ 'STRING' THEN BEGIN
      PRINT, 'ERROR READING ' + AFILE
      STOP
      CONTINUE
    ENDIF
    
    IF HAS(DAT.GLOBAL,'NORTHERNMOST_LATITUDE') EQ 1 THEN BEGIN
      IF MIN(LAT) GT DAT.GLOBAL.NORTHERNMOST_LATITUDE THEN CONTINUE
      IF MAX(LAT) LT DAT.GLOBAL.SOUTHERNMOST_LATITUDE THEN CONTINUE
      IF MIN(LON) LT DAT.GLOBAL.WESTERNMOST_LONGITUDE THEN CONTINUE
      IF MAX(LON) GT DAT.GLOBAL.EASTERNMOST_LONGITUDE THEN CONTINUE      
      SFILES = [SFILES,AFILE]
      CONTINUE
    ENDIF
    
; ===> If min and max coordinates not provided in GLOBAL, then read the latitude and longitude products    
    IF H5F_IS_HDF5(AFILE) EQ 1 THEN DATA = READ_NC(AFILE,PRODS=['latitude','longitude'])
    IF HDF_ISHDF(AFILE)   EQ 1 THEN DATA = READ_HDF_2STRUCT(AFILE,PRODUCTS=['latitude','longitude'])
    
    DT = SATSHIP_GET_LONLAT_SUB(LON,LAT,LONGITUDE=DATA.SD.LONGITUDE,LATITUDE=DATA.SD.LATITUDE, ERROR=ERROR, ERR_MSG=ERR_MSG)
    IF IDLTYPE(DATA) EQ 'STRING' THEN BEGIN
      PRINT, 'ERROR READING ' + AFILE
      STOP
      CONTINUE
    ENDIF
    SFILES = [SFILES,AFILE]    
  ENDFOR  
  RETURN, SFILES

END

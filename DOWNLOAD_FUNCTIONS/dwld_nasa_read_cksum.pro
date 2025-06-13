; $ID:	DWLD_NASA_READ_CKSUM.PRO,	2023-09-21-13,	USER-KJWH	$
  FUNCTION DWLD_NASA_READ_CKSUM, DATASET, DATERANGE=DATERANGE, UPDATE=UPDATE, LOGFILE=LOGFILE, LOGLUN=LOGLUN, OVERWRITE=OVERWRITE

;+
; NAME:
;   DWLD_NASA_READ_CKSUM
;
; PURPOSE:
;   To read (and update) the master CHECKSUM file for L1A/L2 files downloaded from NASA's OBPG
;
; CATEGORY:
;   DOWNLOAD FUNCTIONS
;
; CALLING SEQUENCE:
;   Result = DWLD_NASA_READ_CKSUM(DATASET)
;
; REQUIRED INPUTS:
;   DATASET.......... Either the name of the dataset 
;
; OPTIONAL INPUTS:
;   DATERANGE........ A specified daterange (default = SENSOR_DATES(DATASET)
;   LOGLUN........... The LUN for the log file
;   LOGFILE.......... The name of the log file
;
; KEYWORD PARAMETERS:
;   UPDATE........... Look for new NC files and update the CHECKSUM table
;   OVERWRITE........ Replace an existing file
;
; OUTPUTS:
;   RESULT.......... The checksum information in a structure
;
; OPTIONAL OUTPUTS:
;   An updated CHECKSUM master file
;
; COMMON BLOCKS: 
;   None
;
; SIDE EFFECTS:  
;   None
;
; RESTRICTIONS:  
;   None
;
; EXAMPLE:
; 
;
; NOTES:
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2020, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on December 15, 2020 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Dec 15, 2020 - KJWH: Initial code written
;   Apr 08, 2021 - KJWH: Updated to add the MODIS SST 11UM "dataset"
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DWLD_NASA_READ_CKSUM'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  IF N_ELEMENTS(LOGLUN) EQ 1 THEN LUN=LOGLUN ELSE LUN = []
  
  IF N_ELEMENTS(DATASET) NE 1 THEN MESSAGE, 'ERROR: A single DATASET must be provided.'
  CKSUM_MASTER = CREATE_STRUCT('LOCAL_FILES','','LOCAL_CKSUM','','LOCAL_MTIME',0LL)  
  
  TYPE='L1A'
  PROD = ''
  CASE DATASET OF
    'SEAWIFS':    DATDIR=!S.SEAWIFS 
    'MODISA':     DATDIR=!S.MODISA
    'MODISA_CHL': BEGIN & DATDIR=!S.MODISA & SENSOR='MODISA' & TYPE='L3B4' & PROD='CHL' & PAT='L3b.DAY.'+PROD+'*' & END
    'MODISA_PAR': BEGIN & DATDIR=!S.MODISA & SENSOR='MODISA' & TYPE='L3B4' & PROD='PAR' & PAT='L3b.DAY.'+PROD+'*' & END
    'MODISA_RRS': BEGIN & DATDIR=!S.MODISA & SENSOR='MODISA' & TYPE='L3B4' & PROD='PAR' & PAT='L3b.DAY.'+PROD+'*' & END
    'SEAWIFS_CHL': BEGIN & DATDIR=!S.SEAWIFS & SENSOR='SEAWIFS' & TYPE='L3B9' & PROD='CHL' & PAT='L3b.DAY.'+PROD+'*' & END
    'SEAWIFS_PAR': BEGIN & DATDIR=!S.SEAWIFS & SENSOR='SEAWIFS' & TYPE='L3B9' & PROD='PAR' & PAT='L3b.DAY.'+PROD+'*' & END
    'SEAWIFS_RRS': BEGIN & DATDIR=!S.SEAWIFS & SENSOR='SEAWIFS' & TYPE='L3B9' & PROD='RRS' & PAT='L3b.DAY.'+PROD+'*' & END
    'MODIST':      BEGIN & DATDIR=!S.MODIST                     & TYPE='L2' & END
    'SMODISA':     BEGIN & DATDIR=!S.MODISA & SENSOR='MODISA' & TYPE='L2' & OLIST = 'SMODISA'     & PAT='L2.SST.nc' & END
    'SMODISA_NRT': BEGIN & DATDIR=!S.MODISA & SENSOR='MODISA' & TYPE='L2' & OLIST = 'SMODISA_NRT' & PAT='L2.SST.NRT.nc' & END
    'SMODIST':     BEGIN & DATDIR=!S.MODIST & SENSOR='MODIST' & TYPE='L2' & OLIST = 'SMODIST'     & PAT='L2.SST.nc' & END
    'SMODIST_NRT': BEGIN & DATDIR=!S.MODIST & SENSOR='MODIST' & TYPE='L2' & OLIST = 'SMODIST_NRT' & PAT='L2.SST.NRT.nc' & END
    'VIIRS':      DATDIR=!S.VIIRS
    'JPSS1':      DATDIR=!S.JPSS1
    ELSE: MESSAGE, 'ERROR: ' + DATASET + 'is not a recognized DATASET.'
  ENDCASE
  
  FILEDIR = DATDIR+SL+TYPE+SL+'NC'+SL+ PROD + SL & FILEDIR = REPLACE(FILEDIR,SL+SL,SL)
  CKDIR   = DATDIR+SL+TYPE+SL+'CHECKSUMS'+SL + PROD + SL & CKDIR = REPLACE(CKDIR,SL+SL,SL) & DIR_TEST, CKDIR
  FILES = FILE_SEARCH(FILEDIR+'*.*',COUNT=NFILES) 
  IF NFILES EQ 0 THEN RETURN, []
  FP = FILE_PARSE(FILES)
  
  CKSUM_FILE = DATDIR+SL+TYPE+SL+'CHECKSUMS.sav' 
  UPDATE_CKSUM = 0
  IF FILE_TEST(CKSUM_FILE) THEN BEGIN
    PLUN, LUN, 'Reading checksum file...'
    CKSUM = IDL_RESTORE(CKSUM_FILE) 
    OK = WHERE(FILE_TEST(FILEDIR+CKSUM.LOCAL_FILES) EQ 1, COUNT, COMPLEMENT=COMPLEMENT, NCOMPLEMENT=NCOMPLEMENT)
    IF NCOMPLEMENT GT 1 THEN BEGIN
      PLUN, LUN, 'Found ' + ROUNDS(NCOMPLEMENT) + ' entries in the CHECKSUM master that do not exist.'
      FOR I=0, NCOMPLEMENT-1 DO PLUN, LUN, 'Removing ' + CKSUM[COMPLEMENT[I]].LOCAL_FILES + ' from the CHECKSUM master.',0
      CKSUM = CKSUM[OK]
      UPDATE_CKSUM = 1
    ENDIF
    IF COUNT EQ 0 THEN GOTO, RESTART_CHECKSUM    
    OK = WHERE_MATCH(CKSUM.LOCAL_FILES,FP.NAME_EXT,COUNT,VALID=VALID,COMPLEMENT=COMPLEMENT,NCOMPLEMENT=NCOMPLEMENT,INVALID=INVALID,NINVALID=NINVALID)
    IF NINVALID GT 0 THEN BEGIN
      PLUN, LUN, 'Found ' + ROUNDS(NINVALID) + ' files that need to be added to the master file.'
      CKNEW = REPLICATE(CKSUM_MASTER,NINVALID)
      CKNEW.LOCAL_FILES = FP[INVALID].NAME_EXT
      CKSUM = [CKSUM, CKNEW]
      UPDATE_CKSUM = 1
    ENDIF  
  ENDIF ELSE BEGIN
    RESTART_CHECKSUM:
    CKSUM = REPLICATE(CKSUM_MASTER,NFILES)
    CKSUM.LOCAL_FILES = FP.NAME_EXT
    UPDATE_CKSUM = 1
  ENDELSE
  
  OK_FILE = WHERE(FILE_TEST(FILEDIR+CKSUM.LOCAL_FILES) EQ 0,COUNT_MISSING,COMPLEMENT=COMPLEMENT)  ; Look for files in the MASTER CHEKCSUMS list that do not exist in the DIR
  IF COUNT_MISSING GE 1 THEN BEGIN
    CKSUM = CKSUM[COMPLEMENT]                                                                     ; Remove missing files from the MASTER CHECKSUMS list
    UPDATE_CKSUM = 1
  ENDIF
  
  OK = WHERE(CKSUM.LOCAL_CKSUM EQ '',COUNT)
  IF COUNT GT 0 THEN BEGIN
    CKSUM[OK].LOCAL_CKSUM = GET_CHECKSUMS(FILEDIR+CKSUM[OK].LOCAL_FILES,MD5CKSUM=MD5CKSUM,/VERBOSE,LOGLUN=LUN)
    UPDATE_CKSUM = 1
  ENDIF
  
  OK = WHERE(CKSUM.LOCAL_MTIME EQ 0,COUNT)
  IF COUNT GT 0 THEN BEGIN
    CKSUM[OK].LOCAL_MTIME = GET_MTIME(FILEDIR+CKSUM[OK].LOCAL_FILES)
    UPDATE_CKSUM = 1
  ENDIF
  
  IF UPDATE_CKSUM EQ 1 THEN BEGIN  
    IF EXISTS(CKSUM_FILE) THEN FILE_MOVE,CKSUM_FILE,CKDIR+'CHECKSUMS-REPLACED_'+DATE_NOW()+'.sav' 
    SAVE, CKSUM, FILENAME=CKSUM_FILE
  ENDIF  
  RETURN, CKSUM
    
END ; ***************** End of DWLD_NASA_READ_CKSUM *****************

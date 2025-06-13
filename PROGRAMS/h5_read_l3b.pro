; $ID:	H5_READ_L3B.PRO,	2016-08-25,	USER-KJWH	$
;###################################################################################
FUNCTION H5_READ_L3B, FILE, PROD, BINS=BINS, NOBS=NOBS, NROWS=NROWS

;+NAME/ONE LINE DESCRIPTION OF ROUTINE:
;    H5_READ_L3B READS A SPECIFIC PRODUCT FROM A SEADAS GENERATED BINNED HDF5 FILE
;
;  NAME:
;    H5_READ_L3B
;
;  PURPOSE:
;    SIMPLIFIES THE READING OF STANDARD L3 BIN FILE. RETURNS MEAN BIN VALUES FOR A SPECIFIED PRODUCT.
;
;  CALLING SEQUENCE:
;    DATA = READ_L3BIN_NC(FILENAME,PROD)
;
;  INPUT:
;    FILE - L3BIN FILENAME STRING.
;    PROD - L3 SDS PRODUCT NAME STRING. IF THIS ENDS IN '_', ALL SDS PRODUCTS OF NAME PROD_NNN (WHERE NNN IS WAVELENGTH) WILL BE RETURNED.
;
;    KEYWORDS:           
;
;  OUTPUT:
;    DATA - 1-DIMENSIONAL ARRAY CONTAINING THE REQUESTED PRODUCT.
;   
;  OPTIONAL OUTPUT:
;    BINS  - 
;    NOBS  - 
;    NROWS -
;     
;  SUBROUTINES CALLED:
;    
;  WRITTEN BY:
;    J. GALES, FUTURETECH CORP..
;    B. A. FRANZ, SAIC GENERAL SCIENCES CORP..
;    FEBRUARY 2000.
;
; MODIFICATION HISTORY:
;       OCT 29, 2002 - JOEL GALES <JOEL@SHERPA.DOMAIN.SDPS>
;       APR 03, 2009 - JOEL GALES <JOEL@SHERPA.DOMAIN.SDPS>   - ADD SUPPORT FOR QUALITY FIELD
;       FEB 3, 2015 - JOR: MINOR FORMATTING CHANGES [UPPER CASE WHERE FEASIBLE FOR LEGIBILITY]
;                          NOTE: CALLS TO READ_HDF5 ARE HIGHLY CASE SENSITIVE: 
;                            E.G. binlist = read_hdf5(file, 'BinList', group='level-3_binned_data')
;       SEP 16, 2015 - KJWH: Removed STRLOWCASE(PROD) because not all L3 prods (e.g. Kd_490) are lowercase in the file
;       OCT 01, 2015 -  JOR: Added GONE,BININDEX,BINLIST,BINLIST,VAL to save memory space     
;       NOV 23, 2015 - KJWH: Changed name to READ_L3BIN_NC to be consistent with our other READ_xxx programs        
;                            Removed BIN2LL call and LON, LAT keywords because they not used
;                            Removed BEG, EXTENT, NSCENES, SUM, SUM2, QUAL, and VERBOSE keywords
;       AUG 25, 2016 - KJWH: Changed the file name to H5_READ_L3B to be consistent with the other H5_xxx programs                     
;
;
;###############################################################################################3
;-
;*****************************
ROUTINE_NAME = 'H5_READ_L3B'
;*****************************
IF NONE(PROD) THEN MESSAGE,'ERROR: PROD IS REQUIRED'
;===> ENSURE PROD IS LOWER CASE
; PROD = STRLOWCASE(PROD) - Error with the Kd_490 product

;===> CAREFUL-CASE SENSITIVE >
  BININDEX = READ_HDF5(FILE, 'BinIndex', GROUP='level-3_binned_data')
  BEG = BININDEX._BEGIN
  EXTENT = BININDEX.EXTENT
  START = BININDEX.START_NUM
  MX = BININDEX.MAX
  NROWS = N_ELEMENTS(BININDEX)
  GONE,BININDEX
;===> CAREFUL-CASE SENSITIVE >
  BINLIST = READ_HDF5(FILE, 'BinList', GROUP='level-3_binned_data')
  BINS = BINLIST.BIN_NUM
  NOBS = BINLIST.NOBS
  WTS = BINLIST.WEIGHTS
  NSCENES = BINLIST.NSCENES
  GONE,BINLIST
  N = LONG(TOTAL(DOUBLE(NOBS NE 0)))
  IF KEY(VERBOSE) THEN PRINT,'# OF NON-ZERO BINS:', N

  BINS    = BINS[0:N-1]
  NOBS    = NOBS[0:N-1]
  WTS     = WTS[0:N-1]
  NSCENES = NSCENES[0:N-1]

  IF (PROD EQ '') THEN BEGIN
    DATA = -1
    GOTO, SKIP
  ENDIF;IF (PROD EQ '') THEN BEGIN
    
;===> CAREFUL-CASE SENSITIVE >
  VAL = READ_HDF5(FILE, PROD, GROUP='level-3_binned_data')

  SUM = VAL.SUM
  SUM = SUM[0:N-1]
  SUM2 = VAL.SUM_SQUARED
  SUM2 = SUM2[0:N-1]

  DATA = SUM/WTS
  GONE,VAL
  SKIP:

  RETURN, DATA
END

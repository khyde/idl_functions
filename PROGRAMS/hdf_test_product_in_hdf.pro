; $Id:	hdf_test_product_in_hdf.pro,	April 05 2011	$
FUNCTION HDF_TEST_PRODUCT_IN_HDF, AFILE, PRODUCT,QUIET=QUIET
;+
; NAME:
;   HDF_TEST_PRODUCT_IN_HDF
;
; PURPOSE:
;
;   Tests for existence of PRODUCT in AFILE
;   
; CATEGORY:
;   Utilities
;
; CALLING SEQUENCE:
;   HDF_TEST_PRODUCT_IN_HDF(AFILE, PRODUCT)
;
; INPUTS:
;   AFILE:  AFILE is an HDF file containing the products
;   PRODUCT: String name of a product
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   Returns 0 if error, or product is not found.
;   Returns HDF Scientific Dataset index if product is found.
;
; OPTIONAL OUTPUTS:
;
; PROCEDURE:
;
; EXAMPLE:
;   IF HDF_TEST_PRODUCT_IN_HDF('my.hdf','product_a') then $
;     print, 'product_a found in hdf file' $
;   ELSE $
;     PRINT, 'product_a not found in hdf file'
;
; NOTES:
;
; MODIFICATION HISTORY:
;     Written Mar 28, 2011 by D.W.Moonan, 28 Tarzwell Drive, NMFS, NOAA 02882 (daniel.moonan@noaa.gov)
;-
  ROUTINE_NAME='HDF_TEST_PRODUCT_IN_HDF'
  ERROR = ''
  IF N_ELEMENTS(AFILE) EQ 0 THEN BEGIN
    PRINT,'ERROR: FILE MUST BE SPECIFIED'
    RETURN, 0
  END
  IF N_ELEMENTS(PRODUCT) EQ 0 THEN BEGIN
    PRINT,'ERROR: PRODUCT MUST BE SPECIFIED'
    RETURN, 0
  END
  IF FILE_TEST(AFILE) EQ 0 THEN BEGIN
    PRINT,'FILE DOES NOT EXIST:' + AFILE
    RETURN, 0
  END 
  IF HDF_ISHDF(AFILE) NE 1 THEN BEGIN
    PRINT, ROUTINE_NAME, AFILE, ' IS NOT AN HDF FILE'
    RETURN, 0
  END

  ID=HDF_SD_START(AFILE,/RDWR)
  PIDX = HDF_SD_NAMETOINDEX(ID,PRODUCT)
  HDF_SD_END, ID   ; don't forget this!

  IF PIDX EQ -1 THEN BEGIN
    IF NOT KEYWORD_SET(QUIET) THEN PRINT, 'PRODUCT: ' + PRODUCT + ' NOT FOUND IN FILE: ' + AFILE
    RETURN, 0
  END

  IF NOT KEYWORD_SET(QUIET) THEN PRINT, 'PRODUCT: ' + PRODUCT + ' FOUND IN FILE: ' + AFILE
  IF NOT KEYWORD_SET(QUIET) THEN PRINT, 'INDEX : ' + string(PIDX)
  
  RETURN, PIDX 

END

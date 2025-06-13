; $Id:	hdf_overwrite_product.pro,	April 06 2011	$
PRO HDF_OVERWRITE_PRODUCT, AFILE, DATA, PRODUCT, DATASTRUCT, QUIET=QUIET
;+
; NAME:
;   HDF_OVERWRITE_PRODUCT
;
; PURPOSE:
;   If product exists in the specified HDF file, it's data and attributes will be overwritten.
;   
; CATEGORY:
; 
;   Utilities
;
; CALLING SEQUENCE:
;
; INPUTS:
;   AFILE: HDF file in which the product resides
;   PRODUCT: String name of the product to overwrite
;   DATA: The array of the data which will overwrite the existing data
;   DATASTRUCT: A structure containing the attributes of the SDS variable being overwritten.
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   This function returns 0 if successful, 1 otherwise.
;
; OPTIONAL OUTPUTS:
;
; SIDE EFFECTS:  HDF file data will be overwritten/modified.
; RESTRICTIONS:  Overwritten data must be the same size of the input data
;
; PROCEDURE:
;
; EXAMPLE:
;   STRUCT = READ_HDF_2STRUCT('my.hdf',ERROR=ERROR,ERR_MSG=ERR_MSG, PRODUCTS=['chlor_a'])
;   A_PRODUCT= STRUCT.SD.CHLOR_A * 1000.0
;   RESULT = HDF_OVERWRITE_PRODUCT('my.hdf', 'a_product', A_PRODUCT.IMAGE, A_PRODUCT)
;   
; NOTES:
;   We need the caller to provide the data array argument, since we don't want to search
;   the structure for the data, and the caller will know already where the data is.
;   
; MODIFICATION HISTORY:
;     Written Jan 1, 2011 by D.W.Moonan, 28 Tarzwell Drive, NMFS, NOAA 02882 (daniel.moonan@noaa.gov)
;-
; ****************************************************************************************************

  IF HDF_TEST_PRODUCT_IN_HDF(AFILE, PRODUCT, QUIET=QUIET) EQ 0 THEN BEGIN
    PRINT, 'ERROR: ' + PRODUCT + ' does not exist in HDF, can not overwrite'
    ERROR = 1
    ERR_MSG = PRODUCT + ' does not exist in HDF, can not overwrite'
    GOTO, DONE
  ENDIF
  ID=HDF_SD_START(AFILE,/RDWR)
  SDID=HDF_SD_SELECT(ID,HDF_SD_NAMETOINDEX(ID,PRODUCT))
  HDF_SD_ADDDATA,SDID,DATA ; Actually overwrite the data
  TNAMES=TAG_NAMES(DATASTRUCT)
  ; set all the attributes using the datastruct 
  FOR I = 2, N_ELEMENTS(TNAMES) - 1 DO BEGIN
    HDF_SD_ATTRSET, SDID, TNAMES(I), DATASTRUCT.(I)
  ENDFOR
  HDF_SD_END,ID
  IF NOT KEYWORD_SET(QUIET) THEN PRINT,'Succesfully overwrote ' + PRODUCT + ' in HDF file : ' + AFILE
  
  DONE:
END

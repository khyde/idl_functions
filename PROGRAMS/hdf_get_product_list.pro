; $Id:	hdf_get_product_list.pro,	April 05 2011	$
FUNCTION HDF_GET_PRODUCT_LIST, AFILE, QUIET=QUIET, ERROR=ERROR, ERR_MSG=ERR_MSG
;+
; NAME:
;   HDF_GET_PRODUCT_LIST
;
; PURPOSE:
;   Determine what products exist in a specified HDF file
; CATEGORY:
;   Utilities
;
; CALLING SEQUENCE:
;   HDF_GET_PRODUCT_LIST, AFILE
;
; INPUTS:
;   Parm1:  AFILE is an HDF file containing the products
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   Returns list of products found in AFILE
;
; OPTIONAL OUTPUTS:
;
; PROCEDURE:
;
; EXAMPLE:
; 
;   my_product_list = HDF_GET_PRODUCT_LIST('my.hdf') 
;
; NOTES:
;
; MODIFICATION HISTORY:
;     Written Mar 28, 2011 by D.W.Moonan, 28 Tarzwell Drive, NMFS, NOAA 02882 (daniel.moonan@noaa.gov)
;-
; ****************************************************************************************************
  ERROR = 0

  ; ===> Ensure that the file is an HDF file
  IF HDF_ISHDF(AFILE) NE 1 THEN BEGIN
    ERROR=1 & ERR_MSG = AFILE+ ' is not an HDF File'
    RETURN, -1
  ENDIF

  ; ===> Open the HDF file for reading only
  file_id=HDF_OPEN(AFILE,/READ)

  ; ===> Get the Scientific Dataset ID from the HDF file
  sd_id=HDF_SD_START(AFILE)

  ; ===> Get Number of Scientific Data Sets and Number of GLOBAL Attributes
  HDF_SD_FILEINFO,sd_id,NumSDS,n_global_attributes
  
  RESULT = []
  IF NUMSDS EQ 0 THEN sds_id = []
  FOR _NUMSDS = 0,NUMSDS-1L DO BEGIN
    sds_id=HDF_SD_SELECT(sd_id,_NUMSDS)
    HDF_SD_GETINFO,sds_id,NATTS=natts,NDIMS=NDIMS,LABEL=LABEL,DIMS=DIMS,TYPE=TYPE,NAME=name      
    RESULT = [RESULT, NAME]    
  ENDFOR
  
  IF sds_id NE [] THEN HDF_SD_ENDACCESS,sds_id ELSE BEGIN
    ERROR = 1
    ERR_MSG = 'Unable to determine the number of Scientific Data Sets for ' + AFILE
  ENDELSE  
  HDF_SD_END, sd_id
  HDF_CLOSE,file_id
  
  RETURN, RESULT

END

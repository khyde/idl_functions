; $ID:	HDF_ADD_PRODUCT.PRO,	2020-07-08-15,	USER-KJWH	$

FUNCTION HDF_DIMNAMES, AFILE, SAMPLEPRODUCT

; Comments: Must know the names of the dimensions for the hdf sds's in order to add data without adding another dimension variable
; Use sampleproduct as an example.  This needs to be done using a product that has the same dimensions as the one we are going to add.
  SAMPLE_PROD = SAMPLEPRODUCT[0] ; Be sure to use the sample product name derived directly from the original HDF and do not alter the case.
  
  ID=HDF_SD_START(AFILE) 
  SDI=HDF_SD_NAMETOINDEX(ID,SAMPLE_PROD)
  SDII=HDF_SD_SELECT(ID,SDI)
  DIMID1=HDF_SD_DIMGETID(SDII,0)
  DIMID2=HDF_SD_DIMGETID(SDII,1)
  HDF_SD_DIMGET,DIMID1,NAME=DN1
  HDF_SD_DIMGET,DIMID2,NAME=DN2
  HDF_SD_END,ID
  DIMNAMES=[DN1,DN2]
  RETURN, DIMNAMES
 
END


PRO HDF_ADD_PRODUCT, AFILE, DATA, SD_NAME, DATASTRUCT, SAMPLEPRODUCT, QUIET=QUIET,ERROR=ERROR, ERR_MSG=ERR_MSG
;+
; NAME:
;   TEMPLATE
;
; PURPOSE:
;   Take data and insert into an HDF file
;
; CATEGORY:
;   Utilities
;
; CALLING SEQUENCE:
;   HDF_ADD_PRODUCT(FILE, DATA, DATASTRUCT, SD_NAME, SAMPLEPRODUCT)
;   
; INPUTS:
;   FILE: HDF file
;   DATA: typically the 'image' array
;   DATASTRUCT: The structure containing the attribute information to create for the new variable
;   SD_NAME: The string name of the NEW scientific data set (SDS) variable.
;   SAMPLEPRODUCT: A string containing the name of an SDS which is already in the HDF (e.g. 'chlor_a')
;    
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;   This function returns 1 if successful, or 0 if a failure occurs.
;
; OPTIONAL OUTPUTS:
;
; SIDE EFFECTS:  Modifies the HDF file, increasing its size, adding a new SDS.
; 
; PROCEDURE:
;   Check to see if HDF file exists and is an HDF file.
;   Open the HDF file and create a new SDS with name SD_NAME
;   Determine the dimension names based on SAMPLEPRODUCT
;   Add the data contained in DATA to the new SDS
;   create and populate the attributes of the new SDS from the structure DATASTRUCT
;   Find the 'Geophysical Data' VGROUP and add the new SDS id to it.
;   Close the file and return 1 if successful.
;   
; EXAMPLE:
;   HDF_ADD_PRODUCT(FILENAME, data_array, structure_with_attributes, string_sds_name, example_existing_product_string_name) 
;
; NOTES:
;   We need an example existing SDS which is already in the HDF file, in order to determine
;   the names of the dimensions.  Otherwise, the new SDS will be created with dummy dimensions.
;   The number of attributes is arbitrary.
;   The data_array is also passed as part of the datastruct, and could be used instead of DATA,
;   but would be more complicated since the name of the structure element with data in it is
;   indeterminate.
;   
; REFERENCES:
;   This code based in part on SeaDAS 6.2 idl_lib program 'wr_swf_hdf_sd.pro'
;
; MODIFICATION HISTORY:
;     Written Mar 28, 2011 by D.W.Moonan, 28 Tarzwell Drive, NMFS, NOAA 02882 (daniel.moonan@noaa.gov)
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'HDF_ADD_PRODUCT'
  PNAME = '[HDF_ADD_PRODUCT] - '
  null = ''
  ERROR = 0
  ERR_MSG = NULL
  
  ON_IOERROR, IOERROR
  
  IF (AFILE EQ NULL) THEN BEGIN
    PRINT,pname,'HDF file is null'
    ERROR = 1
    ERR_MSG = 'No input file'
    GOTO, DONE
  ENDIF
  
  IF FILE_TEST(AFILE) EQ 0  THEN BEGIN
    PRINT,' FILE ' + AFILE + ' does not exist'
    ERROR = 1
    ERR_MSG = AFILE + ' does not exist'
    GOTO, DONE
  ENDIF

  DIMS = SIZE(DATA, /DIMENSIONS)
  DTYPE = SIZE(DATA,/TYPE)
  
  IF HDF_ISHDF(AFILE) NE 1 THEN BEGIN
    PRINT, PNAME, AFILE, ' is not an HDF file'
    ERROR = 1
    ERR_MSG = AFILE + ' is not an HDF'
    GOTO, DONE
  END
  
  ; This should be done prior to calling HDF_ADD_PRODUCT, but double check
  IF HDF_TEST_PRODUCT_IN_HDF(AFILE,SD_NAME,QUIET=QUIET) NE 0 THEN BEGIN
    IF NOT KEYWORD_SET(QUIET) THEN PRINT, PNAME + ' Product already exists in : ' + AFILE    
    ERROR = 1
    ERR_MSG = PNAME + ' already exists in ' + AFILE
    GOTO, DONE
  END

  ;dims=['Number of Scan Lines', 'Pixels per Scan Line']
  DNAMES=HDF_DIMNAMES(AFILE,SAMPLEPRODUCT)   ; get dim names from an existing product

  OFID = HDF_OPEN(AFILE, /RDWR)
  OSDFID = HDF_SD_START(AFILE, /RDWR) 
  
  HDFTYPE = HDF_IDL2HDFTYPE(DTYPE)
  IF HDFTYPE EQ 0 THEN BEGIN
    PRINT,'IDL data type was not mappable to HDF data type for DATA'
    ERROR = 1
    ERR_MSG = 'Data type is not mappable to HDF'
    HDF_SD_END, OSDFID 
    HDF_CLOSE, OFID
    GOTO, DONE
  ENDIF
  SDS_ID = HDF_SD_CREATE(OSDFID, SD_NAME, DIMS, HDF_TYPE=HDFTYPE)

  ; For this purpose, there are only two dimensions for now.
  ; The names of the dimensions need to be set every time a new product is added, or HDF will create a new "FAKEDIMx"
  ; The dimensions should be (Number of Scan Lines, Pixels per Scan Line) - HDF4 will use the same SDS dimensions for the NEW SDS, only if the names match. 
  
  DIMID1=HDF_SD_DIMGETID(SDS_ID,0)           ; new dimension id's
  DIMID2=HDF_SD_DIMGETID(SDS_ID,1)
    
  HDF_SD_DIMSET,DIMID1,NAME=DNAMES[0]        ; set the dims for the new sds to the same name as existing ones
  HDF_SD_DIMSET,DIMID2,NAME=DNAMES[1]         
  HDF_SD_ADDDATA, SDS_ID, DATA               ; add the data and no "dummy dimensions" will be created
  TNAMES=TAG_NAMES(DATASTRUCT)               ; get the attributes from the datastruct variable
  
  FOR I = 0, N_ELEMENTS(TNAMES) - 1 DO BEGIN ; set all the attributes using the datastruct 
    HDF_SD_ATTRSET, SDS_ID, TNAMES(I), DATASTRUCT.(I)
  ENDFOR

; *** Add the new SDS to the vgroup 'Geophysical Data' ***
  DFTAG_VG = 1965
  NVGPS = HDF_NUMBER(OFID, TAG=DFTAG_VG)
  IF (NVGPS GT 0) THEN BEGIN
    VREF = -1
    FOR I=1, NVGPS DO BEGIN
      VREF = HDF_VG_GETID(OFID, VREF)
      OVID = HDF_VG_ATTACH(OFID, VREF, /READ, /WRITE)
      HDF_VG_GETINFO, OVID, NAME=VGNAME, NENTRIES=NENTRIES, CLASS=CLASS_NAME
      IF (VGNAME EQ 'Geophysical Data') THEN BEGIN
        SDSREF = HDF_SD_IDTOREF(SDS_ID)
        TAG = 720                ; DFTAG_NDG
        HDF_VG_ADDTR, OVID, TAG, SDSREF
        HDF_VG_DETACH, OVID
        GOTO, CONTINUE1
      ENDIF
      HDF_VG_DETACH, OVID
    ENDFOR
  CONTINUE1:
  ENDIF
     
  HDF_SD_ENDACCESS, SDS_ID    ; Close HDF access
  HDF_SD_END, OSDFID 
  HDF_CLOSE, OFID
          
  IF NOT KEYWORD_SET(QUIET) THEN PRINT, PNAME, 'Added SD "', SD_NAME, '" to file ', AFILE, '.'
  GOTO, DONE
    
  IOERROR: 
  ERROR = 1
  ERROR_MSG = !ERROR_STATE.MSG
  PRINT, PNAME, 'Error writing SD to file ', AFILE  
  
  DONE:

END


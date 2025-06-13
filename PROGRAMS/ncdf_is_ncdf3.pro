;-----------------------------------------------
; Copyright (c) 2002-2016, Exelis Visual Information Solutions, Inc. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; NAME:
;   NCDF_IS_NCDF
;
; PURPOSE:
;   This function determines if a file (or files) is NetCDF-3 format.
;
;   This function is modeled after the H5F_IS_HDF5 and HDF_ISHDF functions.
;
; SYNTAX:
;
;   Result = NCDF_IS_NCDF(filenames)
;
; RETURN VALUE:
;   NCDF_IS_NCDF returns 1 (true) if the file exists and is NetCDF-3 format,
;   0 (false) otherwise. If the input argument is an array of filenames, then
;   an array of 1 or 0 values will be returned.
;
; INPUTS:
;
;   Filename (required): A string or array of strings containing the filename
;   to check.
;
;
; KEYWORD PARAMETERS:
;
;   None.
;
; MODIFICATION HISTORY:
;   Written by: Ben Foreback, Harris, February 2016
;

FUNCTION NCDF_IS_NCDF3, filenames
  COMPILE_OPT IDL2, HIDDEN

  ON_ERROR, 2

  nFiles = N_ELEMENTS(filenames)
  IF nFiles EQ 0 THEN BEGIN
    MESSAGE, 'Incorrect number of arguments.'
  ENDIF

  IF~ISA(filenames, /STRING) THEN BEGIN
    MESSAGE, 'Filename must be a string.'
  ENDIF

  ; Start with a FILE_TEST on all of the files; if a given file doesn't exist,
  ; then it is, of course, not a NetCDF file.
  isNCDF = FILE_TEST(filenames)

  ; Define a catch block in order to make absolute sure that the LUN will always
  ; be freed.
  CATCH, err
  IF (err NE 0) THEN BEGIN
    CATCH, /CANCEL
    IF (N_ELEMENTS(unit) GT 0) THEN BEGIN
      FREE_LUN, unit
    ENDIF
    MESSAGE, /REISSUE_LAST
  ENDIF

  ; To determine if the file is a NetCDF-3 file, check the first four bytes
  ; of the file. The first three bytes will be "CDF" and the fourth is either
  ; the byte value 1 or the byte value 2. This comes from the NetCDF FAQ page
  ; found at http://www.unidata.ucar.edu/software/netcdf/docs/faq.html under
  ; the section "How can I tell which format a netCDF file uses?" (site
  ; accessed 4 February 2016).
  header = BYTARR(4, /NOZERO)
  validCDFHeader1 = [67B, 68B, 70B, 1B]
  validCDFHeader2 = [67B, 68B, 70B, 2B]
  FOR i = 0, nFiles - 1 DO BEGIN
    IF ~isNCDF[i] THEN CONTINUE
    OPENR, unit, filenames[i], /GET_LUN
    READU, unit, header
    FREE_LUN, unit
    IF ~ARRAY_EQUAL(header, validCDFHeader1) && $
      ~ARRAY_EQUAL(header, validCDFHeader2) THEN isNCDF[i] = 0B
  ENDFOR

  RETURN, isNCDF

END
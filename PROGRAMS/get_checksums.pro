; $ID:	GET_CHECKSUMS.PRO,	2020-06-30-17,	USER-KJWH	$

  FUNCTION GET_CHECKSUMS, FILES, MD5CKSUM=MD5CKSUM, LOGLUN=LOGLUN, VERBOSE=VERBOSE

;+
; NAME:
;   GET_CHECKSUMS
;
; PURPOSE:
;   This function will get the checksum of existing files
;
; CATEGORY:
;   
;
; CALLING SEQUENCE:
;   CHKS = GET_CHECKSUMS(FILES)
;
; INPUTS:
;   FILES: List of files (with full directory name)
;
; OPTIONAL INPUTS:
;   
;
; KEYWORD PARAMETERS:
;   MD5CKSUM: Use MD5SUM instead of SHA1SUM for the checksum value
;
; OUTPUTS:
;   This function returns a structure with the original input filenames and the checksum values
;
; OPTIONAL OUTPUTS:
;   
;
; NOTES:
;   This routine uses SHA1SUM to get the checksum value.  Other types of checksums (e.g. md5) can be added if needed
;   
; MODIFICATION HISTORY:
;			Written:  Feb 12, 2016 by K.J.W. Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;			Modified: Feb 17, 2016 - KJWH: Remove ERROR string if no files are found, now return a null string for missing file checksums
;			          Mar 04, 2016 - KJWH: Removed the structure and now only returning the CHKSUMS
;			                               Fixed bug so that it works with a single file
;			          Mar 09, 2016 - KJWH: Added MD5CKSUM keyword and function     
;			          Dec 22, 2017 - KJWH: Added VERBOSE keyword and function  
;			          May 08, 2020 - KJWH: Changed the parameter name FLS to FILES to avoid a conflict with the function FLS              
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'GET_CHECKSUMS'
	
  IF NONE(FILES) THEN RETURN, 'ERROR: No input files provided'
  IF N_ELEMENTS(LOGLUN) EQ 1 THEN LUN = LOGLUN ELSE LUN = []
  
  CHKSUMS = REPLICATE('',N_ELEMENTS(FILES))
	OK = WHERE(FILE_TEST(FILES) NE 0,COUNT)
	IF COUNT GE 1 THEN BEGIN
	  FILES = FILES[OK]
	  CKS = CHKSUMS[OK]
	  FOR N=0, N_ELEMENTS(FILES)-1 DO BEGIN
	    IF KEY(VERBOSE) THEN PLUN, LUN, 'Checking file ' + FILES(N) + ' (' + NUM2STR(N) + ' of ' + NUM2STR(N_ELEMENTS(FILES)) + ')',0
	    IF KEY(MD5CKSUM) THEN SPAWN, 'md5sum '  + FILES(N), CKSUM $
	                     ELSE SPAWN, 'sha1sum ' + FILES(N), CKSUM
      IF CKSUM[0] EQ '' THEN CONTINUE
      SSP  = STRSPLIT(CKSUM,' ',/EXTRACT)
      CKS(N) = SSP[0]
	  ENDFOR 
	  CHKSUMS[OK] = CKS
	ENDIF 
	RETURN, CHKSUMS
	 
	


END; #####################  End of Routine ################################

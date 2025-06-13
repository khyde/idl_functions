; $ID:	GEB2DI6.PRO,	2020-07-08-15,	USER-KJWH	$
PRO GEB2DI6, GEBCO_FILES , DIR_OUT=dir_out
;+
; NAME:
;       GEB2DI6
;
; PURPOSE:
;       Generate a 'DI6' type file for use in plotting programs such
;       as the PLOTDEG.PRO (J.O'Reilly) program
;
; CATEGORY:
;       BATHYMETRY
;
; CALLING SEQUENCE:
;  1) PLACE THE GEBCO-97 CD-ROM in the cd reader
;  2) (RUN THIS PROGRAM)  e.g.  GEB2DI6,DIR_OUT='D:\IDL\GEBCO\'

;	 3) PICK A FILE FROM THE CD ROM (e.g. east coast to 46 deg N = Gebco508.asc or East Coast from 46 to 72 N = Gebco504.asc ) ASCII NOT BIN !
;
;
; INPUTS:
;   GEBCO-97 CD-ROM
;
; KEYWORD PARAMETERS:
;          NONE
; OUTPUTS:
;          A *.DI6 FILE
;          Where the number of elements in each line segment is written
;          followed by the lon,lat coordinates for the line segement.
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Jan, 1998, Written by:  J.E.O'Reilly,
;       Modified Aug 12,1998 (added documentation)
;				JOR, June 20, 2001  modified to deal with newest cd rom gebco format ascii files
;-


; =============>

	GEBCO_FILES = 'Z:\ASCII\GEB_CON\'+ ['Gebco508','Gebco504'] + '.ASC'


; If input file name not provided then pickfile
  IF N_ELEMENTS(GEBCO_FILES) EQ 0 THEN GEBCO_FILES = PICKFILE()
  CD,CURR=DIR
  IF N_ELEMENTS(DIR_OUT) NE 1 THEN DIR_OUT = 'D:\IDL\BATHY\GEBCO\'




;	LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
	FOR  _FILES = 0L,N_ELEMENTS(GEBCO_FILES)-1L DO BEGIN
	; ===> Define some variables
  	ATEXT = ' '
  	ICODE=''

	; =============>
	; Open the GEBCO ascii input file
		GEBCO_FILE = GEBCO_FILES(_FILES)
	  OPENR,lun_in, GEBCO_FILE,/GET_LUN
	  FN=PARSE_IT(GEBCO_FILE)
	  NAME = FN.FIRST_NAME


	; =============>
	; Read the entire file to determine how many different
	; isobaths are represented
	  PRINT,'Examining input file for isobaths'
	  WHILE NOT EOF(lun_in) DO BEGIN
	    READF,lun_in,atext
	    IF STRPOS(atext,'.') LT 0 THEN BEGIN
	       ACODE = STRTRIM(STRMID(ATEXT,0,6),2)
	       ICODE=[ICODE,ACODE]
	    ENDIF
	  ENDWHILE
	  CLOSE,lun_in
	  FREE_LUN,lun_in


	; ====================>
	; Close all open units
	  CLOSE,/ALL

	; ==================>
	; FIND VALID (non-blank) ISOBATHS
	  ok = WHERE(ICODE NE '',count)
	  IF count GE 1 THEN ICODE=ICODE(ok)

	; ===================>
	; Convert ICODE to long
	  ICODE = LONG(ICODE)

	; ==================>
	; Find unique ICODEs
	  ICODE = ICODE(UNIQ(ICODE, SORT(ICODE)))

	; ===================>
	; Convert ICODE back to string
	  ICODE = STRTRIM(STRING(ICODE),2)

	; ==================>
	; Create an array, parallel to ICODE
	; to indicate the unit to open for writing output
	  lunout  = 2+ INDGEN(n_elements(ICODE))

	; ==================>
	; Now open up all needed output ICODE files
	  PRINT,'Creating output ICODE files'
	  FOR nth = 0,N_ELEMENTS(ICODE)-1 DO BEGIN
	    OUTPUT = DIR_OUT+NAME+'_'+ICODE(nth)+'.DI6'
	    PRINT, OUTPUT
	    lun = lunout(nth)
	    OPENW, lun,output
	    PRINT, lun,output
	  ENDFOR


	; ===================>
	; Convert ICODE to long
	  ICODE = LONG(ICODE)

	; =============>
	; Open the GEBCO ascii input file (AGAIN)
	  OPENR,1, GEBCO_FILE

	  npts = -1L
	  lonlat = DBLARR(2,99999)

	  ACODE=0
	  NPTS =0
	  ALAT = 0.0
	  ALON = 0.0
	  WHILE NOT EOF[1] DO BEGIN
	    READF,1,ACODE,NPTS
	    LONLAT = FLTARR(2,NPTS)
	    FOR N=0L,NPTS-1 DO BEGIN
	      READF,1,ALAT,ALON,FORMAT='(F8.4,F10.4)' ; LAT FIRST
	      LONLAT(0,N) = ALON
	      LONLAT(1,N) = ALAT
	    ENDFOR

	;  Determine which file to write to
	   ok = WHERE(ICODE EQ ACODE)
	   lun_out = lunout(ok)
	   lun_out =  lun_out[0]
	   PRINTF,lun_out,NPTS,ACODE,FORMAT='(2I6)'
	   FOR I = 0,NPTS-1  DO BEGIN
	     PRINTF,lun_out,LONLAT(0,I),LONLAT(1,I),FORMAT='(2F10.6)'
	   ENDFOR
	  ENDWHILE
	  CLOSE,/ALL
	ENDFOR ; FILES

  PRINT, 'PROGRAM GEB2DI6 FINISHED'
END

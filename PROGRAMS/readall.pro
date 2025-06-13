; $ID:	READALL.PRO,	2020-07-08-15,	USER-KJWH	$

  FUNCTION READALL,   FILE, $                ; Input file
                      TYPE=type, $           ; Type of file/image
                      red=red,green=green,blue=blue,$          ; Palette data
                      HEAD=head,TAIL=tail,$  ; Additional image file data
                      PX=px,PY=py ,$         ; x,y, Dimensions of array
                      DEFAULT=default ,$     ; The image type if all else fails
                      QUIET=quiet,$
                      products=products,BINARY=binary,DATA=data,$ ; for hdf only
                      ERROR=error,$
                      _EXTRA=_extra


;+
; NAME:
;       READALL
;
; PURPOSE:
;       A general purpose program to unify various image reading programs
;       and to read idl 2-dimensional arrays
;
;       Reads in image files:
;                 PNG;
;                 JPEG,JPG;
;                 BMP;
;                ,PCX;
;                ;DSP (U.Miami DSP)
;                ;SEADAS Level 3 hdf integer files
;                ;NECW *rs7,*rd7 Coastwatch Files

;                ;IDL (SAVE) & RESTORE
;
;       and IDL 2-dimensional arrays:
;                ;BYT (A File containing only a  BYTE array);
;                ;INT (A File containing only an INTEGER array)
;                ;LON (A File containing only an LONG INTEGER array)
;                ;FLT (A File containing only an FLOAT   array)
;                ;DBL (A File containing only an DOUBLE  array)
;
;       and IDL OUTPUT from IMAGE_STATS1.pro
;                :HIS



; CATEGORY:
;       Image
;
; CALLING SEQUENCE:
;       Result = READALL(file)
;       Result = READALL(file,type=dsp)
;       Result = READALL(file,r=r,g=g,b=b,type=gif,)
;
; INPUTS:
;       A File, usually an image, and with implied 2 dimensions
;       Can also read other arrays such as BYTE, INTEGER, LONG, FLOAT, AND DOUBLE ARRAYS
;
; KEYWORD PARAMETERS:
;
;       TYPE:   type of file:  png,dsp,pcx,bmp,jpg, or BYT,INT,LON,FLT,DBL
;       For Image Files
;
;       DEFAULT: The default type of image when the extension is not as expected
;       red:   red palette (as in READ_png.PRO)
;       green:   green
;       blue:   blue
;
;
;
;      OPTIONAL for ARRAYS
;      PX:   X Size of array in pixels
;      PY:   Y Size of array in pixels
;
;
; OUTPUTS:
;       Returns a -1 if program can not read the file
;
;       An Array matching the type in the file
;       PX, PY  (x,y dimensions of the array)
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
;       Written by:  J.E.O'Reilly, Dec 1, 1996
;       Dec 29,1997  Added BYTE, INT, LON, DBL, FLT Capability
;       Jan 23, 1998  Added SEADAS level 3 hdf integer reading Capability
;       Feb 3, 1998   Added HIS  TYPE (image histogram output from IMAGE_STATS.PRO
;       Mar 6, 1998   Added LFF  TYPE (Long, float, float)
;       Nov 28,1998   Added ARR  TYPE (DATA ARE PRECEEDED BY LONG ARRAY FROM IDL SIZE FUNCTION
;       Dec 27,1999   Added IDL  TYPE (DATA SAVED USING IDL SAVE COMMAND AND VARIABLES SAVED AS 'SAVE')
;       Nov 1,2000    Added PNG  type and REMOVED GIF type
;       Nov 17, 2010  Changed to call FILE_PARSE instead of PARSE_IT, since only the .ext is needed.
;       Jan 23, 2014  Changed READ_CSV to READ_CSV_NAR to avoid conflict with IDL's version of READ_CSV

;-

	ERROR = 0
	ERR_MSG = []

; ====================>
; Set array to -1 and return -1 if no array can be opened
  array=(-1)

  first_attempt = 0

; ===================>
; Set r,g,b to -1
  red = -1 & green=-1 & blue=-1

; ====================>
; Set head and tail to -1
  head = -1 & tail = -1

; ====================>
; If file name not provided then use Pickfile to get a file
  IF N_ELEMENTS(FILE) EQ 0 THEN $
           FILE = DIALOG_PICKFILE(TITLE='Pick a File',$
           filter='*.idl;*.bmp;*.png;*.pcx;*.jpeg;*.jpg; *.dsp; *.dbf; *.byt;*.bin;*.int;*.lon;*.flt;*.dbl;*.his;*.axd;*.rs7;*.rd7;*.csv;*',$
           _EXTRA=_extra)


; ====================>
; If the TYPE of array not provided then try to determine the TYPE
; from the file extension
; Type should be a string atleast 2 char long

  IF N_ELEMENTS(TYPE) EQ 1 THEN BEGIN
    type_len = STRLEN(STRTRIM(STRING(TYPE),2))
  ENDIF ELSE BEGIN
    type_len = 0
  ENDELSE


  IF type_len LE 2 THEN BEGIN
    fname = FILE_PARSE(file[0])
    ext = STRUPCASE(fname.ext)
  ENDIF ELSE BEGIN
    ext = STRUPCASE(STRTRIM(type,2))
  ENDELSE


; ====================>
; Make type first 3 characters
  IF N_ELEMENTS(TYPE) NE 1 THEN type = STRUPCASE(STRMID(ext,0,3)) ELSE TYPE = STRUPCASE(STRMID(TYPE,0,3))


  AGAIN:
; ====================>
; Based on the Type use the Appropriate array Reading Program
; TODO: Candidate for CASE statement structure - DWM 02/18/2011
  IF type EQ 'PCX'  THEN READ_PCX, FILE, array, Red, Green, Blue
  IF type EQ 'BMP'  THEN array = READ_BMP(file,RED,GREEN,BLUE,HEAD)
  IF type EQ 'PNG'  THEN ARRAY = READ_PNG(file,Red,green,blue)
  IF type EQ 'GIF'  THEN READ_GIF, FILE, ARRAY,Red,green,blue
  IF type EQ 'JPEG' or type EQ 'JPG'  THEN BEGIN
    READ_JPEG,file,array,colors
    red=colors[*,0] & green=colors[*,1] & blue=colors[*,2]
  ENDIF

  IF type EQ 'DSP'  THEN READ_DSP,FILE=file,image=array,HEAD=head,TAIL=tail,$
                                  PX=px,PY=py,/ROTATE,/QUIET

  IF type EQ 'CSV'  THEN ARRAY = CSV_READ(FILE,_EXTRA=_extra)

  IF type EQ 'SAV'  THEN BEGIN
  	IF NOT KEYWORD_SET(DATA) THEN BEGIN
  		RETURN,IDL_RESTORE(FILE,ERROR=error)
  	ENDIF ELSE BEGIN
  		; FIGURE OUT WHETHER IS: BASIC , STATS, OR TS_IMAGES SAVE
  	ENDELSE
  ENDIF
  IF type EQ 'TXT'  THEN ARRAY = READ_TXT(FILE)

;	===> Read a 'MATLAB 5.0 MAT-file' and return an IDL structure
	IF type EQ 'MAT' THEN RETURN, READ_MATFILE(FILE)



; ==============>
; Get image dimensions if do not already have them
;  IF N_ELEMENTS(PX) EQ 0 OR N_ELEMENTS(PY) EQ 0 THEN BEGIN
;    sz = SIZE(array)
;    px = sz[1]
;    py = sz(2)

;  ENDIF

  IF type EQ 'HDF'  THEN BEGIN
;   ===============>
    BINARY = 1 ; DEFALT
    IF N_ELEMENTS(DATA) EQ 1 THEN BEGIN
     BINARY = 0
     DATA = 1
    ENDIF
;   Read a SEADAS INTEGER HDF CHL IMAGE

    SD = READ_HDF_2STRUCT(FILE,products=products)
    ARRAY = SD.(0).IMAGE

;   Get the dimensions of the image
    s = size(ARRAY)
    px = s[1] & py = s(2)

    ENDIF



; ====================>
; dBASE IV files
  IF type EQ 'DBF'  THEN array = READ_DB(file,quiet=quiet)

; IF a structure is present in the array then the READ_DB worked,
; and return the array
  IF IDLTYPE(array,/code) EQ 8 THEN RETURN, array


; ====================>
; ARR (IDL ARRAY TYPES WHERE A LONG ARRAY FROM IDL SIZE COMMAND PRECEEDS DATA
;      AND IS USED TO INSTRUCT HOW TO READ AND BUILD THE ARRAY FROM THE ARR FILE)
  IF type EQ 'ARR' THEN BEGIN
    ARRAY = READ_ARR(FILE)
  ENDIF

; ====================>
; AXD (IDL XDR ARR )
  IF type EQ 'AXD' THEN BEGIN
     ARRAY=READ_AXD(FILE)
  ENDIF

; ====================>
; NECW (Northeast Coast Watch *rs7,*rd7)
  IF type EQ 'NECW' or type eq 'RS7' or type EQ 'RD7' $
     or type EQ 'rcm' or type eq 'rc1' or type eq 'rc2' THEN BEGIN
     ARRAY=NECW_READ(FILE)
     IF KEYWORD_SET(BINARY) THEN ARRAY = BYTSCL(ARRAY,MIN=0,MAX=3200)
  ENDIF

; ====================>

  IF FIRST_ATTEMPT EQ 0 AND array[0] EQ -1 AND KEYWORD_SET(DEFAULT) THEN BEGIN
    first_attempt = 1
    TYPE = STRUPCASE(DEFAULT)
    GOTO, AGAIN
  ENDIF



; ====================>
; IDL other Types of Images or Arrays
; If file is a plain BINARY or INTEGER ARRAY OR A LONG ARRAY (and nothing else in the file)
  idl_type = ['BYT','BIN','INT','LON','FLT','FLO', 'DBL','DOU']
  ok         = WHERE(ext EQ idl_type,count)

  IF count GE 1 THEN BEGIN
    nth = ok[0]
;   idl_type    = ['BYT','BIN','INT','LON','FLT','FLO', 'DBL','DOU']
    nbytes      = [   1 ,   1,    2 ,   4 ,   4 ,   4,     8,    8 ] ; number of bytes per array element
    array_type  = ['BYT','BYT','INT','LON','FLT','FLT', 'DBL','DBL']
    _array_type = array_type(nth)
    _nbytes     = nbytes(nth)

;   Open the file
    OPENR,lun,file,/GET_LUN
;   Get statistics on file size
    s = FSTAT(lun)
    sz = s.size

;   ====================>
;   If px and py are not provided then assume a Square Array
    IF KEYWORD_SET(PX) AND KEYWORD_SET(PY) THEN BEGIN
      _px = LONG(PX)        & _py = LONG(PY)
    ENDIF ELSE BEGIN
      _px  = LONG(SQRT(sz/_nbytes)) & _py = _px
    ENDELSE

;   ====================>
;   Reassign px,py to output as keywords if called for by user
    px = _px & py = _py

;   ====================>
;   Check that array size and type agree with _px and _py dimensions
    pxpy = _px*_py
    _sz = sz - (pxpy*_nbytes)
    IF _sz NE 0 THEN  BEGIN
     ERROR = 1
     ERR_MSG = 'File size and/or type do not agree with PX and PY'
     PRINT, 'ERROR: File size and/or type do not agree with PX and PY'
      GOTO, DONE
    ENDIF

;   ==================>
;   Construct an idl command to execute and make the appropriate array
    _idl = 'array = ' + _array_type + 'ARR(' + STRING(_px) + ',' + STRING(_py) + ')'  ; end of this string
    a = EXECUTE(_idl)

;   ==================>
;   Read the image array
    READU,lun, array & CLOSE,LUN & FREE_LUN, lun

  ENDIF ;  IF count GE 1 THEN BEGIN



; ====================>
; HIS  IDL file made using IMAGE_STATS.PRO
; This is an 1108 byte record
; First field is image name (string 80 characters)
; Next  field is the subarea code (-1 if whole image statistics)
; Next  fields are histo output (lonarr(256)
  IF type EQ 'HIS'  THEN BEGIN
    _nbytes      = 1108 ;

;   Open the file
    OPENR,lun,file,/GET_LUN
;   Get statistics on file size
    s = FSTAT(lun)
    sz = s.size
    N  = LONG(sz/_nbytes) ; NUMBER OF RECORDS


;   ====================>
;   Check that array size and type agree dimensions
    _sz = sz - (N*_nbytes)
    IF _sz NE 0 THEN  BEGIN
      ERROR = 1
      ERR_MSG = 'File size and/or type do not agree with type expected'
      PRINT, 'ERROR: File size and/or type do not agree with type expected'
      GOTO, DONE
    ENDIF

;   =====================>
;   Maximum length of image name
    name_length = 80 ;
    blanks = BYTARR(name_length)
    blanks(*) = 32b
    blanks = STRING(blanks)

;   ==================>
;   Construct an idl command to execute and make the appropriate array
    _idl = CREATE_STRUCT('iname',blanks,'color',0L,'HIST',LONARR(256))
;   Replicate the structure template _idl
    ARRAY = REPLICATE(_idl, N)

;   ==================>
;   Read the HIS file
    READU,lun, array & CLOSE,LUN & FREE_LUN, lun

  ENDIF ;  IF count GE 1 THEN BEGIN






  DONE:



  RETURN, array


  END  ; End of Program READALL

; $ID:	PLOTDEG.PRO,	2020-06-26-15,	USER-KJWH	$
  pro plotdeg,FILES=files, MAP=MAP,quiet=QUIET,_EXTRA=_extra
;  TIMER,/START
;
;+
; NAME:
;       plotdeg
;
; PURPOSE:
;       Plot degree files (Formatted and unformated)
;
; CATEGORY:
;      Plotting
;
; CALLING SEQUENCE:
;       plotdeg
;       plotdeg,file='al8403.deg'
;       PLOTDEG,FILE='MARMAP.DEG',MAP='UCHUPI'
;
; INPUTS:
;          CONVENTIONS FOR FILE TYPES ACCORDING TO FILE EXTENSION
;
; ====================>  di6
;          Formatted
;          number of points for first line segment on first line
;          followed by lon,lat
;                      lon,lat
;                      lon,lat ... for all pts on line segment
;          followed by number of points for second line segment ...
;          These are written as following.
;          PRINTF,lun,pts,FORMAT='(I6)'   ; (number of pts in outline)
;          FOR _pts = 0, (pts -1) DO BEGIN
;            PRINTF,lun,lon(_pts),lat(_pts),FORMAT='(2F10.6)'
;          ENDFOR
;
;          Number of points per line segment limited to 999999
;          di6 files are made using IDL2DI6.PRO (COASTLINE,RIVERS,COUNTRIES)
;                          or using RRO2DI6.PRO

; ====================>  GDA  GEBCO DIGITAL ATLAS
;       ********************************************************
;       *               STANDARD OUTPUT FORMAT                 *
;       *            USED FOR EXPORTING DATA FROM              *
;       *              THE GEBCO DIGITAL ATLAS                 *
;       ********************************************************
;          Formatted
;					 Each vector stream is preceded by a header record containing a feature
;					 code  'ICODE'  for the vector and a count 'ICOUNT'  of the  number  of
;				   succeeding coordinate pairs making up the vector. Each coordinate pair
;					 is stored in a record with a geographic latitude 'ALAT'  and longitude
;					 'ALONG', each expressed in decimal degrees.
;					 Each record is made up of 20 bytes as follows:
;					 Header record: ICODE, ICOUNT in format (2I6,6X),CR,LF
;				   Coordinate pair record: ALAT, ALONG in format (F8.4,F10.4),CR,LF
;
; ====================>  deg
;          Unformatted
;          These are written as follows.
;          lonlat = FLTARR(2,npts) & WRITEU,lun,npts,lonlat
;          deg files are made using DI62DEG.PRO

; ====================>  uxy
;          Unformatted, UCHUPI standard inch coordinates
;          uxy files are made using DI62UXY.PRO
;          These are written as follows.
;          lonlat = FLTARR(2,npts) & WRITEU,lun,npts,lonlat
;

; ====================>  usg
;          Formatted
;          '# -b' on the first line
;          followed by lon,lat
;                      lon,lat
;                      lon,lat ...
;          followed by a # -b
;          followed by lon,lat
;                      lon,lat ...
;          Used by USGS, Woods Hole, MA
;
; ====================>  dim
;          Formatted
;          DSP DIM:
;          Assumes DSP Dim Files are comprised of:
;          Description Line (first line)
;          Longitude   space   Latitude  (decimal degrees)
;          etc. to last longitude,latitude record in file
; ====================>  d99
;          Formatted
;          DSP DIM:
;          Assumes DSP Dim Files are comprised of:
;          99.00(first line)
;          Longitude   space   Latitude  (decimal degrees)
;          for each line segment
;          Followed by 99.00 (delimiter)
;          etc. to last longitude,latitude record in file
;
; OTHER PROGRAMS CALLED BY THIS PROGRAM:
;          parse_it.pro    (Gets extension from file name)
;          filelist.pro    (Builds file list if wildcard '*' used)
;
; KEYWORD PARAMETERS:
;         FILES    Name(s) of input degree (lon,lat) files
;         QUIET:   Prevents program from printing to screen.
; OUTPUTS:
;         Plots on a previously established map projection.
; SIDE EFFECTS:
;         None.
;
; RESTRICTIONS:
;        Program does not work if a map projection is not established
;        by map_set.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, March 8, 1995.
;       April 4,1996: added keyword MAP (allows plotting of lambert
;                     MAP coordinates (inches) generated using
;                     mapconic.pro
;       March 16, 1998 Eliminated a case conversion of file names
;				June 20, 2001  Added GDA format to deal with new GEBCO data format
;				Jan 25, 2002   ADDED E16 FORMAT
;
;-

; ====================>
  color = !P.color
  icode = 0



; ====================>
; Define filter for file types recognized by this program
  _filter =  ['*.deg','*.di6','*.dim','*.d99','*.usg','*.uxy','*.gda','*.E16','con']


; ==================================>
; Get input files
; If the user does not supply a files=' file name(s) '
; then get a single file using the mouse
  IF KEYWORD_SET(files) EQ 0 THEN BEGIN
    files = DIALOG_PICKFILE(TITLE='Pick files',/MULTIPLE_FILES,FILTER=_filter)
  ENDIF ELSE BEGIN

	OK = WHERE(FILE_TEST(FILES) EQ 1,COUNT)
	IF COUNT GE 1 THEN BEGIN
		FILES=FILES[OK]
	ENDIF ELSE GOTO,DONE



IF N_ELEMENTS(MAP) EQ 0 THEN MAP = 'JUNK'
; IF STRUPCASE(MAP) EQ 'UCHUPI'
; ====================>
; Check if wildcard used for files
; If so then expand number of files in files to include
; all target files.

  files = filelist(files,/list)


  ENDELSE


; ====================>
; Loop for each of the input files
  FOR _files = 0,(N_ELEMENTS(files)-1) DO BEGIN
    IF N_ELEMENTS(quiet) EQ 0 THEN BEGIN
      PRINT, 'Reading File: ',files(_files)
    ENDIF

;   ====================>
;   Get the file type (extension).
    fname =parse_it(files(_files))
    ext = fname.ext
    ext = STRUPCASE(ext)

;   ====================>
;   Open the file
;    OPENR,lun,files(_files),/GET_LUN
    npts = 0L


; ====================>
; Check that the map transform has been established.

    IF   !x.type NE 3  THEN message,'Map transform not established.'


;   ====================>          DEG
    IF ext EQ 'DEG' THEN BEGIN
    OPENU,lun,files(_files),/GET_LUN

    ;POINT_LUN,LUN,0
    ptr = 0L
   AGAIN_DEG:
   POINT_LUN,LUN,ptr
   npts = 0L
    IF NOT EOF(lun) THEN READU,lun,npts $
      ELSE GOTO, DONEDEG
    lonlat = FLTARR(2,npts)
    READU,lun,lonlat

     IF STRUPCASE(MAP) EQ 'UCHUPI' THEN BEGIN
        MAPCONIC,LONLAT(0,*),LONLAT(1,*),_XX,_YY,MAP=MAP,/IN ; WANT OUTPUT IN OLD LAMBERT INCHES
        LONLAT(0,*) = _XX & LONLAT(1,*) = _YY
     ENDIF
        PLOTS,lonlat,NOCLIP=0,COLOR=COLOR,_EXTRA=_extra
    ptr = ptr + 4L + Long(npts*8)
    GOTO,AGAIN_DEG
    DONEDEG:

    ENDIF

;   ====================>          UXY
    IF ext EQ 'UXY' THEN BEGIN
    OPENU,lun,files(_files),/GET_LUN

    ;POINT_LUN,LUN,0
    ptr = 0L
   AGAIN_UXY:
   POINT_LUN,LUN,ptr
   npts = 0L
    IF NOT EOF(lun) THEN READU,lun,npts $
      ELSE GOTO, DONEuxy
    lonlat = FLTARR(2,npts)
    READU,lun,lonlat

    PLOTS,lonlat,NOCLIP=0,COLOR=COLOR,_EXTRA=_extra
    ptr = ptr + 4L + Long(npts*8)
    GOTO,AGAIN_UXY
    DONEuxy:

    ENDIF


;   ====================>          DI6
      IF ext EQ 'DI6' THEN BEGIN
      OPENR,lun,files(_files),/GET_LUN
      WHILE NOT EOF(lun) DO BEGIN
        READF,lun, npts, FORMAT='(I6)'
        lonlat = FLTARR(2,npts)
        FOR _npts = 0,(npts-1) DO BEGIN
          READF,lun,alon,alat,FORMAT='(2F10.6)'
          lonlat(0,_npts) = alon
          lonlat(1,_npts) = alat
        ENDFOR

     IF STRUPCASE(MAP) EQ 'UCHUPI' THEN BEGIN
        MAPCONIC,LONLAT(0,*),LONLAT(1,*),_XX,_YY,MAP=MAP,/IN ; WANT OUTPUT IN OLD LAMBERT INCHES
        LONLAT(0,*) = _XX & LONLAT(1,*) = _YY
     ENDIF
      PLOTS,lonlat(0,*),lonlat(1,*),$
            NOCLIP=0,COLOR=COLOR,_EXTRA=_extra
      ENDWHILE
    ENDIF

;   ====================>          E16
      IF ext EQ 'E16' THEN BEGIN
      EXTRA=0D
      OPENR,lun,files(_files),/GET_LUN
      WHILE NOT EOF(lun) DO BEGIN

        READF,lun, npts,EXTRA, FORMAT='(2E16.8)'
        lonlat = FLTARR(2,npts)
        FOR _npts = 0,(npts-1) DO BEGIN
          READF,lun,alon,alat,FORMAT='(2E16.8)'
          lonlat(0,_npts) = alon
          lonlat(1,_npts) = alat
        ENDFOR
      PLOTS,lonlat(0,*),lonlat(1,*),NOCLIP=0,COLOR=COLOR,_EXTRA=_extra
      ENDWHILE
    ENDIF

;   ***************************************
;		***** C O N  (IDL CONTOUR OUTPUT) *****
;		***************************************
      IF EXT EQ 'CON' THEN BEGIN
      INFO = { TYPE:0B, HIGH:0B, LEVEL:0, NUM:0L, VALUE:0.0}
      OPENR,lun,files(_files),/GET_LUN
      WHILE NOT EOF(lun) DO BEGIN
       	READU,LUN,INFO
				lonlat=FLTARR(2,INFO.NUM)
				READU,LUN,lonlat
      	PLOTS,lonlat(0,*),lonlat(1,*),NOCLIP=0,COLOR=COLOR,_EXTRA=_extra
      ENDWHILE
    ENDIF

;   ====================>          GDA
      IF ext EQ 'GDA' THEN BEGIN
      OPENR,lun,files(_files),/GET_LUN
      WHILE NOT EOF(lun) DO BEGIN
        READF,lun,Icode, npts, FORMAT='(2I6)'
        lonlat = FLTARR(2,npts)
        FOR _npts = 0,(npts-1) DO BEGIN
          READF,lun,alat,alon,FORMAT='(F8.4,F10.6)'
          lonlat(0,_npts) = alon
          lonlat(1,_npts) = alat
        ENDFOR
        PLOTS,lonlat(0,*),lonlat(1,*),$
            NOCLIP=0,COLOR=COLOR,_EXTRA=_extra
      ENDWHILE
    ENDIF

;   ====================>          DIM
       IF ext EQ 'DIM' THEN BEGIN
      OPENR,lun,files(_files),/GET_LUN
;       Codes used by usgs to delimit line segments
        new_line = '/break'
;       Get first line segment delimiter:  "/break"
        ATEXT = ' '

       REPEAT READF,lun,atext UNTIL MAX(WHERE (STRTRIM(atext,2) eq new_line))GE 0

        npts       = -1L
        lonlat = DBLARR(2,99999)
        WHILE NOT EOF(lun) DO BEGIN
          READF,lun,atext


          IF MAX(WHERE (STRTRIM(atext,2) eq new_line))GE 0 OR EOF(lun) THEN BEGIN
            IF npts GE 1 THEN BEGIN
            IF STRUPCASE(MAP) EQ 'UCHUPI' THEN BEGIN
               MAPCONIC,LONLAT(0,*),LONLAT(1,*),_XX,_YY,MAP=MAP,/IN ; WANT OUTPUT IN OLD LAMBERT INCHES
               LONLAT(0,*) = _XX & LONLAT(1,*) = _YY
            ENDIF

            PLOTS,lonlat(0,0:npts),lonlat(1,0:npts),$
                                    NOCLIP=0,COLOR=COLOR,_EXTRA=_extra
            ENDIF
            npts = -1L
          ENDIF ELSE BEGIN
            npts = npts + 1L
            READF,lun,alon,alat, FORMAT='(F7.2,F6.3)'
            lonlat(0,npts)=alon
            lonlat(1,npts)=alat
          ENDELSE
        ENDWHILE
       PLOTS,lonlat(0,0:npts),lonlat(1,0:npts),NOCLIP=0,COLOR=COLOR,_EXTRA=_extra
;       Plot the last line segment read.
    ENDIF



;   ====================>          D99
      IF ext EQ 'D99' THEN BEGIN
      OPENR,lun,files(_files),/GET_LUN
;       Codes used by usgs to delimit line segments
        new_line = ['  99.00 99.00']
;       Get first line segment delimiter:  "99.00"
        ATEXT = ' '
        stop
       REPEAT READF,lun,atext UNTIL MAX(WHERE (atext eq new_line))GE 0

        npts       = -1L
        lonlat = DBLARR(2,99999)
        WHILE NOT EOF(lun) DO BEGIN
          READF,lun,atext


          IF MAX(WHERE(atext eq new_line))GE 0 OR EOF(lun) THEN BEGIN
            IF npts GE 1 THEN BEGIN
            IF STRUPCASE(MAP) EQ 'UCHUPI' THEN BEGIN
               MAPCONIC,LONLAT(0,*),LONLAT(1,*),_XX,_YY,MAP=MAP,/IN ; WANT OUTPUT IN OLD LAMBERT INCHES
               LONLAT(0,*) = _XX & LONLAT(1,*) = _YY
            ENDIF

            PLOTS,lonlat(0,0:npts),lonlat(1,0:npts),$
                                    NOCLIP=0,COLOR=COLOR,_EXTRA=_extra
            ENDIF
            npts = -1L
          ENDIF ELSE BEGIN
            npts = npts + 1L
            READF,lun,alon,alat, FORMAT='(F7.2,F6.3)'
            lonlat(0,npts)=alon
            lonlat(1,npts)=alat
          ENDELSE
        ENDWHILE
;       PLOTS,lonlat(0,0:npts),lonlat(1,0:npts),NOCLIP=0,COLOR=COLOR,_EXTRA=_extra
;       Plot the last line segment read.
    ENDIF


;   ====================>          USG
;  Codes used by usgs to delimit line segments
   new_line = ['# -b' , '#-b' , '#  -b' , '#- b' , '#-b' , '#-  b' , '#- b']

   IF ext EQ 'USG' THEN BEGIN
   OPENR,lun,files(_files),/GET_LUN


;     Get first line segment delimiter:  "# -b"
      ATEXT = ' '
       REPEAT READF,lun,atext UNTIL MAX(WHERE (STRTRIM(STRMID(atext,0,5),2) eq new_line)) GE 0
        npts       = -1L
        lonlat = DBLARR(2,99999)
        WHILE NOT EOF(lun) DO BEGIN
          READF,lun,atext
;         print, atext
          IF MAX(WHERE(atext eq new_line))GE 0 OR EOF(lun) THEN BEGIN
            IF npts GE 1 THEN BEGIN
            IF STRUPCASE(MAP) EQ 'UCHUPI' THEN BEGIN
               MAPCONIC,LONLAT(0,0:NPTS),LONLAT(1,0:NPTS),_XX,_YY,MAP=MAP,/IN ; WANT OUTPUT IN OLD LAMBERT INCHES
               LONLAT(0,0:NPTS) = _XX & LONLAT(1,0:NPTS) = _YY
            ENDIF

            PLOTS,lonlat(0,0:npts),lonlat(1,0:npts),$
                                    NOCLIP=0,COLOR=COLOR,_EXTRA=_extra
            ENDIF
            npts = -1L
          ENDIF ELSE BEGIN
            IF STRPOS(ATEXT,'#',0) EQ -1 THEN BEGIN
;             Comment lines usually begin with '## ...'
;             These comments should be ignored.
              npts = npts + 1L
;             NOTE: USG bathymetry files are lat, lon ordered.
            ;  lonlat(1,npts) = DOUBLE(strmid(atext,0,9))
            ;  lonlat(0,npts) = DOUBLE(strmid(atext,10,10))
              lonlat(0,npts) = DOUBLE(strmid(atext,0,9))
              lonlat(1,npts) = DOUBLE(strmid(atext,10,10))
            ENDIF
          ENDELSE
        ENDWHILE

;        PLOTS,lonlat(0,0:npts),lonlat(1,0:npts),NOCLIP=0,COLOR=COLOR,_EXTRA=_extra

;      Plot the last line segment read.
    ENDIF


;   ====================>          GEBCO (R.SIGNELL USGS)
;  Codes used by usgs to delimit line segments
   new_line = ['# -b' , '#-b' , '#  -b' , '#- b' , '#-b' , '#-  b' , '#- b']

   IF ext EQ 'GEB' THEN BEGIN
   OPENR,lun,files(_files),/GET_LUN
;     Get first line segment delimiter:  "# -b"
      ATEXT = ' '
       REPEAT READF,lun,atext UNTIL MAX(WHERE (STRTRIM(STRMID(atext,0,5),2) eq new_line)) GE 0
        npts       = -1L
        lonlat = DBLARR(2,99999)
        WHILE NOT EOF(lun) DO BEGIN
          READF,lun,atext
;         print, atext
          IF MAX(WHERE (STRTRIM(STRMID(atext,0,5),2) eq new_line)) GE 0 OR EOF(lun) THEN BEGIN
            IF npts GE 1 THEN BEGIN

            PLOTS,lonlat(0,0:npts),lonlat(1,0:npts),$
                                    NOCLIP=0,COLOR=COLOR,_EXTRA=_extra
            ENDIF
            npts = -1L
          ENDIF ELSE BEGIN
            IF STRPOS(ATEXT,'#',0) EQ -1 THEN BEGIN
;             Comment lines usually begin with '## ...'
;             These comments should be ignored.
              npts = npts + 1L
;             NOTE: USG bathymetry files are lat, lon ordered.
              lonlat(0,npts) = DOUBLE(strmid(atext,0,10))
              lonlat(1,npts) = DOUBLE(strmid(atext,11,9))
            ENDIF
          ENDELSE
        ENDWHILE
;       PLOTS,lonlat(0,0:npts),lonlat(1,0:npts),NOCLIP=0,COLOR=COLOR,_EXTRA=_extra

;      Plot the last line segment read.
    ENDIF




    CLOSE,LUN & FREE_LUN,lun

		DONE:
    ENDFOR ; (FOR _files = 0,(N_ELEMENTS(files)-1) DO BEGIN)
   ; TIMER,/STOP
  END    ; ==================================>   END OF PROGRAM

; $Id: di62deg.pro,v 1.0 1996/04/05 12:00:00 J.E.O'Reilly Exp $
  pro di62deg,files=FILES ,QUIET=quiet
;
;+
; NAME:
;       di62deg
;
; PURPOSE:
;       Generate a smaller,faster binary file
;       from a di6 npts,lon,lat file
;       NOTE: Plotting a 'deg' file is 12 times faster than a 'di6' file
;       NOTE: Make the di6 file first since this is formatted and portable
;             across platform machines, then on the particular computer,
;             use di62deg.pro to make an unformatted file (readable only
;             on that computer)
;
;
; CATEGORY:
;      Reformatting
;
; CALLING SEQUENCE:
;       di62deg
;       di62deg,files='al8403.di6'
;
; INPUTS:
;          A 'di6' file made using e.g. idl2di6.pro
;
;
; ====================>  di6
;          Formatted
;          number of points for first line segment on first line (
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
;

; OTHER PROGRAMS CALLED BY THIS PROGRAM:
;          parse_it.pro    (Gets extension from file name)
;          filelist.pro    (Builds file list if wildcard '*' used)
;
; KEYWORD PARAMETERS:
;         FILES:   Name(s) of input degree (lon,lat) files
;         QUIET:   Prevents printing program messages
;
; OUTPUTS:
;
;          A 'deg' file which is an Unformatted version of the di6 file
;          These are written as follows:
;          first write the number of points as a longword then write lonlat
;          lonlat = FLTARR(2,npts) & WRITEU,lun,npts,lonlat
;
; SIDE EFFECTS:
;         None.
;
; RESTRICTIONS:
;        Program requires a di6 type file as input (see idl2di6.pro)
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, April 9, 1995.
;
;-

; ===================>
  IF !D.NAME EQ 'WIN' THEN dir = 'c:\idl\jay\deg\'
  IF !D.NAME EQ 'X'   THEN dir = '/c1/pathfdr1/jay/'
  cd,dir
; ====================>
; Define filter for file types recognized by this program
  _filter =  ['*.di6']

; ==================================>
; Get input files
; If the user does not supply a files=' file name(s) '
; then get a single file using the mouse
  IF KEYWORD_SET(files) EQ 0 THEN BEGIN
    files = PICKFILE(/READ,FILTER=_filter)
  ENDIF ELSE BEGIN

; ====================>
; Check if wildcard used for files
; If so then expand number of files in files to include
; all target files.

  files = STRLOWCASE(filelist(files,/list))
  ENDELSE

; ====================>
; Loop for each of the input files
  FOR _files = 0,(N_ELEMENTS(files)-1) DO BEGIN
    IF KEYWORD_SET(quiet) NE 0 THEN BEGIN
      PRINT, 'Reading File: ',files(_files)
    ENDIF

;   ====================>
;   Get the file type (extension).
    fname =parse_it(files(_files))
    ext = fname.ext
    ext = STRUPCASE(ext)


;   ====================>          DI6
    IF STRUPCASE(ext) EQ 'DI6' THEN BEGIN
;   Open the file
    OPENR,di6,files(_files),/GET_LUN

    degfile = fname.dir+fname.name+'.deg'
    OPENW,deg,degfile,/GET_LUN
    npts = 0L
    ptr = 0L
      WHILE NOT EOF(di6) DO BEGIN
        POINT_LUN,deg,ptr
        READF,di6, npts, FORMAT='(I6)'
        lonlat = FLTARR(2,npts)
        FOR _npts = 0,(npts-1) DO BEGIN
          READF,di6,alon,alat,FORMAT='(2F10.6)'
          lonlat(0,_npts) = alon
          lonlat(1,_npts) = alat
        ENDFOR

        WRITEU,deg,LONG(npts),FLOAT(lonlat)

        ptr = ptr + 4L + Long(npts*8L)
  ;      PRINT, NPTS,PTR

      ENDWHILE
    ENDIF

    FREE_LUN,di6
    FREE_LUN,deg
    CLOSE,di6
    CLOSE,deg
  ENDFOR ; (FOR _files = 0,(N_ELEMENTS(files)-1) DO BEGIN)
  END    ; ==================================>   END OF PROGRAM

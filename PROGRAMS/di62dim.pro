; $Id: di62dim.pro,v 1.0 1997/07/08 12:00:00 J.E.O'Reilly Exp $
  pro di62dim,files=FILES ,QUIET=quiet
;
;+
; NAME:
;       di62dim
;
; PURPOSE:
;       Generate a 'dim' file for use by U.Miami DSP program
;       from a di6 npts,lon,lat file
;
;       NOTE: Make the di6 file first since this is formatted and portable
;             across platform machines, then
;             use di62dim.pro to make a formatted ascii dim file
;
;
; CATEGORY:
;      Mapping, Reformatting
;
; CALLING SEQUENCE:
;       di62dim
;       di62dim,files='al8403.di6'
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
;         FILES:   Name(s) of input di6 (lon,lat) files
;         QUIET:   Prevents printing program messages
;
; OUTPUTS:
;
;          A 'dim' file which is an formatted ascii dim file for use by U.Miami DSP
;          These are written as follows:
;          first write the name of the file on the first line (header)
;          Then write each lon,lat pair on a single line
;          Before each line segment (arc) write '/break'
;
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
;       Written by:  J.E.O'Reilly, July 8, 1997
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

    dimfile = fname.dir+fname.name+'.dim'
    OPENW,dim,dimfile,/GET_LUN
    npts = 0L
    ptr = 0L
      WHILE NOT EOF(di6) DO BEGIN
        READF,di6, npts, FORMAT='(I6)'
        PRINTF,dim,'/break'
        lonlat = FLTARR(2,npts)
        FOR _npts = 0,(npts-1) DO BEGIN
          READF,di6,alon,alat,FORMAT='(2F10.6)'
           PRINTF,dim, alon,alat, FORMAT='(F7.3,1X,F6.3)'

        ENDFOR
      ENDWHILE
    ENDIF
    PRINTF,dim,'/break'
    FREE_LUN,di6
    FREE_LUN,dim
    CLOSE,di6
    CLOSE,dim
  ENDFOR ; (FOR _files = 0,(N_ELEMENTS(files)-1) DO BEGIN)
  END    ; ==================================>   END OF PROGRAM

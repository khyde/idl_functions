; $ID:	MAKE_HTML.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;MAKE_HTML:	This Program Makes HTML help file using IDL's MK_HTML_HELP
;HISTORY:	Oct 4, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO MAKE_HTML
  ROUTINE_NAME='MAKE_HTML'

	DIR_HTML='D:\IDL\HTML\'
  IF FILE_TEST(DIR_HTML,/DIRECTORY) EQ 0L THEN FILE_MKDIR,DIR_HTML

;MK_HTML_HELP, Sources, Filename [, /STRICT] [, TITLE=string] [, /VERBOSE]

 SOURCES = ['DT_*.PRO','WHERE*.PRO']
 SOURCES = ['TEMP*.PRO']
 SOURCES = ['DT_*.PRO']
  sources = 'TEMPLATE.PRO
 ; sources='DATE_NOW.PRO'
;  sources='MAKE_*.PRO'
 FOR nth=0,N_ELEMENTS(SOURCES)-1 DO BEGIN
 	 asource = SOURCES[NTH]
 	 FILES=FILELIST(asource)
 	 POS=STRPOS(asource,'*')
 	 type = STRMID(asource,0,pos )
 	 html_file = DIR_HTML+TYPE+'.HTML'
 	 print, type
   MK_HTML_HELP,files, html_file ;[, /STRICT] [, TITLE=string] [, /VERBOSE]

 ENDFOR



END; #####################  End of Routine ################################

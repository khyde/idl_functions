; $ID:	PFILE.PRO,	2023-09-19-17,	USER-KJWH	$
;########################################################################################################
	PRO PFILE,FILES,W=W,R=R,E=E,G=G,D=D,O=O,S=S,X=X,C=C,I=I,U=U,M=M,A=A,K=K,B=B,Z=Z,TXT=TXT,_OUTTXT=_OUTTXT,_POFTXT=_POFTXT,QUIET=QUIET,VERBOSE=VERBOSE,LOGLUN=LOGLUN

;+
; NAME:
;		PFILE
;
; PURPOSE: PRINT THE NAMES OF,AND THE OPERATION ON THE FILES BEING PROCESSED 
;
; CATEGORY:
;		 PRINT
;
; CALLING SEQUENCE:
; PFILE, FILES
; INPUTS:
;		FILES:	FILE NAMES
;		
; OPTIONAL INPUTS:
;		TXT........ Text to add to the end of the print line
;   _POFTXT.... Output from pof to add to the output text line
;   LOGLUN..... If provided, the LUN to write to a log file
;
; KEYWORD PARAMETERS:
;		W: WRITE [DEFAULT]
;		A: APPEND
;		R: READ
;		O: OPEN
;		G: GET
;		E: EXECUTE
;		D: DELETE
;		S: SIZE
;		X: EXIST
;		C: COPY
;		I: INFORMATION 
;		U: USING
;		M: MAKING
;		K: SKIPPING
;		V: MOVING
;		
;		QUIET: TO NOT PRINT ANY TXT
;   VERBOSE: TO PRINT EXTRA BLANK LINES
;
; OUTPUTS:
;		PRINTS INFORMATION ABOUT THE FILES BEING PROCESSED
;
; OPTIONAL OUTPUT:
;   _OUTTXT: VARIABLE TO SAVE THE OUTPUT TEXT
;
; EXAMPLES:
;  PFILE,'PFILE.PRO';    PRINTS: WRITE PFILE.PRO
;  PFILE,'PFILE.PRO',/W; PRINTS: WRITE PFILE.PRO
;  PFILE,'PFILE.PRO',/R; PRINTS: READ PFILE.PRO
;  PFILE,'PFILE.PRO',/G; PRINTS: GET PFILE.PRO
;  PFILE,'PFILE.PRO',/E; PRINTS: EXECUTE PFILE.PRO
;  PFILE,'PFILE.PRO',/X; PRINTS: EXIST PFILE.PRO
;  PFILE,'PFILE.PRO',/D; PRINTS: DELETE PFILE.PRO
;  PFILE,'PFILE.PRO',/O; PRINTS: OPEN PFILE.PRO
;  PFILE,'PFILE.PRO',/S; PRINTS: SIZE:6,412   PFILE.PRO
;  PFILE,'PFILE.PRO',/C; PRINTS: COPYING PFILE.PRO
;  PFILE,'PFILE.PRO',/U; PRINTS: USING PFILE.PRO
;  PFILE,'PFILE.PRO',/M; PRINTS: MAKING PFILE.PRO
;  PFILE,'PFILE.PRO',/Z; PRINTS: UNCOMPRESSING PFILE.PRO

;  FILES = ['FILE1.TXT','FILE2.TXT']&PFILE,FILES
;  PRINTS:
;  WRITE FILE1.TXT
;  WRITE FILE2.TXT
;
;COPYRIGHT:
; Copyright (C) 2012, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on March 12, 2001 by J.E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;   Inquiries on this code should be directed to: kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;			FEB 09, 2012 - JEOR: Wrote the initial code
;			FEB 23, 2012 - JEOR: ADDED KEYWORDS W,R,E,D [WRITE,READ,EXECUTE,DELETE] 
;			MAR 02, 2012 - JEOR: NOW USING FUNCTION CHARS [FOR SPECIAL CHARACTERS] 
;			MAR 14, 2012 - JEOR: ADDED KEYWORD G [GETTING ]
;			APR 06, 2012 - JEOR: ADDED KEYWORD S FOR SIZE OF FILE IN BYTES
;			APR 07, 2012 - JEOR: KEYWORD X NOW STANDS FOR EXIST; ADDED KEYWORD O FOR OPENING
;			APR 11, 2012 - JEOR: SHORTENED OUTPUT STRING SO INFO AND FILE NAME ARE ON THE SAME LINE.
;			JUL 26, 2012 - JEOR: CHANGED CHAR FOR GET
;			DEC 01, 2012 - JEOR: ADDED KEYWORD C FOR COPY
;			FEB 12, 2013 - JEOR: ADDED KEYWORD I FOR INFORMATION
;			MAY 28, 2013 - JEOR: ADDEDKEYWORD U FOR USING
;			AUG 13, 2013 - JEOR: ADDED DATE TI INFO WHEN KEYWORD I IS USED
;			AUG 15, 2013 - JEOR: ADDED MORE INFO WHEN /I    IM = READ_IMAGE(AFILE)
;     0CT 29, 2013 - JEOR: ADDED KEYWORD M FOR MAKING
;     JAN 11, 2014 - JEOR: ADDED KEYWORD A FOR APPENDING
;     MAR 26, 2014 - KJWH: ADDED TXT, _OUTTXT, _POFTXT, QUIET AND VERBOSE KEYWORDS
;     MAR 27, 2014 - JEOR: FIXED ERROR: % AMBIGUOUS KEYWORD ABBREVIATION: O.
;                          BU ADDING UNDERSCORES TO _OUTTXT & _POFTXT
;     APR 17, 2014 - JEOR: ADDED B FOR 'BANISHING'
;     AUG 26, 2014 - JEOR: ADDED Z FOR 'UNCOMPRESSING'
;     DEC 03, 2015 - JEOR: ADDED EXAMPLE FOR KEY Z,FIXED DOCUMENTATION,USE KEY FUNCTION
;     MAR 02, 2017 - JEOR: CHANGED KEY(Z) TO 'UNZIPPING'
;     MAR 10, 2017 - KJWH: Added IF !S.USER EQ 'KJWH' THEN BEGIN block to use Kim's preferred output
;     NOV 15, 2018 - KJWH: Changed the PRINT commands to PLUN so that they can be captured in a log file if provided
;                          Added LOGLUN keyword
;     JUL 01, 2020 - KJWH: Added COMPILE_OPT IDL2
;                          Removed calls to CHARS
;                          Changed the case of the output text 
;                          Updated documentaiton
;-
;########################################################################################################
  ROUTINE_NAME = 'PFILE'
  COMPILE_OPT IDL2

  IF NONE(LOGLUN)    THEN LOG_LUN = [] ELSE LOG_LUN = LOGLUN
  N = N_ELEMENTS(FILES)
  SP=' '
  
  IF N_ELEMENTS(TXT) NE 1 THEN _TXT = '' ELSE _TXT = '   ' + TXT
  CASE 1 OF
    KEYWORD_SET(R): TXT = 'Reading' +SP 
    KEYWORD_SET(W): TXT = 'Write'    +SP 
    KEYWORD_SET(G): TXT = 'Get'      +SP 
    KEYWORD_SET(E): TXT = 'Execute'  +SP 
    KEYWORD_SET(X): TXT = 'Exists'   +SP 
    KEYWORD_SET(D): TXT = 'Delete'   +SP 
    KEYWORD_SET(O): TXT = 'Open'     +SP 
    KEYWORD_SET(C): TXT = 'Copying'  +SP 
    KEYWORD_SET(U): TXT = 'Usimg'    +SP 
    KEYWORD_SET(M): TXT = 'Making'   +SP 
    KEYWORD_SET(A): TXT = 'Appending'+SP 
    KEYWORD_SET(K): TXT = 'Skipping' +SP 
    KEYWORD_SET(B): TXT = 'Banishing'+SP 
    KEYWORD_SET(Z): TXT = 'Unzipping'+SP 
    ELSE:           TXT = 'Writing'  +SP  
  ENDCASE
;
  FOR NTH=0, N-1L DO BEGIN
    AFILE=FILES[NTH]
    IF KEYWORD_SET(X) THEN BEGIN
      IF FILE_TEST(AFILE) EQ 1 THEN BEGIN
       TXT = ' Exists ' 
      ENDIF ELSE BEGIN
       TXT = 'Does not exist '     
     ENDELSE;IF FILE_TEST(AFILE) EQ 1 THEN BEGIN
    ENDIF;IF KEYWORD_SET(S)THEN BEGIN  
  
    IF KEYWORD_SET(S)THEN BEGIN
      TXT = 'Size: '   
      FI=FILE_INFO(AFILE)
      T = STR_COMMA(FI.SIZE)+SP
      TXT = TXT + T
    ENDIF;IF KEYWORD_SET(S)THEN BEGIN

    IF KEYWORD_SET(I) THEN BEGIN
      FI=FILE_INFO(AFILE)
      DATE = 'Date: '+ DATE_FORMAT(JD_2DATE(MTIME_2JD(FI.MTIME)),/YMD)
      D = IDL_RESTORE(AFILE,ERROR=ERROR) ;===> SEE IF THE FILE IS A SD [SCIENTIFIC DATASET]
      SZ = SIZEXYZ(D)
      IF SZ.TYPE EQ 8 THEN BEGIN  ;===> SEE IF STRUCT IS A STRUCTURE
        PLINES
        IF N_TAGS(D) EQ 1 THEN HELP,D.(0)
        TXT = 'Struct   ' 
      ENDIF ELSE BEGIN
        IM = READ_IMAGE(AFILE)
        SZ = SIZEXYZ(IM)
        TXT = 'Dimenions:   '+ SZ.TYPE_NAME +'  ' + STRTRIM(SZ.PX,2) + ' , ' +STRTRIM(SZ.PY,2) +'   '
        TXT = [DATE,TXT]
        PLIST,[AFILE,TXT] ,/NOSEQ  
      ENDELSE;IF TYPE EQ 8 THEN BEGIN
    ENDIF;IF KEYWORD_SET(I) THEN BEGIN
  
    IF N_ELEMENTS(_POFTXT) EQ 1 THEN _OUTTXT = TXT+_POFTXT+' '+ AFILE+_TXT ELSE _OUTTXT = TXT+AFILE+_TXT
    IF KEYWORD_SET(VERBOSE) THEN PLUN, LOG_LUN  ; ONLY PRINT IF YOU WANT THE EXTRA WHITE LINES
    IF NOT KEYWORD_SET(QUIET) THEN PLUN, LOG_LUN,_OUTTXT, 0
  ENDFOR;FOR NTH = 0,N-1L DO BEGIN

;FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  
END; #####################  END OF ROUTINE ################################

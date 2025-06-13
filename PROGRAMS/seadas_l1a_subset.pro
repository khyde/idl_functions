; $ID:	SEADAS_L1A_SUBSET.PRO,	2020-06-30-17,	USER-KJWH	$
;+
; NAME:
;		 SEADAS_L1_L2
;
; PURPOSE:
;    This procedure is the main program that will process L0 or L1A files to L2 using SeaDAS
;
; CATEGORY:
;    SeaDAS
;
; CALLING SEQUENCE:
;    Use SEADAS_MAIN to call this program (will not run as a stand alone program)
;
; INPUTS:
;		 FILES=FILES,$                     ; List of input files
;    DIR_OUT=DIR_OUT,$                 ; Output working directory
;    FILE_LABEL=FILE_LABEL,$           ; Output file names
;    SENSOR=SENSOR,$                   ; SeaWiFS or MODIS
;    METHOD=METHOD,$                   ; Valid Method (REPRO5)
;    COVERAGE=COVERAGE,$               ; Valid Coverage or HRPT site
;    PRODS=PRODS,$                     ; Output L2 products
;    SEADAS_MISSINGS=SEADAS_MISSINGS,$ ; Missing codes for the L2 products
;    LEVEL=LEVEL,$                     ; Input file LEVEL (L1A, L2, etc.)
;    OVERWRITE=OVERWRITE,$             ; Overwrite previous files
;    KEEP_FILES=KEEP_FILES,$           ; List of files to delete
;
;	NOTES:
;    Use SEADAS_MAIN to call this program (will not run as a stand alone program)
;
; MODIFICATIONS:
;
;  Sep 12, 2000  T.Ducas:    modified to run on flounder
;  Aug 8,  2000  J.O'Reilly: MSL12 input parameters:
;                            Changed the SUNZEN FROM SUNZEN=60 TO SUNZEN=75 (NASA DEFAULT, so we get data in GOM in December)
;  Sep 26, 2001  T.Ducas:    change output file naming to include the HRPT_SITE
;  JAN 29, 2002  T.Ducas:    direct PRINT statements to a log file, concatinate with seadas log for each iname
;  Jan 30, 2002  T.Ducas:    allow to process L2 files as input
;  Feb 25, 2002              added routines to get product suites and sensor names and renamed output l2 and l3 files
;  Sep 17, 2002              work with REPRO4,seadas 4.3,add steps l1atol0, l1agen
;  Mar 17, 2004  T.Ducas:    work with new naming convention
;  Nov 14, 2005  T.Ducas:    work with seadas 4.8 SEAWIFS REPRO5
;  Oct 13, 2006  K.J.W.Hyde: added ISOTROPIC = 1 to NEC and EC maps
;  Oct 13, 2006  K.J.W.Hyde: added MASS_BAY and GM (Gulf of Mexico for Rick Stumpf) maps
;  Oct 18, 2006  K.J.W.Hyde: changed the L2 names and added a VALID_LEVELS check so that it will skip the msl12 step if L2 files are already present
;  Oct 23, 2006  K.J.W.Hyde: added INVENTORY checks
;  Mar 05, 2007  K.J.W.Hyde: added MODIS options
;  Jun 26, 2007  K.J.W.Hyde: removed the BL2MAP step
;  Jul 27, 2007  K.J.W.Hyde: added ATM_COR and removed DO_SWIR keywords
;  Dec 16, 2010  K.J.W.Hyde: removed keywords and variables associated with the HIGH RES processing steps and updated calls compatible with SeaDAS 6.2
;  Dec 17, 2010  D.W.Moonan: Fixing up to run with SeaDAS 6.2, added MODIS and SEAWIFS l2gen command sections.  Added ability to use 'getanc'


PRO SEADAS_L1A_SUBSET,$
    FILES=FILES,$                     ; List of input files
    DIR_OUT=DIR_OUT,$                 ; Output working directory            
    SWLAT=SWLAT, $                    ; Southwest latitude for L1A MODIS extraction
    SWLON=SWLON, $                    ; Southwest longitude for L1A MODIS extraction
    NELAT=NELAT, $                    ; Northeast latitude for L1A MODIS extraction
    NELON=NELON, $                    ; Northeast longitude for L1A MODIS extraction
    SENSOR=SENSOR,$                   ; SeaWiFS or MODIS    
    COVERAGE=COVERAGE,$               ; Valid Coverage or HRPT site        
    LEVEL=LEVEL,$                     ; Input file LEVEL (L1A, L2, etc.)    
    OVERWRITE=OVERWRITE               ; Overwrite previous files
    

  ROUTINE_NAME = 'SEADAS_L1_L2'
  SL = DELIMITER(/PATH)

  IF N_ELEMENTS(OVERWRITE)   EQ 1 THEN OVERWRITE = FIX(OVERWRITE) ELSE OVERWRITE = 0  
  IF N_ELEMENTS(DIR_OUT)     EQ 0 THEN DIR_OUT   = !S.DATASETS+SL+'OC_'+SENSOR +'_' + COVERAGE + SL
  
  ; ***** SET UP SUBAREA EXTRACTION AREA *****
  IF N_ELEMENTS(SWLAT) EQ 0 THEN _SWLAT = '17.92' ELSE _SWLAT = STRING(SWLAT) 
  IF N_ELEMENTS(SWLON) EQ 0 THEN _SWLON = '-97.8' ELSE _SWLON = STRING(SWLON)
  IF N_ELEMENTS(NELAT) EQ 0 THEN _NELAT = '55.4'  ELSE _NELAT = STRING(NELAT)
  IF N_ELEMENTS(NELON) EQ 0 THEN _NELON = '-43.8' ELSE _NELON = STRING(NELON)  
  
  FPDIR = FILE_PARSE(DIR_OUT)  
  FPFILE = FILE_PARSE(FILES[0])
  DIR_UP  = REPLACE(DIR_OUT,SL+FPDIR.SUB+SL,SL)
  DIR_LOG     = DIR_OUT + 'LOG'     + SL  
  DIR_L1A_SUB = DIR_UP  + 'L1A_SUB' + SL
  DIR_GEO_SUB = DIR_UP  + 'GEO_SUB' + SL
  IF FILE_TEST(DIR_OUT,/DIR) EQ 0 THEN FILE_MKDIR, DIR_OUT
  IF FILE_TEST(DIR_LOG,/DIR) EQ 0 THEN FILE_MKDIR, DIR_LOG
  IF FILE_TEST(DIR_L1A_SUB,/DIR) EQ 0 THEN FILE_MKDIR, DIR_L1A_SUB
  IF FILE_TEST(DIR_GEO_SUB,/DIR) EQ 0 THEN FILE_MKDIR, DIR_GEO_SUB
  
  seadas_init ; needed for seadas6.3

; *******************************************
; *****      LOOP THROUGH EACH FILE     *****
; *******************************************
  FOR _FILE = 0L,N_ELEMENTS(FILES)-1 DO BEGIN
    AFILE = FILES(_FILE)
    PRINT, 'Working on ' + AFILE + ' (' + NUM2STR(_FILE) + ' out of ' + NUM2STR(N_ELEMENTS(FILES)) + ')'  
    
;   ***** Make sure input file exists *****
    IF FILE_TEST(AFILE) EQ 0 THEN BEGIN
      OPENW,LUN,LOG_FILE,/GET_LUN
      PRINTF,LUN, 'ERROR: '+AFILE+' NOT FOUND'
      CLOSE,LUN  
      FREE_LUN, LUN, /FORCE       
      CONTINUE
    ENDIF
    
    FN = PARSE_IT(AFILE,/ALL)    
    IF N_ELEMENTS(SENSOR) EQ 0 THEN BEGIN
      IF STRMID(FN.NAME,0,1) EQ 'S' THEN _SENSOR = 'SEAWIFS'
      IF STRMID(FN.NAME,0,1) EQ 'A' THEN _SENSOR = 'MODIS'
      IF STRMID(FN.NAME,0,1) EQ 'C' THEN _SENSOR = 'CZCS'
    ENDIF ELSE _SENSOR = SENSOR(_FILE)
    IF N_ELEMENTS(METHOD) EQ 0 THEN _METHOD = 'R2010' ELSE _METHOD = METHOD(_FILE)
    IF N_ELEMENTS(LEVEL)  EQ 0 THEN _LEVEL  = 'L1A'   ELSE _LEVEL  = LEVEL(_FILE)
            
    _NAME = STRSPLIT(FN.NAME_EXT,'._-',/EXTRACT,/PRESERVE_NULL)
    _SUB  = WHERE(_NAME EQ 'SUB',COUNT_SUB)
    SATDATE = _NAME[0]    
    EXT = STRUPCASE(FN.EXT)
    IF EXT EQ 'Z' OR EXT EQ 'GZ' OR EXT EQ 'BZ2' THEN IFILE = DIR_OUT + FN.NAME ELSE IFILE = DIR_OUT + FN.NAME_EXT 
    REMOVE_FILES = []
    
;   ***** Set up output names *****        
    GEOFILE                  = DIR_OUT + SATDATE + '.GEO'    
    GEOPCF                   = GEOFILE + '.pcf'
    L1A_SUB                  = DIR_L1A_SUB + SATDATE + '.L1A_LAC_SUB'
    L1A_SUB_GZIP             = L1A_SUB + '.gz'
    L1A_SUB_BZIP             = L1A_SUB + '.bz2'
    GEO_SUB                  = DIR_GEO_SUB + SATDATE + '.GEO_SUB'        
    LOG_FILE                 = DIR_LOG + SATDATE + '.L1A_LAC_SUB.log'
        
;   ***** If input file is a L1A_LAC_SUB file, do not process subset *****
    IF COUNT_SUB GT 0 THEN BEGIN
      OPENW,LUN,LOG_FILE,/GET_LUN
      PRINTF,LUN, 'ERROR, FILE ('+AFILE+' HAS ALREADY BEEN SUBSET'
      CLOSE,LUN  
      FREE_LUN, LUN, /FORCE 
      CONTINUE
    ENDIF

;   ***** If input file is not a L2 or a L1A then do not process *****
    IF STRUPCASE(_LEVEL) NE 'L1A' AND STRUPCASE(_LEVEL) NE 'L0' THEN BEGIN
      OPENW,LUN,LOG_FILE,/GET_LUN
      PRINTF,LUN, 'ERROR, FILE ('+AFILE+' IS NOT A LEVEL L1A Z FILE'
      CLOSE,LUN  
      FREE_LUN, LUN, /FORCE 
      CONTINUE
    ENDIF

;   ***** If OVERWRITE = 1 then create all new processing files *****
    IF KEYWORD_SET(OVERWRITE) THEN BEGIN
      PRINT, 'KEYWORD OVERWRITE SET: Deleting all previously created processing files'      
      IF FILE_TEST(L1A_SUB)          GE 1 THEN FILE_DELETE, L1A_SUB
      IF FILE_TEST(L1A_SUB + '.gz')  GE 1 THEN FILE_DELETE, L1A_SUB + '.gz'
      IF FILE_TEST(L1A_SUB + '.bz2') GE 1 THEN FILE_DELETE, L1A_SUB + '.bz2'
      IF FILE_TEST(L1A_SUB + '.GZ')  GE 1 THEN FILE_DELETE, L1A_SUB + '.GZ'
      IF FILE_TEST(L1A_SUB + '.BZ2') GE 1 THEN FILE_DELETE, L1A_SUB + '.BZ2'
      IF FILE_TEST(GEOFILE)          GE 1 THEN FILE_DELETE, GEOFILE
      IF FILE_TEST(GEO_SUB)          GE 1 THEN FILE_DELETE, GEO_SUB
    ENDIF
    
;   ***** Check to see if files exist *****
    IF _LEVEL EQ 'L1A' AND _SENSOR EQ 'MODIS' THEN BEGIN      
      IF TOTAL(FILE_TEST([L1A_SUB,L1A_SUB_GZIP,L1A_SUB_BZIP])) GE 1 AND FILE_TEST(GEO_SUB) EQ 1 THEN GOTO, SKIP_SUBSET
      IF FILE_TEST(GEOFILE)  EQ 1 THEN GOTO, SKIP_GEO
    ENDIF  

;   ***** Uncompress and copy file to working directory *****
    COPY_L1A:
    IF STRUPCASE(FN.EXT) EQ 'Z' OR STRUPCASE(FN.EXT) EQ 'GZ' OR STRUPCASE(FN.EXT) EQ 'BZ2' THEN BEGIN
      PRINT, 'Copying and unzipping ' + AFILE
      Z = DIR_OUT + FN.NAME
      IF FILE_TEST(Z) EQ 0 THEN ZIP, FILES=AFILE, DIR_OUT=DIR_OUT
      IFILE = DIR_OUT + FN.NAME
    ENDIF ELSE BEGIN
      PRINT, 'Copying ' + AFILE
      Z = DIR_OUT + FN.NAME_EXT
      IF FILE_TEST(Z) EQ 0 THEN FILE_COPY, AFILE, DIR_OUT
      IFILE = DIR_OUT + FN.NAME_EXT
    ENDELSE
    
    IF FILE_TEST(IFILE) EQ 0 THEN CONTINUE     
    REMOVE_FILES = [IFILE]
    
;   ***** If MODIS then create GEOLOCATION, SUBSET and L1B files *****
    IF _LEVEL EQ 'L1A' THEN BEGIN 
      IF _SENSOR EQ 'MODIS' THEN BEGIN
  ;     ***** Make GEOLOCATION file for MODIS LIA if it does not exist *****
        PRINT, 'Making geolocation file for : ' + IFILE + ' (' + NUM2STR(_FILE) + ' out of ' + NUM2STR(N_ELEMENTS(FILES)) + ')'
        GEOCOUNTER = 0
        RERUN_GEOGEN_MODIS:
        IF FILE_TEST(GEOFILE) NE 1 THEN $   ; If ATTEPH files are to be downloaded during processing, then turn off the /disabledefinftp, /disablepredftp keywords
          GEOGEN_MODIS, IFILE=IFILE, GEOFILE=GEOFILE,ENABLEDEM=0,/WAIT,/VERBOSEHTTP,/SAVELOG          
        IF FILE_TEST(GEOFILE) EQ 0 THEN BEGIN
          IF GEOCOUNTER EQ 0 THEN OPENW,LUN,LOG_FILE,/GET_LUN
          PRINTF,LUN, 'ERROR: CAN NOT PROCEDE WITH GEOLOCATE, ' + GEOFILE +' NOT FOUND'     
          GEOCOUNTER = GEOCOUNTER + 1               
          IF GEOCOUNTER LT 5 THEN GOTO, RERUN_GEOGEN_MODIS
          CLOSE,LUN  
          FREE_LUN, LUN, /FORCE 
          CONTINUE
        ENDIF
        IF KEYWORD_SET(GEO_ONLY) THEN GOTO, DONE                
        SKIP_GEO:
        GEO_FILE = GEOFILE
        
;      ***** Subset L1A and GEOLOCATION files (for the HIGH RESOLUTION MODIS files) *****
        PRINT, 'Subsetting the L1A and GEOLOCATION files on ' + IFILE + ' (' + NUM2STR(_FILE) + ' out of ' + NUM2STR(N_ELEMENTS(FILES)) + ')'
        IF FILE_TEST(IFILE) EQ 0 THEN GOTO, COPY_L1A
        IF FILE_TEST(L1A_SUB) NE 1 OR FILE_TEST(GEO_SUB) NE 1 THEN $
          L1AEXTRACT_MODIS, IFILE=IFILE, GEOFILE=GEOFILE, OFILE=L1A_SUB, OUTGEO=GEO_SUB,$
          SWLAT=_SWLAT, SWLON=_SWLON, NELAT=_NELAT, NELON=_NELON,/WAIT          
        REMOVE_FILES = [REMOVE_FILES,GEOFILE,GEOPCF]
        SKIP_SUBSET:
      ENDIF
    ENDIF    
        
    IF REMOVE_FILES NE [] THEN OK = WHERE(FILE_TEST(REMOVE_FILES) EQ 1,COUNT) ELSE COUNT = 0
    IF COUNT GE 1 THEN FILE_DELETE,REMOVE_FILES[OK]
  
    DONE:    
    PRINT, routine_name + ' Finished subsetting: ' + AFILE +  ' (' + NUM2STR(_FILE) + ' out of ' + NUM2STR(N_ELEMENTS(FILES)) + ')'
    
  ENDFOR  ; FOR FILE
  
  
END



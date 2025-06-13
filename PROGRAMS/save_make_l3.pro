; $ID:	SAVE_MAKE_L3.PRO,	2020-07-08-15,	USER-KJWH	$
;################################################################################################################
 PRO SAVE_MAKE_L3, FILES, PRODS=prods, DATE_RANGE=date_range, DIR_OUT=dir_out, MAP_OUT=map_out, GLOBAL_ONLY=global_only, DATA_ONLY=data_only, RETURN_STRUCT=return_struct, OVERWRITE=overwrite, ERROR=error
 
;+
; PURPOSE: This Function Reads a SEADAS NETCDF L3b Day file and saves the entire structure as an IDL compressed file, which economizes space and permits quick accessibility in IDL
;
; SYNTAX:  L3_2SAV(Files,DIR_OUT=dir_out,OVERWRITE=overwrite)
; 
; OUTPUT:  Level 3 .SAV files
; 
; INPUT: FILES = Global L3b_DAY files from the NASA Ocean Color Web
;        
; KEYWORDS: PRODUCTS = Sensor specific products to get fromt the L3b files
;           METHOD = Reprocessing method (i.e. R2015) for the output file name
;           DIR_OUT = Output directory for the .SAV files
;           OVERWRITE = Rewrite the .SAV if it already exits
;
; EXAMPLE:
; 
; CATEGORY: SAVE_MAKE

; NOTES:
; 
; REQUIRES:
;   
; WRITTEN: Aug 10, 2015 - K. Hyde 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov) 
;          Adapted from L3_2SAV
;          
; MODIFICATION_HISTORY: 
;          Sep 17, 2015 - KJWH: Updated CHL algorithms and added VIIRS block
;          Oct 20, 2015 - KJWH: Streamlined and overalled the program to use SENSOR_INFO
;                               NOTE - Still need to update the SST info
;          Oct 22, 2015 - KJWH: Changed VALID_PRODS and VALID_ALGS to VALIDS   
;          Nov 23, 2015 - KJWH: Now can read multiple products with a single call to READ_NC  
;          Dec 03, 2015 - KJWH: Added PRESERVE_NULL keyword to the STRSPLIT call in case there are blanks in the string  
;          Apr 25, 2016 - KJWH: Added step to write out the original GLOBAL information in the netcdf as a .SAV file     
;          Jul 27, 2016 - KJWH: Added MAP_OUT keyword and updated program so that it accurately creates .SAV files for the specified PROD and MAP_OUT  
;          Jul 29, 2016 - KJWH: Added DATA_ONLY and RETURN_STRUCT keywords
;          Sep 14, 2016 - KJWH: Changed the output struct tag "INFILE" to "NCFILES" to be consistent with other files
;                         
;##########################################################################
;-

;***************************
  ROUTINE_NAME='SAVE_MAKE_L3'
;***************************

  ERROR = 0
  DASH=DELIMITER(/DASH)
  SL=PATH_SEP()

  IF NONE(FILES) THEN FILES = DIALOG_PICKFILE(TITLE='satellite files')
  IF KEY(DATE_RANGE) THEN FILES = DATE_SELECT(FILES,DATE_RANGE)	
	IF NONE(MAP_OUT) THEN MAP_OUT = ''
		 
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR F=0, N_ELEMENTS(FILES)-1L DO BEGIN
  	AFILE=FILES(F)
  	FP = FILE_PARSE(AFILE)
  	SI = SENSOR_INFO(AFILE)
  	IF NONE(DIR_OUT) THEN DIR_OUT  = REPLACE(FP.DIR,FP.SUB,SI.MAP+SL+'SAVE') 
  	DIR_LOG  = DIR_OUT + 'SAVE_LOGS' + SL       
  	DIR_GLOBAL = REPLACE(FP.DIR, FP.SUB, 'GLOBAL')     
  	DIR_TEST, [DIR_LOG,DIR_GLOBAL]    
  	OUTPUT_LABEL=SI.PERIOD+DASH+SI.FILELABEL
  	IF STRUPCASE(FP.EXT) NE 'NC' THEN GLOBALFILE = DIR_GLOBAL + FP.NAME_EXT + '-GLOBAL.SAV' ELSE GLOBALFILE = DIR_GLOBAL + FP.NAME + '-GLOBAL.SAV'

  	PROD_NAME    = STRSPLIT(SI.PRODS,  SI.DELIM,/EXTRACT,/PRESERVE_NULL)
  	L3_PROD_NAME = STRSPLIT(SI.NC_PROD,SI.DELIM,/EXTRACT,/PRESERVE_NULL)
  	IF NONE(PRODS) THEN SAVEPRODS = PROD_NAME ELSE SAVEPRODS = PRODS ; If no PRODS provided, then make save files for all products specified in SENSOR_INFO
  	OK=WHERE_IN(PROD_NAME,SAVEPRODS,COUNT)
  	IF COUNT GE 1 THEN BEGIN
  	  PROD_PAIRS = []
  	  PRODUCTS = PROD_NAME[OK]
  	  L3_PRODS = L3_PROD_NAME[OK]
  	  FOR P=0, N_ELEMENTS(PRODUCTS)-1 DO PROD_PAIRS = [PROD_PAIRS,STRJOIN([PRODUCTS(P),L3_PRODS(P)],';')]
  	ENDIF ELSE BEGIN
  	  TXT = PROD_NAME + ': Are not valid products for file - ' + AFILE
  	  REPORT, TXT, DIR=DIR_LOG 
  	  CONTINUE
  	ENDELSE
  	    
    DO_PRODS  = []
    SAVEFILES = []
    FOR M=0, N_ELEMENTS(MAP_OUT)-1 DO BEGIN
      MAP_LABEL = REPLACE(OUTPUT_LABEL,SI.MAP, MAP_OUT(M))
      DIR_MAP   = DIR_OUT + MAP_OUT(M) + SL + 'SAVE' + SL
      FOR P=0,N_ELEMENTS(PRODUCTS)-1 DO BEGIN
        APROD = PRODUCTS(P)
        OUTPROD = VALIDS('PRODS',APROD)
        DIR_PROD = DIR_MAP + OUTPROD + SL    
        SAVEFILE=DIR_PROD + MAP_LABEL + DASH + OUTPROD + '.SAV' 
        ALG = VALIDS('ALGS',APROD)  
       	IF ALG NE '' THEN BEGIN
       	  DIR_PROD = DIR_MAP+OUTPROD+DASH+ALG+SL
       	  SAVEFILE = DIR_PROD + MAP_LABEL + DASH + OUTPROD + DASH + ALG + '.SAV'
       	ENDIF
        DIR_TEST, DIR_PROD                    
        IF FILE_MAKE(AFILE,SAVEFILE,OVERWRITE=OVERWRITE) EQ 1 THEN BEGIN
          DO_PRODS = [DO_PRODS,APROD]
          SAVEFILES = [SAVEFILES,SAVEFILE]
        ENDIF
      ENDFOR ; PRODUCTS
    ENDFOR ; MAP_OUT  
    SFP = PARSE_IT(SAVEFILES,/ALL)
    
    IF DO_PRODS EQ [] AND FILE_MAKE(AFILE,GLOBALFILE) EQ 0 THEN CONTINUE;>>>>>>>>>>>>>>>>>>>>
    IF DO_PRODS EQ [] OR KEY(GLOBAL_ONLY) THEN BEGIN
      PFILE, AFILE, /R
      SD = READ_NC(AFILE,PRODS='GLOBAL')
      IF IDLTYPE(SD) EQ 'STRING' THEN BEGIN
        TXT='ERROR: CAN NOT READ '+SFILE+ '; ' + DATE_NOW()
        REPORT,TXT,DIR=DIR_LOG
        PRINT,TXT
        CONTINUE
      ENDIF
      GLOBAL=SD.GLOBAL
      PRINT, 'WRITING: ' + GLOBALFILE
      SAVE, GLOBAL, FILENAME=GLOBALFILE
      CONTINUE
    ENDIF
    
    DO_PRODS = DO_PRODS[UNIQ(DO_PRODS, SORT(DO_PRODS))] ; Sort and find uniq DO_PRODS
                
    PRINT, 'READING: '+AFILE      
    OK=WHERE_MATCH(STRUPCASE(PRODUCTS),STRUPCASE(DO_PRODS),COUNT)
    IF COUNT EQ 0 THEN NC_PRODS = 'GLOBAL' ELSE NC_PRODS = ['GLOBAL',L3_PRODS[OK]]  
   
      
    NC = READ_NC(AFILE,PRODS=NC_PRODS) 
    GLOBAL = NC.GLOBAL
    SD = NC.SD
    TAGS = TAG_NAMES(SD)
    IF FILE_MAKE(AFILE,GLOBALFILE,OVERWRITE=OVERWRITE) EQ 1 THEN SAVE, GLOBAL, FILENAME=GLOBALFILE
    
    
    FOR P=0,N_ELEMENTS(SD)-1 DO BEGIN
      APROD = STRUPCASE(DO_PRODS(P))    
      OK = WHERE(PRODUCTS EQ APROD, COUNT) & IF COUNT EQ 0 THEN STOP
      PP = STRSPLIT(PROD_PAIRS[OK],';',/EXTRACT)
      NCPOS = WHERE(STRUPCASE(TAGS) EQ STRUPCASE(PP[1]), COUNT) & IF COUNT EQ 0 THEN STOP
      L3DATA = SD.(NCPOS).DATA
               
      IF STRPOS(APROD,'SST') GE 0 THEN IF SST_QUALITY_CODE LT 4 THEN BEGIN            ; SST_QUALITY_CODE OF 4 = No masking
 STOP ; NEED TO UPDATE THE SST STEP WITH THE NC OPTIONS
;        MASK = READL3BINJ(AFILE,'qual_l3',bins,ERROR=error)                     
;        OK_CODE = WHERE(MASK GT SST_QUALITY_CODE,COUNT_CODE)  ; Mask pixels with QUALITY values greater than the SST_QUALITY_CODE          
;        IF COUNT_CODE GE 1 THEN DATA(OK_CODE) = MISSINGS(DATA)     
;        GONE, MASK
      ENDIF;IF STRPOS(APROD,'SST') GE 0 THEN IF SST_QUALITY_CODE LT 4 THEN BEGIN            ; SST_QUALITY_CODE OF 4 = No masking 
                          
      IF HAS(SI.MAP,'L3B') THEN BEGIN 		
        BINS = SD.(NCPOS).BINS
        IF N_ELEMENTS(L3DATA) GE 10 THEN BEGIN
          IMG = FLTARR(SI.N_BINS) & IMG(*,*) = MISSINGS(IMG)   
          IMG(BINS) = L3DATA
          SZ=SIZE(IMG,/STRUCT)
          
          IF SZ.N_ELEMENTS NE SI.N_BINS THEN BEGIN
            TXT=' ERROR GETTING IMAGE DATA FOR FILE: '+NUM2STR(F)+'   '+AFILE
            REPORT,TXT,DIR=DIR_LOG
            CONTINUE
          ENDIF ; IF SZ.N_ELEMENTS NE N_BINS THEN BEGIN
          
          IF SZ.N_DIMENSIONS EQ 1 THEN IMG=REFORM(IMG,1,SZ.N_ELEMENTS) 
        
        ENDIF ELSE BEGIN  ; IF N_ELEMENTS(DATA) GE 10 THEN BEGIN
       	  TXT=' IMAGE CONTAINS LESS THAN 10 PIXELS IN FILE: '+NUM2STR(F)+'   '+AFILE
          REPORT,TXT,DIR=DIR_LOG
          CONTINUE
        ENDELSE ; IF N_ELEMENTS(DATA) GE 10 THEN BEGIN      
      ENDIF 
      
      FOR M=0, N_ELEMENTS(MAP_OUT)-1 DO BEGIN
        OK = WHERE(SFP.MAP EQ MAP_OUT(M) AND SFP.PROD_ALG EQ APROD,COUNT) 
        IF COUNT NE 1 THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        IF KEY(MAP_OUT(M)) THEN IMG = MAPS_REMAP(L3DATA, MAP_IN=SI.MAP, MAP_OUT=MAP_OUT(M), BINS=BINS)
        IF KEY(DATA_ONLY) THEN RETURN_STRUCT = 1 ELSE RETURN_STRUCT = 0
        STRUCT_WRITE, IMG, FILE=SAVEFILES[OK], GLOBAL=GLOBAL, DATA_UNITS=UNITS(APROD), NCFILES=AFILE, RETURN_STRUCT=RETURN_STRUCT,$
                    METHOD=SI.METHOD, SATELLITE=SI.SATELLITE, SENSOR=SI.SENSOR, COVERAGE=SI.COVERAGE,  N_BINS=SI.N_BINS, DATA_SOURCE=SI.SOURCE
      ENDFOR ; FOR M=0, N_ELEMENTS(MAP_OUT)-1 DO BEGIN
    ENDFOR ;   FOR P = 0,N_ELEMENTS(DO_PROD)-1 DO BEGIN
  ENDFOR ;     FOR F = 0L,N_ELEMENTS(FILES)-1L DO BEGIN
  DONE:  
END; #####################  End of Routine ################################

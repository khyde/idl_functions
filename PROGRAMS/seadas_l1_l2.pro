; $ID:	SEADAS_L1_L2.PRO,	2020-06-30-17,	USER-KJWH	$
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


PRO SEADAS_L1_L2,$
    FILES=FILES,$                     ; List of input files
    DIR_OUT=DIR_OUT,$                 ; Output working directory
    FILE_LABEL=FILE_LABEL,$           ; Output file names
    DO_SUBSET=DO_SUBSET,$             ; Subset the MODIS files
    GEO_ONLY=GEO_ONLY,$               ; Step out of program after the GEOGEN step
    SUBSET_ONLY=SUBSET_ONLY,$         ; Step out of program after the SUBSET step
    L1B_ONLY=L1B_ONLY,$               ; Step out of program after the L1BGEN step
    SWLAT=SWLAT, $                    ; Southwest latitude for L1A MODIS extraction
    SWLON=SWLON, $                    ; Southwest longitude for L1A MODIS extraction
    NELAT=NELAT, $                    ; Northeast latitude for L1A MODIS extraction
    NELON=NELON, $                    ; Northeast longitude for L1A MODIS extraction
    SENSOR=SENSOR,$                   ; SeaWiFS or MODIS
    METHOD=METHOD,$                   ; Valid Method (REPRO5)
    COVERAGE=COVERAGE,$               ; Valid Coverage or HRPT site
    PRODS=PRODS,$                     ; Output L2 products
    SEADAS_MISSINGS=SEADAS_MISSINGS,$ ; Missing codes for L2 products
    LEVEL=LEVEL,$                     ; Input file LEVEL (L1A, L2, etc.)
    SKIP_ZIP=SKIP_ZIP,$               ; Turn ZIP function on and off
    OVERWRITE=OVERWRITE               ; Overwrite previous files
    

  ROUTINE_NAME = 'SEADAS_L1_L2'

  SL = DELIMITER(/PATH)

  IF N_ELEMENTS(OVERWRITE)   EQ 1 THEN OVERWRITE = FIX(OVERWRITE) ELSE OVERWRITE = 0  
  IF N_ELEMENTS(DIR_OUT)     EQ 0 THEN DIR_OUT   = !S.DATASETS+SL+'OC_'+SENSOR +'_' + COVERAGE + SL
  
  FPDIR = FILE_PARSE(DIR_OUT)
  DIR_LOG = DIR_OUT+'LOG'+SL  
  DIR_PAR = DIR_OUT+'PAR'+SL
  FPFILE = FILE_PARSE(FILES[0])
  DIR_UP  = REPLACE(DIR_OUT,SL+FPDIR.SUB+SL,SL)
  DIR_L1A_SUB = DIR_UP + 'L1A_SUB' + SL
  DIR_GEO_SUB = DIR_UP + 'GEO_SUB' + SL
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
    PRINT, 'Working on ' + AFILE + ' (' + NUM2STR(_FILE+1) + ' out of ' + NUM2STR(N_ELEMENTS(FILES)) + ')'  
    IF N_ELEMENTS(PRODS)       EQ 0 THEN L2_PRODUCTS   = 'chlor_a'  ELSE L2_PRODUCTS = PRODS(_FILE)
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
    SATDATE = _NAME[0]
    IF N_ELEMENTS(FILE_LABEL) EQ 0 THEN _FILE_LABEL = SATDATE + '-' + SENSOR + '-' + METHOD ELSE _FILE_LABEL = FILE_LABEL(_FILE)
    EXT = STRUPCASE(FN.EXT)
    IF EXT EQ 'Z' OR EXT EQ 'GZ' OR EXT EQ 'BZ2' THEN IFILE = DIR_OUT + FN.NAME ELSE IFILE = DIR_OUT + FN.NAME_EXT 
    REMOVE_FILES = []
    
;   ***** Set up output names *****    
    L1A_FILE                 = DIR_OUT + SATDATE + '.L1A'
    L1B_FILE                 = DIR_OUT + SATDATE + '.L1B'    
    GEOFILE                  = DIR_OUT + SATDATE + '.GEO'    
    GEOPCF                   = GEOFILE + '.pcf'
    L1A_SUB                  = DIR_L1A_SUB + SATDATE + '.L1A_LAC_SUB'
    L1A_SUB_GZIP             = L1A_SUB + '.gz'
    L1A_SUB_BZIP             = L1A_SUB + '.bz2'
    GEO_SUB                  = DIR_GEO_SUB + SATDATE + '.GEO_SUB'    
    L2_FILE                  = DIR_OUT + _FILE_LABEL + '-L2.hdf'
    L2_GZIP                  = L2_FILE + '.gz'
    L2_BZIP                  = L2_FILE + '.bz2'
    PAR_FILE                 = L2_FILE + '.par'
    LOG_FILE                 = DIR_LOG + _FILE_LABEL + '.L2.log'
        
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
      IF FILE_TEST(L1B_FILE)         GE 1 THEN FILE_DELETE, L1B_FILE
      IF FILE_TEST(L2_FILE)          GE 1 THEN FILE_DELETE, L2_FILE
      IF FILE_TEST(L2_FILE + '.gz')  GE 1 THEN FILE_DELETE, L2_FILE + '.gz'
      IF FILE_TEST(L2_FILE + '.bz2') GE 1 THEN FILE_DELETE, L2_FILE + '.bz2'
      IF FILE_TEST(L2_FILE + '.GZ')  GE 1 THEN FILE_DELETE, L2_FILE + '.GZ'
      IF FILE_TEST(L2_FILE + '.BZ2') GE 1 THEN FILE_DELETE, L2_FILE + '.BZ2'
    ENDIF
    
;   ***** Check to see if files exist *****
    IF _LEVEL EQ 'L1A' AND _SENSOR EQ 'MODIS' THEN BEGIN      
      IF TOTAL(FILE_TEST([L2_FILE,L2_GZIP,L2_BZIP])) GE 1 THEN GOTO, SKIP_L2
      IF FILE_TEST(L1B_FILE) EQ 1 THEN GOTO, SKIP_L1B
      IF TOTAL(FILE_TEST([L1A_SUB,L1A_SUB_GZIP,L1A_SUB_BZIP])) GE 1 AND FILE_TEST(GEO_SUB) EQ 1 AND KEYWORD_SET(DO_SUBSET) THEN GOTO, SKIP_SUBSET
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
        PRINT, 'Making geolocation file for : ' + IFILE + ' (' + NUM2STR(_FILE+1) + ' out of ' + NUM2STR(N_ELEMENTS(FILES)) + ')'
        GEOCOUNTER = 0
        RERUN_GEOGEN_MODIS:
        IF FILE_TEST(GEOFILE) NE 1 THEN $   ; If ATTEPH files are to be downloaded during processing, then turn off the /disabledefinftp, /disablepredftp keywords
          GEOGEN_MODIS, IFILE=IFILE, GEOFILE=GEOFILE,/WAIT,/VERBOSEHTTP,/SAVELOG          
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
        IF KEYWORD_SET(DO_SUBSET) THEN BEGIN 
          PRINT, 'Subsetting the L1A and GEOLOCATION files on ' + IFILE + ' (' + NUM2STR(_FILE+1) + ' out of ' + NUM2STR(N_ELEMENTS(FILES)) + ')'
          IF FILE_TEST(IFILE) EQ 0 THEN GOTO, COPY_L1A
          IF FILE_TEST(L1A_SUB) NE 1 OR FILE_TEST(GEO_SUB) NE 1 THEN $
            L1AEXTRACT_MODIS, IFILE=IFILE, GEOFILE=GEOFILE, OFILE=L1A_SUB, OUTGEO=GEO_SUB,$
            SWLAT=SWLAT, SWLON=SWLON, NELAT=NELAT, NELON=NELON,/WAIT          
          REMOVE_FILES = [REMOVE_FILES,GEOFILE,GEOPCF]
          SKIP_SUBSET:
          IFILE = L1A_SUB
          GEO_FILE = GEO_SUB    
          IF KEYWORD_SET(SUBSET_ONLY) THEN GOTO, SKIP_L2      
        ENDIF
        

;      ***** Make L1B from L1A and GEOLOCATION files *****
        IF FILE_TEST(L1B_FILE) EQ 0 THEN BEGIN
          IF FILE_TEST(GEO_FILE) EQ 0 THEN CONTINUE
          PRINT, 'Running modis l1bgen on ' + IFILE + ' (' + NUM2STR(_FILE+1) + ' out of ' + NUM2STR(N_ELEMENTS(FILES)) + ')'
          ;MODIS_L1BGEN, IFILE = IFILE, GEOFILE=GEO_FILE, OFILE=L1B_FILE, FILEHKM=HKM_FILE, FILEQKM=QKM_FILE, /WAIT
          L1BGEN_MODIS, IFILE=IFILE, GEOFILE=GEO_FILE, OFILE=L1B_FILE,/DELETEHKM,/DELETEQKM, /WAIT
          IF FILE_TEST(L1B_FILE) EQ 0 THEN BEGIN
            OPENW,LUN,LOG_FILE,/GET_LUN
            PRINTF,LUN, 'ERROR: CAN NOT PROCEDE WITH MSL12, '+L1B_FILE+' NOT FOUND'
            CLOSE,LUN  
            FREE_LUN, LUN, /FORCE 
            CONTINUE
          ENDIF
          SKIP_L1B:
          IFILE = L1B_FILE
        ENDIF ELSE IFILE = L1B_FILE
        IF KEYWORD_SET(L1B_ONLY) THEN GOTO, SKIP_L2
        REMOVE_FILES = [REMOVE_FILES,L1B_FILE]
      ENDIF ; IF SENSOR EQ 'MODIS'
      
      IF _SENSOR EQ 'CZCS' THEN BEGIN  
        IF FILE_TEST(L1B_FILE) EQ 0 THEN BEGIN
          L1BGEN, 2, IFILE=IFILE, OFILE=L1B_FILE,/WAIT
          IF FILE_TEST(L1B_FILE) EQ 0 THEN BEGIN
            OPENW,LUN,LOG_FILE,/GET_LUN
            PRINTF,LUN, 'ERROR: CAN NOT PROCEDE WITH MSL12, '+L1B_FILE+' NOT FOUND'
            CLOSE,LUN  
            FREE_LUN, LUN, /FORCE            
            CONTINUE
          ENDIF
          IFILE = L1B_FILE
        ENDIF ELSE IFILE = L1B_FILE
        REMOVE_FILES = [REMOVE_FILES,IFILE]
      ENDIF ; IF SENSOR EQ 'CZCS'  
    ENDIF  ;IF LEVEL EQ 'L1A' THEN BEGIN


;   ****************************************************************************************************

;   ***** L 2 G E N (SeaDAS 6.2) *****    
    PRINT, ' sensor : ', _SENSOR,'      input_file: ',ifile,'      l2_file: ',l2_file
    PRINT, 'l2_products : '
    PRINT, l2_products    
    PRINT, 'Creating file ' + L2_FILE + ' (' + NUM2STR(_FILE+1) + ' out of ' + NUM2STR(N_ELEMENTS(FILES)) + ')'  
    PRINT, 'Running l2gen on ', IFILE
;    
      l2gen,                         $
;     sat_id,                        $
      ifile=ifile,                   $  ; input L1 file
      ofile1=l2_file,                $  ; output file
      geofile=geo_file,              $  ; input geolocation file - note: only useable for MODIS      
;     par=pfile,                     $  ; input parameter file
;     par=MET_PAR_FILE,              $  ; note that multiple par files may be specified
      /wait,                         $  
;     help=hlp,                      $  
;     eval=1,                        $  ; default=0
;     group=group,                   $  ; default=
;     disableftp=1,                  $  
;     slat=slat,                     $  ; default=
;     elat=elat,                     $  ; default=
;     slon=slon,                     $  ; default=
;     elon=elon,                     $  ; default=
;      aer_opt=5, $ ; TEMP for CZCS 6.2 processing
;      aermodels=r70f10v01, $ ; TEMP for CZCS 6.2 processing
;      aermodmax=1, $ ; TEMP for CZCS 6.2 processing
;      aermodmin=1, $ ; TEMP for CZCS 6.2 processing 
;     aer_iter_max=10,               $  ; default=10
;     aer_opt=aer_opt,               $  ; default for seawifs is -3,choices are: 1-12,0,-1,-2,-3,-4,-9 (-9 is for SWIR correction)
;     aer_wave_short=aer_wave_short, $  ; default = 748 (MODIS)
;     aer_wave_long=aer_wave_long,   $  ; default = 869 (MODIS)
;     aer_swir_short=aer_swir_short, $  ; default = 1240 (MODIS-SWIR)
;     aer_swir_long=aer_swir_long,   $  ; default = 2130 (MODIS-SWIR)
;     albedo=0.027,                  $  ; default= 0.027
;     atmocor = 1,                   $  ; default= 1
;     brdf_opt=brdf_opt,             $  ; default for seawifs = 7
;     chlclark_coef=chlclark_coef,   $
;     chlclark_wave=chlclark_wave,   $
;     chloc2_coef=chloc2_coef,       $
;     chloc2_wave=chloc2_wave,       $
;     chloc3_coef=chloc3_coef,       $
;     chloc3_wave=chloc3_wave,       $
;     chloc4_coef=chloc4_coef,       $
;     chloc4_wave=chloc4_wave,       $
      ctl_pt_incr=1,                 $  ; default=8
;     dline=1,                       $  ; default=1
;     dpixl=1,                       $  ; default=1
;     eline=0,                       $  ; default=last line number
;     epixl=0,                       $  ; default=the last pixel
;     epsmin=epsmin,                 $  ; default=0.85
;     epsmax=epsmax,                 $  ; default=1.35
;     filter_file=filter_file,       $  ; default='$MSL12_DATA/seawifs/seawifs_filter.dat'
;     filter_opt=0,                  $  ; default=1 for OCTS, 0 otherwise
;     gain=gain,                     $  ; default='0.9710,0.9848,1.0020,0.9795,0.9870,0.9850,0.9842,1.0049,0.9797,0.9776,0.9855,1.0304,1.000,1.055,1.000,1.115',         $  ;
;     gas_opt=gas_opt,               $  ; default=1 (ozone)
;     glint_opt=glint_opt,           $  ; default=1
;     glint_thresh=glint_thresh,     $  ; default=0.005
;     icefile=icefile,               $  ; default=$OCDATAROOT/common/ice_mask.hdf
;     ice_threshold=ice_threshold,   $  ; defualt=0.1
      l2prod1=l2_products,           $  ; default= "chlor_a,K_490,tau_865,eps_78,angstrom_510,l2_flags,nLw_412,nLw_443,nLw_490,nLw_510,nLw_555,nLw_670"
;     l2prod2=l2prod2,               $
;     l2prod3=l2prod3,               $
;     l2prod4=l2prod4,               $
;     land=land,                     $  ; default=$OCDATAROOT/common/landmask.dat
      maskland=0,                    $  ; default=1
      maskbath=0,                    $  ; default=0
      maskcloud=0,                   $  ; default=1
      maskglint=0,                   $  ; default=0
      masksunzen=0,                  $  ; default=0
      masksatzen=0,                  $  ; default=0
      maskhilt=0,                    $  ; default=1
      maskstlight=0,                 $  ; default=0
;     met1=met1,                     $  ; default=$OCDATAROOT/common/met_climatology.hdf
;     met2=met2,                     $
;     met3=met3,                     $
      metsearch=1,                   $  ;
;     nlwmin=nlwmin,                 $  ; default= 0.15
;     no2file=no2file,               $  ; default=$OCDATAROOT/common/no2_climatology.hdf
;     offset=offset,                 $  ; default='[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]'
;     ofile2=ofile2,                 $
;     ofile3=ofile3,                 $
;     ofile4=ofile4,                 $
;     outband_opt=outband_opt,       $  ; default=1 (0:correct Lr,1:correct Lr and La,2:correct Lr La Lw nlw)
;     ozone1=ozone1,                 $  ; default=$OCDATAROOT/common/ozone_climatology.hdf
;     ozone2=ozone2,                 $
;     ozone3=ozone3,                 $
      ozonesearch=1,                 $  ;
;     ozoneover=ozoneover,           $  ; default= -1000
;     pol_opt=pol_opt,               $
;     pressure=pressure,             $  ; default= -1000
;     proc_land=proc_land,           $  ; default= 0
;     proc_ocean=proc_ocean,         $  ; default= 1
      proc_sst=0,                    $  ; turn SST processing off - MODIS Only
;     qaa_opt=qaa_opt,               $
;     qaa_s=qaa_s,                   $
;     relhumid=relhumid,             $  ; default= -1000
      resolution=1000,               $  ; default= 1000
;     rhoamin=rhoamin,               $  ; default= 0.0001
;     satzen=satzen,                 $  ; default= 60.0
;     sl_frac=sl_frac,               $  ; default= 0.25
;     sl_pixl=sl_pixl,               $  ; default=3  for LAC, =4 for GAC
;     sline=sline,                   $  ; default=1
;     spixl=spixl,                   $  ; default=1
;     sstfile=sstfile,               $  ; (default=$OCDATAROOT/common/sst_climatology.hdf
      sstsearch=1                       ;
;     sunzen=sunzen                  $  ; default= 75.0
;     tau_a=tau_a,                   $  ;
;     tauamax=tauamax,               $  ; default= 0.30
;     water=water,                   $  ; default=$OCDATAROOT/common/watermask.dat
;     watervaporover=watervaporover, $  ; default= -1000
;     windangle=windangle,           $  ; default= -1000
;     windspeed=windspeed,           $  ; default= -1000
;     wsmax=wsmax                       ; default= 8.0
    PRINT, routine_name + ' Finished creating: ' + L2_FILE
    SKIP_L2:
        
    IF FILE_TEST(PAR_FILE) EQ 1 THEN FILE_MOVE, PAR_FILE, DIR_PAR, /OVERWRITE    
        
  ; ***** Compress L2 file  *****  
    IF NOT KEYWORD_SET(SKIP_ZIP) AND FILE_TEST(L2_FILE) EQ 1 THEN BEGIN
      PRINT,'COMPRESSING L2 File'
      zip, files=l2_file,/bzip,/keep_ext  
      FILE_DELETE,L2_FILE
    ENDIF  
    IF REMOVE_FILES NE [] THEN OK = WHERE(FILE_TEST(REMOVE_FILES) EQ 1,COUNT) ELSE COUNT = 0
    IF COUNT GE 1 THEN FILE_DELETE,REMOVE_FILES[OK]
  
    DONE:    
    PRINT, routine_name + ' Finished processing: ' + AFILE 
        
  ENDFOR  ; FOR FILE
  
  
END




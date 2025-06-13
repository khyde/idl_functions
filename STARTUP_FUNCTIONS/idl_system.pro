; $ID:	IDL_SYSTEM.PRO,	2023-09-21-13,	USER-KJWH	$
;###################################################################################     
PRO IDL_SYSTEM, TEST=TEST
;+
;	NAME:
;   IDL_SYSTEM
;
;	PURPOSE: 
;	  This procedure establishes a system variable (!S) for the IDL session and is set to run with each new IDL session.  
;	  The !S structure contains frequently used directores and constants used in the local IDL programs.  
;	    
; CATEGORY:
;   UTILITIES
;
; CALLING SEQUENCE:
;   IDL_SYSTEM
;   
; REQUIRED INPUTS:
;   None
;   
; OPTIONAL INPUS:
;   None
;   
; KEYWORD PARAMETERS
;   TEST........ To "test" the creation of the structure, but won't replace !S     
; 
; OUTPUTS
;   Creates a structure in the system variable !S
;   
; OPTIONAL OUTPUTS
;   None
; 
; COMMON BLOCKS:
;   None
;
; SIDE EFFECTS:
;   It may not be possible to rerun without restarting IDL
;
; RESTRICTIONS:
;   None
;
; EXAMPLE:
;   IDL_SYSTEM
; 
; NOTES:
;   More information on System Variables available here: https://www.harrisgeospatial.com/docs/System_Variables.html
;   Any user that intends to use this program will need to set up user specific information.
;   Should be included in the start-up file
;
; COPYRIGHT:
; Copyright (C) 2003, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR INFORMATION
;   This program was written on September 4, 2003 by J.E. O'Reilly Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;     and maintained by, Kimberly Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882 kimberly.hyde@noaa.gov
;
; MODIFICATION HISTORY:
;		NOV 05, 2013 - JEOR: PATH_SEP() ; IF COMPUTER EQ 'LAPSANG' THEN DIR_IDL = GET_PATH()  + 'IDL' + PATH
;		NOV 10, 2013 - JEOR: REPLACED DB WITH MASTER 
;		DEC 10, 2013 - KJWH: ADDED DIR_DEMO, DIR_LANDMASKS, DIR_SUBAREAS, DIR_OUTLINE AND REMOVED DIR_TEST
;		DEC 11, 2013 - KJWH: MOVED THE DEFSYSV !S EXISTS CHECK TO THE BEGINNING 
;		DEC 11, 2013 - KJWH: ADDED DIR_TEST TO MAKE SURE ALL DIRECTORIES EXIST
;		DEC 12, 2013 - KJWH: ADDED DIR_MAIN AND UPDATED ASSOCIATED DIRECTORIES
;		                     ADDED COMPATIBITIY FOR KHYDE'S MAC LAPTOP
;		                     REMOVED UNNECESSARY "IF COMPUTER EQ" CALLS
;		DEC 17, 2012 - KJWH: ADDED DIR_SHAPEFILES    
;		JAN 07, 2014 - KJWH: ADDED MORE OPTIONS FOR KHYDE'S MAC LAPTOP   
;		MAR 05, 2014 - KJWH: ADDED DIR_MAPAREAS   
;		MAR 24, 2014 - JEOR: REMOVED THE PREFIX 'DIR_' FROM THE STRUCTURE TAG NAMES   
;		MAR 26, 2014 - KJWH: ADDED DIR_LOGS 
;   APR 17, 2014 - JEOR: IF COMPUTER EQ 'OOLONG' THEN DIR_MAIN = GET_PATH()  
;                        ADDED OBSOLETE FOLDER
;   MAY 6,  2014 - KJWH: FIXED BUG WITH MAC WHEN ON VPN 
;                        ADDED CD,DIR_PROGRAMS TO MAKE SURE THE CURRENT DIRECTORY IS !S.PROGRAMS   E
;   NOV 17, 2014 - KJWH: CHANGED OBSOLETE TO PROGRAMS_OBSOLETE  
;   NOV 20, 2014 - JEOR: IF COMPUTER NE 'NECDNAKHYDE'          THEN DIR_TEST, DIRS     
;   NOV 20, 2014 - KJWH: ADDED DIR_LOCAL FOR MAC       
;   OCT 30, 2015 - KJWH: ADDED DIR_FILES - A SUBDIRECTORY IN DEMO TO KEEP SAMPLE FILES
;   NOV 24, 2015 - KJWH: ADDED USER (KJWH OR JOR) BASED ON COMPUTER
;   DEC 15, 2015 - KJWH: ADDED DIR_SCRIPTS
;   DEC 15, 2015 - JEOR: ADDED DIR_TOPO 
;   DEC 17, 2015 - KJWH: ADDED DIR_MODIS
;   DEC 23, 2015 - JEOR: CHANGED DIR_BATHY:  DIR_BATHY = DIR_IDL + 'TOPO' + PATH +  'DEG'  + PATH
;   JUL 19, 2016 - KJWH: CHANGED DIR_MAPAREAS TO DIR_MAPINFO
;   AUG 29, 2016 - KJWH: ADDED DIR_GLOBAL TO HOLD THE GLOBAL INFORMATION FOR SENSOR SPECIFIC PRODS
;   NOV XX, 2016 - KJWH: ADDED DIR_FRONTS 
;   FEB 07, 2017 - KJWH: ADDED DIR_PPD
;   FEB 22, 2017 - KJWH: ADDED DIR_ARCHIVE FOR THE OLD ARCHIVED DATA FILES
;   FEB 28, 2017 - KJWH: CHANGED JEOR TO JEOR
;   MAR 14, 2107 - KJWH: REMOVED REFERENCES TO OLD COMPUTERS AND ADDED A CHECK FOR WHEN KIM'S LAPTOP IS CONNECTED VIA VPN
;   AUG 01, 2017 - KJWH: CHANGED THE !S.FRONTS SERVER TO BE DIR_SEADAS INSTEAD OF DIR_MAIN
;   AUG 18, 2017 - KJWH: CHANGED THE !S.PPD SERVER TO BE DIR_SEADAS INSTEAD OF DIR_MAIN
;   DEC 04, 2017 - KJWH: Changed the location of the !S.PPD and !S.FRONTS to DIR_DATASETS
;                        Added !S.SST and !S.OC directories 
;   DEC 07, 2017 - KJWH: Added DIR_SST and DIR_OC to the !S structure
;   DEC 08, 2017 - KJWH: Updated the DIR_ARCHIVE location
;   DEC 18, 2017 - KJWH: Added DIR_DAY_LENGTH
;   NOV 02, 2018 - KJWH: Added a directory for SUBAREAS_EXTRACTS (!S.EXTRACTS)
;   NOV 19, 2018 - KJWH: Added PID to the output structure
;   NOV 26, 2018 - KJWH: Changed DIR_LOGS from nadata/IDL/LOGS to /nadata/LOGS
;   MAR 05, 2019 - KJWH: Added DIR_NETCDF directory
;   AUG 22, 2019 - KJWH: Added DIR_PALS directory and removed DIR_SEADAS and DIR_MODIS
;   JUN 03, 2020 - KJWH: Overhauled IDL_SYSTEM to work with the new "PROJECT" focused structure
;                        Now automatically adds some directories found within specified folders (previously they were added manually)
;   JUN 26, 2020 - KJWH: Changed subscripts from () to []
;                        Added COMPILE_OPT IDL2    
;   SEP 25, 2020 - KJWH: Added IDL_TEST      
;   SEP 21, 2021 - KJWH: Moved the MASTER directory out of IDL_DATA to be IDL_MASTER 
;                        Updated documentation     
;   OCT 12, 2021 - KJWH: Fixed error with the IDL_FUNCTIONS directories in the structure     
;   OCT 14, 2021 - KJWH: Added steps to ignore specific directories found within IDL_GIT (IGNORE_DIRS = ['idl-coyote'])     
;   JAN 05, 2024 - KJWH: Changed IDLGIT to IDL_MAIN                                                           
;                      
;###################################################################################     
;-

  ROUTINE_NAME  = 'IDL_SYSTEM'
  COMPILE_OPT IDL2
  SL = PATH_SEP()  ; Get the correct "slash" for directory names

  DEFSYSV, '!S', EXISTS = EXISTS                            ; Check if system variable !S exists 
  IF EXISTS EQ 1 AND ~KEYWORD_SET(TEST) THEN BEGIN                                 
    IF ~KEYWORD_SET(OVERWRITE) THEN GOTO, DONE              ; If it exists and OVERWRITE is not set, then skip
    MESSAGE, 'Need to determine how to overwrite an existing system variable'   ; Null out the !S variable to recreate
  ENDIF

; ===> Initialize the struction with user information based on the USERNAME    
  SPAWN, 'whoami', USERNAME                                 ; Get the user name information
  RESET_USERNAME:
  CASE USERNAME OF
    'khyde': S = CREATE_STRUCT('USER',USERNAME[0],'INITIALS','KJWH', 'AUTHOR','Kimberly J. W. Hyde', 'EMAIL','kimberly.hyde@noaa.gov', $
                               'AFFILIATION','Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce', $
                               'ADDRESS','28 Tarzwell Dr, Narragansett, RI 02882') 
    'kimberly.hyde': BEGIN & USERNAME = 'khyde' & GOTO, RESET_USERNAME & END
    'abc': BEGIN &  USERNAME = 'khyde' & GOTO, RESET_USERNAME & END
    'hsynan': S = CREATE_STRUCT('USER',USERNAME[0],'INITIALS','HES', 'AUTHOR','Haley E. Synan', 'EMAIL','haley.synan@noaa.gov', $
      'AFFILIATION','Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce', $
      'ADDRESS','28 Tarzwell Dr, Narragansett, RI 02882') 
    'nmfs\haley.synan': BEGIN & USERNAME = 'hsynan' & GOTO, RESET_USERNAME & END
    'nefsc': BEGIN & USERNAME = 'khyde' & GOTO, RESET_USERNAME & END
    ELSE: MESSAGE, 'ERROR: ' + USERNAME + ' not found.  Must enter information to IDL_SYSTEM.pro'
  ENDCASE

  ; ===> Get the MAIN directory structure based on the OS and/or COMPUTER name
  OS = STRUPCASE(!VERSION.OS_FAMILY)                        ; Get information about the operating system
  SPAWN, 'hostname', COMPUTER                               ; Get the name of the computer
  COMPUTER=STRUPCASE(COMPUTER)
  CASE OS OF
    'UNIX': BEGIN
      CASE COMPUTER OF
        'NECLWHKHYDEMAC.LOCAL': IF FILE_TEST('/Volumes/nadata/',/DIR) THEN PATH = '/Volumes/nadata/' ELSE PATH = '/Users/khyde/nadata/'
        'NECLNAMAC94512.LOCAL': PATH = '/Users/kimberly.hyde/nadata/'
        'NECLNAMAC94512.LOCALDOMAIN': PATH = '/Users/kimberly.hyde/nadata/'
        'SATDATA': PATH = '/nadata/'
        'MODIS': PATH = '/nadata/'
        'LUNA': PATH = '/nadata/'
        'FC04347D5C0F': PATH = '/Satdata_Primary/nadata/'
        'ED00753D5F52': PATH = '/Satdata_Primary/nadata/'
        'FD91437AA6DB':PATH = '/Satdata_Primary/nadata/'
        '92A61AB41D2A': BEGIN & PATH = '/mnt/EDAB_Archive/nadata/' & SPATH = '/mnt/EDAB_Datasets/' & END
        'NEFSCSATDATA.NMFS.LOCAL': PATH = '/Satdata_Primary/nadata/'
        'NECMAC04363461.LOCAL': BEGIN & PATH = '/Users/kimberly.hyde/Documents/nadata/' & SPATH = '/Users/kimberly.hyde/Documents/nadata/DATASETS_SOURCE/' & END
        ELSE: MESSAGE, 'ERROR: ' + COMPUTER + ' not found.  Must enter directory path information to IDL_SYSTEM.pro'
      END
      PID = GET_IDLPID()
    END
    'WINDOWS': BEGIN
     ; MESSAGE, 'ERROR: Must set up Windows/computer specific directory information.'
    CASE COMPUTER OF
    'NECL04740467': PATH = 'C:\Users\haley.synan\Documents\nadata\'
    ENDCASE
      PID = ''
    END
  ENDCASE
  IF SPATH EQ [] THEN SPATH = PATH
  IF FILE_TEST(PATH,/DIR) EQ 0 THEN MESSAGE, 'ERROR: ' + PATH + ' does not exist.  Check location of the PATH and rerun.'

; ===> Fill in the computer information to the structure
  S = CREATE_STRUCT(S,'COMPUTER',COMPUTER[0],'OS',OS,'PID',PID,'PATH',PATH)
  
  IF COMPUTER EQ 'NECLWHKHYDEMAC.LOCAL' THEN S = CREATE_STRUCT(S,'LOCAL','/Users/khyde/nadata/')
  
; ===> Add the basic directory information to the structure
  S = CREATE_STRUCT(S,'ARCHIVE', SL + 'Satdata_Archive' + SL + 'nadata_ARCHIVE' + SL + 'DATASETS_ARCHIVE' + SL, $
                      'DATASETS_SOURCE',SPATH)
  MAINDIRS = ['PROJECTS','DATASETS','SCRIPTS','LOGS']
  FOR M=0, N_ELEMENTS(MAINDIRS)-1 DO S = CREATE_STRUCT(S,MAINDIRS[M],PATH + MAINDIRS[M] + SL)

  SUBDIRS = ['DATASETS','DATASETS_SOURCE','PROJECTS'];,'SCRIPTS']
  TAGS = TAG_NAMES(S)
  FOR N=0, N_ELEMENTS(SUBDIRS)-1 DO BEGIN
    OK = WHERE(TAGS EQ SUBDIRS[N],COUNT)
    IF COUNT EQ 0 THEN MESSAGE, 'ERROR: ' + SUBDIRS[N] + ' not found.'    
    DIRS = GET_DIRS(S.(OK))
    FOR F=0, N_ELEMENTS(DIRS)-1 DO BEGIN
      ADIR = DIRS[F]  
      IF ADIR EQ 'Default' THEN CONTINUE
      ANAME = REPLACE(ADIR,['-',SL,':'],['_','',''])
      IF SUBDIRS[N] EQ 'DATASETS_SOURCE' THEN ANAME = ANAME + '_SOURCE'
      S = CREATE_STRUCT(S,ANAME,PATH+SUBDIRS[N]+SL+DIRS[F])
      IF ANAME EQ 'GIT_PROJECTS' OR ANAME EQ 'IDL_PROJECTS' OR ANAME EQ 'ACTIVE_PROJECTS' THEN BEGIN
        SDIRS = GET_DIRS(S.(OK) + ADIR)
        FOR R=0, N_ELEMENTS(SDIRS)-1 DO BEGIN
          SNAME = REPLACE(SDIRS[R],['-',SL,':'],['_','',''])
          S = CREATE_STRUCT(S,SNAME,PATH+SUBDIRS[N]+SL+ANAME+SL+SDIRS[R])
        ENDFOR
      ENDIF 
    ENDFOR ; DIRS
  ENDFOR ; SUBDIRS
  
; ===> Add the IDL specific directories 
  S = CREATE_STRUCT(S,'IDL',PATH + 'IDL' + SL)
 ; S = CREATE_STRUCT(S,'PROGRAMS',S.IDL + 'PROGRAMS' + SL) ; 2020-06-03 Will need to include the main programs directory until the transition to the new "project" based organization is complete
  SUBDIR = S.IDL
  IDLDIRS = GET_DIRS(SUBDIR, SEARCH_STRING='*')
  IGNORE_DIRS = ['idl-coyote']
  FOR F=0, N_ELEMENTS(IDLDIRS)-1 DO BEGIN
    IF IDLDIRS[F] EQ 'Default' THEN CONTINUE
    NAME = REPLACE(IDLDIRS[F],SL,'')
    S = CREATE_STRUCT(S,NAME,SUBDIR+NAME+SL)
    IF NAME EQ 'RESOURCES' THEN BEGIN
      GDIRS = GET_DIRS(SUBDIR+NAME+SL)
      FOR G=0, N_ELEMENTS(GDIRS)-1 DO BEGIN
        GNAME = REPLACE(GDIRS[G],SL,'')
        IF WHERE(GNAME EQ IGNORE_DIRS,/NULL) NE [] THEN CONTINUE ; If the name matches one of the directory names to be ignorned, then skip this step
        S = CREATE_STRUCT(S,'IDL_'+GNAME,SUBDIR+NAME+SL+GNAME+SL)
        IF GNAME EQ 'FUNCTIONS' OR GNAME EQ 'FILES' OR GNAME EQ 'IDL_DATA' OR GNAME EQ 'IDL_TEST' THEN BEGIN
          DIRS = GET_DIRS(SUBDIR+NAME+SL+GDIRS[G])
          FOR N=0, N_ELEMENTS(DIRS)-1 DO BEGIN
            DIRNAME = REPLACE(DIRS[N],SL,'')  ; Remove the ending "/" 
            S = CREATE_STRUCT(S,DIRNAME, SUBDIR+NAME+SL+GNAME+SL+DIRNAME+SL) 
          ENDFOR ; DIRS
        ENDIF ; IDL_FUNCTION/IDL_DATA  
      ENDFOR ; GDIRS
    ENDIF ; IDL_MAIN
    IF NAME EQ 'IDL_DATA' OR NAME EQ 'IDL_TEST' THEN BEGIN
      DIRS = GET_DIRS(S.IDL+IDLDIRS[F]+SL)
      FOR N=0, N_ELEMENTS(DIRS)-1 DO BEGIN
        IF DIRS[N] EQ '' THEN CONTINUE
        DIRNAME = REPLACE(DIRS[N],SL,'')  ; Remove the ending "/" 
        S = CREATE_STRUCT(S,DIRNAME, S.IDL+NAME+SL+DIRNAME+SL) 
      ENDFOR ; DIRS
    ENDIF ; IDL_FUNCTION/IDL_DATA
  ENDFOR ; IDLDIRS
  
; ===> Manually add missing directories
;  S = CREATE_STRUCT(S,'IDL_DEMO_FILES', S.IDL_DEMO + 'FILES' + SL)
;  S = CREATE_STRUCT(S,'IDL_BATHY', S.IDL_TOPO + 'DEG' + SL)
  
; ===> Store structure as an IDL system variable and make a copy of the other system variables
	 IF ~KEYWORD_SET(TEST) THEN BEGIN
  	 DEFSYSV, '!S',   S	 
  	 DEFSYSV, '!S_', !S
     DEFSYSV, '!P_', !P
  	 DEFSYSV, '!X_', !X
  	 DEFSYSV, '!Y_', !Y
  	 DEFSYSV, '!Z_', !Z
   ENDIF ELSE ST, S
  DONE:
  
  PRINT, 'Finished making !S structure'

END; #####################  END OF ROUTINE ################################


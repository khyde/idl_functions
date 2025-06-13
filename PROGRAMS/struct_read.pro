; $ID:	STRUCT_READ.PRO,	2020-07-08-12,	USER-KJWH	$
;+
;############################################################################################################
	FUNCTION STRUCT_READ, FILE, TAG=TAG, STRUCT=STRUCT, NO_STRUCT=NO_STRUCT, MAP_OUT=MAP_OUT, SUBS=SUBS, BINS=BINS, MASK=MASK, COUNT=COUNT,ERROR=ERROR

; THIS FUNCTION READS THE STRUCT MADE BY: STRUCT_WRITE,STATS_WRITE, & STRUCTURES MADE USING STRUCT_SD_WRITE
; 
;	INPUT:
;		FILE: 	THE FULL PATH AND NAME FOR THE FILE
;
;	OUTPUT:  A STRUCTURE WITH EITHER ALL [DEFAULT] OR SOME OF THE TAGS MADE BY STRUCT_WRITE [IF KEYWORD TAGS USED]
;	         OR THE DATA ARRAY IF STRUCT_SD_WRITE WAS USED TO MAKE THE STATS STRUCTURE
;		
;	KEYWORDS:
;	  TAG........	THE NAME[S] OF THE STANDARD TAGS TO EXTRACT ('NUM','MIN','MAX','SPAN','NEG','WTS','SUM','SSQ','MEAN','STD','CV')
;               ALLOWABLE TAGS FROM STATS_ARRAYS = ['NUM','MIN','MAX','NEG','WTS','SUM','SSQ','MEAN','VAR','STD','CV','SPAN']
;   STRUCT..... THE ENTIRE STRUCTURE INFO IS PLACED INTO STRUCT
;		MAP_OUT.... REMAP TO MAP_OUT
;		SUBS....... SUBSCRIPTS OF NON-MISSING DATA
;		BINS....... BIN NUMBERS FOR L3B FILES
;		ERROR...... TEXT ERROR MESSAGES
;
; 	MODIFICATION HISTORY:
;   MAY 24,2014,JOR COPIED  FROM STATS_READ AND MODIFIED TO BE GENERIC
;   JUL 21,2014,JOR INITIALIZE TYPE TYPE = 'RESTORE'
;   JUL 26,2014,JOR REFINED CRITERIA FOR TYPE STRUCT_SD_WRITE
;   OCT 12,2014,JOR :IF FILE_TEST(FILE) EQ 0 THEN FILE = DIALOG_PICKFILE(FILTER = ['*.SAV','*.SAVE'])
;   JAN 21,2015,JOR ADDED KEY MAP_OUT & REMOVED KEY ERROR[NOT NEEDED]
;   FEB 12,2015,JOR, MODS TO BETTER HANDLE NESTED AND UNNESTED SAVES FROM STRUCT_SD_WRITE
;   FEB 13,2015,JOR  IF N_TAGS(STRUCT) EQ 1 THEN UNNEST THE STRUCT 
;   MAR 2,2015,JOR  ADDED STRUCT_GET TO RETRIEVE A SPECIFID TAG AS THE 'DATA'  
;                   IF KEY(TAG)THEN TYPE = 'GET_TAG'
;   MAR 6,2015,JOR  OVERHAULED AND STREAMLINED PROGRAM, 
;                   CHANGED LOGIC [CAN NOW RETURN A TAG FROM THE STRUCT]
;   MAR 15,2015,JOR   SPEED UP - BY NARROWING DOWN THE LIKELY TAG BASED ON TYPE OF INPUT STRUCT
;   MAR 16,2015,JOR& KJWH ADDED KEY SUBS
;   MAR 27,2015,JOR:IF KEY(MAP_OUT) AND MAP_OUT NE FA.MAP THEN BEGIN
;   MAR 30, 2015 - KJWH: ADDED COUNT=0 AS A DEFAULT
;   APR 15,2015,JOR ADDED KEY ERROR,CATCH ERROR HANDLER
;   JUL 15,2015,JOR CHANGED DEFINITION OF TYPE SPREAD [ NEED ONLY 2 OR MORE TAGS]:
;                   IF IDLTYPE(RESULT) EQ 'STRUCT' AND N_TAGS(RESULT) GE 2 THEN RETURN,RESULT
;   NOV 09, 2015 - KJWH: Added IF HAS(NAMES,  'MEAN',/EXACT) THEN TAG = 'MEAN' to 
;                        find the MEAN tag
;                        Added EXACT keyword to HAS(NAMES,'xxxx',/EXACT) 
;                        calls to only find the exact name in the structure 
;                        (fixed a bug when DATA was not in the structure, 
;                        but was returning a postive value from DATA_UNITS)
;                        Changed FILE_ALL(FILE) to PARSE_IT(FILE,/ALL)
;   NOV 24, 2015 - JEOR: REPLACED GET_TAG WITH STRUCT_GET, HAS_TAG WITH STRUCT_HAS
;   MAR 24, 2016 - KJWH: Changed MAP_REMAP to MAPS_REMAP
;   MAY 29, 2016 - JEOR: CHANGED VALID_MAPS TO VALIDS
;                        CHANGED NULL = NULL TO INIT=INIT IN CALL TO STRUCT_REMAP
;   FEB 02, 2017 - KJWH: Added BINS keyword to return the BIN numbers for L3B files if found in the structure      
;   FEB 16, 2017 - KJWH: Updated the REMAPPING section
;                        Added OR IF BINS NE [] to then IF statement determining whether the data can be remapped
;                        Updated the STRUCT_REMAP step, which is now a function        
;   MAR 03, 2017 - KJWH: Added IF N_TAGS(STRUCT) EQ 1 AND IDLTYPE(STRUCT.(0)) EQ 'STRUCT' THEN STRUCT = STRUCT.(0) to work with some of our old PPD .SAVE files                     
;   APR 25, 2017 - KJWH: If remapping, make BINS [] (NULL) after remapping
;                        Added keyword NO_STRUCT to skip the STRUCT_REMAP step if the structure is not needed (to speed up the program)
;   AUG 22, 2018 - KJWH: Added a MASK keyword to mask out specified subscripts from an image 
;                          IF KEY(MASK) THEN BEGIN
;                            IF (SIZEXYZ(RESULT)).N_DIMENSIONS EQ 2 OR BINS NE [] THEN BEGIN
;                              RESULT(MASK) = MISSINGS(RESULT)
;                            ENDIF
;                          ENDIF 
;   AUG 28, 2017 - KJWH: Fixed bug with adding the mask to L3B files.  Added: IF IS_L3B(STRUCT.MAP) THEN RESULT = MAPS_L3B_2ARR(RESULT,MAPP=STRUCT.MAP,BINS=STRUCT.BINS) to create a complete array of data
;                        Added TAGS loop to also add the mask to other 2D elements in the structure (adapted from STRUCT_REMAP)  
;   SEP 01, 2017 - KJWH: Updated the MASK step to only return the BINS with data.  
;                        Commented out the ERROR HANDLING/CATCH step because it was preventing me from debugging the errors in the MASK step   
;   SEP 08, 2017 - KJWH: Updated the calls to MAPS_L3B_2ARR (Changed MAPP to MP)     
;   SEP 08, 2017 - KJWH: Added steps in the MASKING block to get the mask subscripts when RESULT is a STRUCTURE         
;   MAY 14, 2018 - KJWH: Updated the LIKELY_TAGS logic and removed redundant code
;                          Now using WHERE_MATCH to look for the LIKELY_TAGS
;                          If more than one LIKELY_TAG is found, then the program will stop because it won't know which tag to use
;                          If no LIKELY_TAGS are found, then it will try to use the PROD name as the TAG 
;                            IF HAS(NAMES,'PROD',/EXACT) THEN TAG = STRUCT.PROD 
;                            Now if a structure contains 1 main product and additional ancilary products (e.g. FRONTS), the structure will return the data that corresponds to the PROD                                                                  
;   OCT 26, 2018 - KJWH: Added IF IDLTYPE(RESULT) EQ 'STRUCT' THEN RESULT = STRUCT in the MASK step so that the RESULT structure contains the subset data
;   MAY 20, 2019 - KJWH: Added CONTROL_LONS and CONTROL_LATS to MAPS_REMAP to work with LONLAT files (at least those created by SAVE_MAKE_FRONTS).
;   MAY 24, 2019 - KJWH: Added step to set up the CONTROL_LONS and CONTROL_LATS prior to the MAPS_REMAP call because not all structures have the LONS and LATS tags
;   JUL 08, 2020 - KJWH: Now remapping the entire output structure if MAP_OUT is provided and it is a nested structure output
;                        Added COMPILE_OPT IDL2
;                        Changed subscript () to []
;-
;############################################################################################################

  ROUTINE_NAME  = 'STRUCT_READ'
  COMPILE_OPT IDL2

;===> DEFAULTS
  COUNT=0L
  ERROR = []
  LIKELY_TAGS = ['DATA','MEAN','ARRAY','IMAGE'] ; PROGRAM WILL TRY TO FIND THESE TAGS WHEN NO TAG IS PROVIDED

;===> ERROR HANDLER [WHEN CAN NOT WRITE FILE] ETC.
;  CATCH, ERRORSTATUS
;  IF (ERRORSTATUS NE 0) THEN BEGIN
;    CATCH, /CANCEL
;    ERROR = !ERROR_STATE.MSG
;    PRINT, ERROR
;    RETURN,ERROR
;    ENDIF;IF (ERRORSTATUS NE 0) THEN BEGIN


  IF NONE(FILE) THEN FILE = DIALOG_PICKFILE(FILTER = ['*.SAV','*.SAVE'],/READ)
  FA = PARSE_IT(FILE,/ALL)

;===> ALWAYS RESTORE THE COMPLETE STRUCT ANY ERRORS IN RESTORING WILL BE RETURNED IN ERROR
  IF N_ELEMENTS(FILE) EQ 1  THEN STRUCT = IDL_RESTORE(FILE,ERROR=ERROR)

;===> IF NO TAGS THEN FILE IS PROBABLY A SIMPLE SAVEFILE ARRAY
  IF N_TAGS(STRUCT) EQ 0 THEN RETURN, STRUCT
  
;===> IF ONLY ONE TAG AND THAT TAG REPRESENTS A STRUCTURE, RETURN THAT STRUCTURE
  IF N_TAGS(STRUCT) EQ 1 AND IDLTYPE(STRUCT.(0)) EQ 'STRUCT' THEN STRUCT = STRUCT.(0)  

;===> LOGIC: IF TAG IS PROVIDED THEN EXTRACT RESULT FROM THAT TAG IN THE STRUCT ELSE SEE IF ONE OF THE "LIKELY_TAGS" IS IN THE STRUCT. 
;     IF NOT THEN RESULT EQUALS THE WHOLE STRUCT, BUT FIRST SEE IF WE CAN IDENTIFY THE LIKELY TAG BASED ON THE STRUCT:
  IF ~KEY(TAG) THEN BEGIN 
    NAMES = TAG_NAMES(STRUCT)
    OK = WHERE_MATCH(LIKELY_TAGS,NAMES,COUNT) ; Look for LIKELY_TAGS in the structure names
    CASE COUNT OF 
      0: IF HAS(NAMES,'PROD',/EXACT) THEN TAG = STRUCT.PROD ; Use the PROD name (if found) as the TAG
      1: TAG = LIKELY_TAGS[OK] ; Use the matched LIKELY_TAG
      ELSE: MESSAGE, 'ERROR: More than 1 "LIKELY TAG" was found in the structure'  ; LIKELY_TAGS will only work if there is 1 matching tag name 
    ENDCASE    
  ENDIF ; IF ~KEY(TAG) THEN BEGIN 

; ===> DETERMINE THE OUTPUT RESULT
  IF KEY(TAG) THEN IF STRUCT_HAS(STRUCT,TAG) THEN RESULT = STRUCT_GET(STRUCT,TAG) ; If the tag was found, then the RESULT is the data from that tag
  IF NONE(RESULT) THEN RESULT = STRUCT ; If the tag is not in the structure, then return the entire structure as the result
  
  IF STRUCT_HAS(STRUCT,'BINS') THEN BINS=STRUCT.BINS ELSE BINS=[]

;#########  REMAP  #########################################################################
  IF KEY(MAP_OUT)  THEN BEGIN
    IF VALIDS('MAPS',FA.NAME) NE '' AND VALIDS('MAPS',MAP_OUT) NE '' AND MAP_OUT NE FA.MAP  THEN BEGIN
      IF (SIZEXYZ(RESULT)).N_DIMENSIONS EQ 2 OR BINS NE [] THEN BEGIN
        IF HAS(STRUCT,'LONS') THEN CONTROL_LONS=STRUCT.LONS ELSE CONTROL_LONS=[]
        IF HAS(STRUCT,'LATS') THEN CONTROL_LATS=STRUCT.LATS ELSE CONTROL_LATS=[]
        IF ~KEY(NO_STRUCT) THEN REMAP_STRUCT = STRUCT_REMAP(STRUCT, MAP_OUT=MAP_OUT, INIT=INIT) ;===>  Remap the mapped arrays in the structure
        IF IDLTYPE(RESULT) NE 'STRUCT' THEN RESULT = MAPS_REMAP(RESULT, MAP_IN=FA.MAP, MAP_OUT=MAP_OUT, BINS=BINS, CONTROL_LONS=CONTROL_LONS, CONTROL_LATS=CONTROL_LATS) ; ===> Remap the RESULT array
        IF IDLTYPE(RESULT) EQ 'STRUCT' THEN IF ANY(REMAP_STRUCT) THEN RESULT = REMAP_STRUCT ELSE RESULT = STRUCT_REMAP(RESULT, MAP_OUT=MAP_OUT, INIT=INIT) ; ===> If the RESULT is a structure, then remap the entire structure
        IF IDLTYPE(REMAP_STRUCT) EQ 'STRUCT' THEN STRUCT = REMAP_STRUCT ELSE STRUCT = [] ;===> REPLACE THE STRUCT WITH THE REMAP_STRUCT
        IF IDLTYPE(STRUCT) EQ 'STRUCT' THEN IF HAS(STRUCT,'BINS') THEN STRUCT.BINS = MISSINGS(STRUCT.BINS)
        BINS = []
      ENDIF;IF (SIZEXYZ(RESULT)).N_DIMENSIONS EQ 2 THEN BEGIN
    ENDIF;IF VALID_MAPS(FA.NAME) NE '' AND VALID_MAPS(MAP_OUT) NE ''  THEN BEGIN
  ENDIF;IF KEY(MAP_OUT) THEN BEGIN
    
 ; #########  MASK  #########################################################################
   IF KEY(MASK) THEN BEGIN
     _MASK = MASK
     IF (SIZEXYZ(RESULT)).N_DIMENSIONS EQ 2 OR BINS NE [] AND IDLTYPE(RESULT) NE 'STRUCT' THEN BEGIN
       IF IS_L3B(STRUCT.MAP) THEN RESULT = MAPS_L3B_2ARR(RESULT,MP=STRUCT.MAP,BINS=STRUCT.BINS)
       RESULT[_MASK] = MISSINGS(RESULT)
       OK_GOOD = WHERE(RESULT NE MISSINGS(RESULT),COUNT_GOOD,/NULL)
       IF COUNT_GOOD EQ 0 THEN GOTO, SKIP_MASK
       IF IS_L3B(STRUCT.MAP) THEN BEGIN
         RESULT = RESULT(OK_GOOD)
         BINS = MAPS_L3B_BINS(STRUCT.MAP)
         BINS = BINS(OK_GOOD)
       ENDIF   
     ENDIF
     
     NEW = []
     TAGS = TAG_NAMES(STRUCT)
     IF NONE(OK_GOOD) THEN BEGIN ; WHEN "RESULT" IS A STRUCTURE
       FOR TT=0, N_TAGS(STRUCT)-1 DO BEGIN ; Loop through the STRUCT tags
         IF TAGS(TT) EQ 'BINS' THEN CONTINUE ; Don't want to create the masking subscripts on BINS
         RES = STRUCT.(TT)
         IF (SIZEXYZ(RES)).N_DIMENSIONS EQ 2 OR BINS NE [] THEN BEGIN ; Find an array to create the mask subscripts
           IF IS_L3B(STRUCT.MAP) THEN RES = MAPS_L3B_2ARR(RES,MP=STRUCT.MAP,BINS=STRUCT.BINS)
           RES[_MASK] = MISSINGS(RES)
           OK_GOOD = WHERE(RES NE MISSINGS(RES),COUNT_GOOD,/NULL)
           IF COUNT_GOOD EQ 0 THEN GOTO, SKIP_MASK
           IF IS_L3B(STRUCT.MAP) THEN BEGIN
             BINS = MAPS_L3B_BINS(STRUCT.MAP)
             BINS = BINS(OK_GOOD)
             GOTO, DONE_OK_GOOD
           ENDIF 
         ENDIF
       ENDFOR
     ENDIF
     DONE_OK_GOOD:
     
     FOR TT=0, N_TAGS(STRUCT)-1 DO BEGIN                ; Loop through the STRUCT tags
       IF TAGS[TT] EQ 'BINS' THEN BEGIN
         NEW = CREATE_STRUCT(NEW,TAGS[TT],BINS)
         CONTINUE
       ENDIF
       SZ = SIZEXYZ(STRUCT.(TT))
       IF BINS NE [] THEN BEGIN
         IF SZ.N_ELEMENTS GE N_ELEMENTS(STRUCT.BINS) THEN BEGIN  
           TEMP = MAPS_L3B_2ARR(STRUCT.(TT),MP=STRUCT.MAP,BINS=STRUCT.BINS)
           TEMP = TEMP(OK_GOOD)
           NEW = CREATE_STRUCT(NEW,TAGS[TT],TEMP)
         ENDIF ELSE NEW = CREATE_STRUCT(NEW,TAGS[TT],STRUCT.(TT)) ; For non-array tags     
       ENDIF ELSE BEGIN
         IF SZ.N_DIMENSIONS EQ 2 THEN BEGIN
           TEMP = STRUCT.(TT)
           TEMP[_MASK] = MISSINGS(TEMP)
           NEW = CREATE_STRUCT(NEW,TAGS[TT],TEMP)
         ENDIF ELSE NEW = CREATE_STRUCT(NEW,TAGS[TT],STRUCT.(TT)); SZ.N_DIMENIONS EQ 2  
       ENDELSE
     ENDFOR ; TAGS
     IF NEW NE [] THEN STRUCT = NEW
     IF IDLTYPE(RESULT) EQ 'STRUCT' THEN RESULT = STRUCT
     GONE, NEW
   ENDIF
   SKIP_MASK:
  
;===> CAN NOT HAVE SUBS FOR SPREADSHEETS [FOLLOWING IS A WORKAROUND]
  IF IDLTYPE(RESULT) EQ 'STRUCT' AND N_TAGS(RESULT) GE 2 THEN RETURN, RESULT
  
  SUBS = WHERE(RESULT NE MISSINGS(RESULT),COUNT) 

  RETURN,RESULT
END; #####################  END OF ROUTINE ################################

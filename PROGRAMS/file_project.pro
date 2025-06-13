; $ID:	FILE_PROJECT.PRO,	APRIL 2, 2010	$

 FUNCTION FILE_PROJECT,  PATH=PATH,FOLDERS=FOLDERS
;+
; NAME:
;       FILE_PROJECT
;       RESULT=FILE_PROJECT(D:\PROJECTS\TEST\')
; PURPOSE:
;		  Make A PROJECT FOLDER AND SUBFOLDERS AND RETURN A STRUCTURE WITH ALL THE FOLDER NAMES FOR SUBSEQUENT USE BY THE CALLING PROGRAM
;
;	EXAMPLE:
; F= FILE_PROJECT(PATH='D:\PROJECTS\TEST\')
; ===> NOW THERE SHOULD BE THE RIGHT SUBFOLDERS IN PROJECT 'TEST'
; and the subfolders (paths) are subsequently referered to as;
; F.FILES, F.DATA,   F.DIR_DOC, F.BROWSE,  F.DIR_PLOTS,  F.SAVE
; PATH IS REQUIRED INPUT !
;
;EXAMPLE:
;   F = FILE_PROJECT(PATH='D:\PROJECTS\TEST\')
;   PRINT,F.BROWSE
;   D:\PROJECTS\TEST\BROWSE\
;   PRINT,F.PLOTS
;   D:\PROJECTS\TEST\PLOTS\
;  
;  
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly  Nov 9, 2006
;       MODIFIED MARCH 14, 2010 ,JOR, NOW RETURNS A STRUCTURE WITH FOLDER NAMES AND THE FULL PATH TO EACH FOLDER 
;-
;	*******************************************************************************
	ROUTINE_NAME='FILE_PROJECT'
;STOP
;	===> System-specific path separator
  PATH_DELIM			=	PATH_SEP()


;	===> Ensure : at end of disk
;	IF STRPOS(DISK,':') EQ -1 THEN DISK=DISK+':'

	IF N_ELEMENTS(PATH) NE 1 THEN STOP
STRUCT = CREATE_STRUCT('PATH',PATH)

  IF N_ELEMENTS(FOLDERS) EQ 0 THEN FOLDERS = ['BROWSE','DATA','PLOTS','SAVE']
;  GET UNIQUE FOLDER NAMES (IN CASE USER PROVIDES FOLDER NAMES SAME AS DEFAULTS)>>>
FOLDERS = FOLDERS[UNIQ(FOLDERS,SORT(FOLDERS))]
	PATH_TXT=''
;	IF KEYWORD_SET(PROJECT) THEN PATH_TXT=PROJECT+PATH_DELIM
;	IF KEYWORD_SET(DATA_SET) EQ 1 THEN PATH_TXT=PATH_TXT+DATA_SET+PATH_DELIM

 ; PATH = DISK + PATH_DELIM+ PROJECT +   PATH_DELIM + PATH_TXT

  PROJECT_FOLDERS = PATH +PATH_DELIM + FOLDERS+   PATH_DELIM 
  
  LIST,PROJECT_FOLDERS
;  PROJECT_FOLDERS = PATH+PATH_DELIM+FOLDERS+PATH_DELIM
   
;	*******************************************************************************************************
;	******* M A K E    F O L D E R S  A N D  A D D   T O      S T R U C T U R E    ************************
;	*******************************************************************************************************
  FOR N=0,N_ELEMENTS(PROJECT_FOLDERS)-1 DO BEGIN
    AFILE=PROJECT_FOLDERS(N)
    
  
        AFILE= REPLACE(AFILE,'\\','\') 
        FILE_MKDIR,AFILE
        
        FN=PARSE_IT(AFILE)
        NAME=FN.SUB
        STRUCT=CREATE_STRUCT(STRUCT,NAME,AFILE)
          
;    ;		===> ENSURE THAT FILE_MKDIR WORKED AND  ADD TO STRUCTURE
;    		IF FILE_TEST(AFILE,/DIRECTORY) EQ 1 THEN BEGIN
;    		ENDIF	
;    ENDIF; IF FILE_TEST(AFILE,/DIRECTORY) EQ 0L THEN  BEGIN
    
  ENDFOR
RETURN,STRUCT
; ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

END; #####################  End of Routine ################################

; $ID:	SYNC_MAC.PRO,	2015-04-30	$

	PRO SYNC_MAC

;+
; NAME:
;		SYNC_MAC
;
; PURPOSE:;
;		This procedure will backup the local nadata directory and then sync it with the main nadata directory on the server
;
; CATEGORY:
;		Back-ups
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written April 29, 2015 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'SYNC_MAC'
	
	SL = DELIMITER(/PATH)
	SP = ' '

; FIRST SYNC LOCAL DATA (MAC) BACK TO THE SERVER
  DIR_LOCAL  = !S.LOCAL
  DIR_SERVER = !S.PATH
  IF DIR_LOCAL EQ DIR_SERVER THEN MESSAGE, 'ERROR: Local path and server path are the same.'
  DIR_BACKUP = REPLACE(!S.LOCAL, 'nadata', 'nadata_backup') + 'DELETED_FROM_SERVER'+SL+STRMID(DATE_NOW(),0,8)

  EXCLUDE = STRJOIN('--exclude ' + ['"DATASETS*"','"GitHub"','"IDL"','"IDL_PROJECTS"','"ARCHIVE"','"khyde"','"yvasenin"','"PROJECTS*"','"SCRIPTS"','"SOFTWARE"','"LOGS"','".*/"','".*"'],SP)
  BACKUP = '--backup --backup-dir=' + DIR_BACKUP + SP
  LOG =  '--log-file=' + REPLACE(!S.LOCAL, 'nadata', 'nadata_backup') + 'RSYNC_' + STRMID(DATE_NOW(),0,8) + '.log' + SP + '--log-format="%8b/%-8l %i %n%L" '
  
  CMD = 'rsync -aviu ' + EXCLUDE + SP + LOG + BACKUP + DIR_LOCAL + SP + DIR_SERVER
  P, CMD
  SPAWN, CMD
stop
; THEN SYNC SPECIFIC DATASET OR PROJECT DIRECTORIES 
  DIR_BACKUP = REPLACE(!S.LOCAL, 'nadata', 'nadata_backup') + 'DELETED_FROM_MAC'+SL+STRMID(DATE_NOW(),0,8)
  BACKUP = '--backup --backup-dir=' + DIR_BACKUP + SP
  DIRS = ['PROJECTS/EDAB/IEA_WEBSITE/','PROJECTS/EDAB/SOE/','PROJECTS/EDAB/SOE_TECH_MEMO/','PROJECTS/ERDDAP/','PROJECTS/JPSS/','PROJECTS/NCA4/','PROJECTS/OPAL/','PROJECTS/PHENOLOGY/']
  EXCLUDE = STRJOIN('--exclude ' + ['".*/"','".*"'],SP)
  FOR N=0, N_ELEMENTS(DIRS)-1 DO BEGIN   
    CMD = 'rsync -aviu ' + EXCLUDE + SP + LOG + SP + BACKUP + SP + DIR_SERVER+DIRS(N) + SP + DIR_LOCAL + DIRS(N)
    P, CMD
    SPAWN, CMD
  ENDFOR
  
; FINALLY, SYNC THE MAIN NADATA DIRECTORIES, EXCLUDING DATASETS, PROJECTS AND OTHER HIDDEN FILES, BACK TO THE MAC  
 ; INCLUDE = STRJOIN('--include ' + ['DOCUMENTATION','IDL'] ,SP)
  EXCLUDE = STRJOIN('--exclude ' + ['"DATASETS"','"ARCHIVE"','"LOGS"','"PROJECTS"','"HYDE"','"SCRIPTS/SEADAS/seadas_anc"','"SOFTWARE"','"SCRIPTS/SEADAS/LOGS"','"khyde"','"yvasenin"','"ACL"','".*/"','".*"'],SP)
  CMD = 'rsync -aviu --delete ' + EXCLUDE + SP + LOG + BACKUP + DIR_SERVER + SP + DIR_LOCAL
 	P, CMD
 	SPAWN, CMD
  
 
END; #####################  End of Routine ################################


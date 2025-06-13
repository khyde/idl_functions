; $ID:	GET_DRIVE_NAMES.PRO,	2020-06-30-17,	USER-KJWH	$

 FUNCTION GET_DRIVE_NAMES
;+
; NAME:
;       GET_DRIVE_NAMES
;
; PURPOSE:
;				Get the drive names and type of drive (FIXED,REMOVABLE,CDROM,REMOTE)

; CATEGORY:
;		UTILITY
;
; CALLING SEQUENCE:
;		Result = GET_DRIVE_NAMES()
;
; INPUTS:
;		NONE:
;
; OUTPUTS:
;		A structure with the COMPUTER (Hostname), DRIVE, NAME, and TYPE of drive (FIXED,REMOVABLE,CDROM,REMOTE)
;
;	RESTRICTIONS:
;		Works for Windows, not yet for UNIX
;
;		This routine assumes that the 'A:\' drive is a floppy drive.
;
;		The name is the first character of the drive (drive letter.)
;
;		REMOVABLE DRIVES (e.g. memory sticks, etc.)
;		A convention assumed by this routine is that:
;		1) There may be a simple ascii text file at the root folder location of each removable drive named DRIVE_ID.TXT
;		2) That DRIVE_ID.TXT contains the NAME you would like to use for the drive INSTEAD of the DRIVE LETTER.
;		3) The NAME is on the first line of the DRIVE_ID.TXT file.
;
;		That feature is convenient for identifying and distinguishing among removable drives such as memory sticks, etc.
;		by their NAME in the DRIVE_ID.TXT file and not by their drive letter,
;	  which will vary depending on the order in which the removable drives are attached to the computer.
;
;		The Floppy Drive (A) and any CDROM drives will not be searched for DRIVE_ID.TXT to extract a drive name.
;
; EXAMPLE:
;		Result = GET_DRIVE_NAMES()
;		SPREAD,RESULT
;
;	NOTES:
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly & T. Ducas, Sept 21, 2004
;				Jan 26, 2007 JOR Revised and Streamlined
;-
;	****************************************************************************************************
	ROUTINE_NAME='GET_DRIVE_NAMES'

;	===> Assumes the Floppy Drive is the A drive
	FLOPPY_DRIVE = 'A:\'

;	===> Get the path separator for this operating system (/ or \)
	DELIM_PATH = PATH_SEP()

;	===> Make a structure to hold information
	TEMPLATE=CREATE_STRUCT('COMPUTER','','DRIVE','','NAME','','TYPE','')
	STRUCT   = TEMPLATE

;	===> FIXED DRIVES
	drives	=	GET_DRIVE_LIST(/FIXED)
 	IF drives[0] NE '' THEN BEGIN
 		COPY = REPLICATE(TEMPLATE,N_ELEMENTS(drives))
 		COPY.DRIVE = drives
 		COPY.TYPE  = 'FIXED'
 		STRUCT=[STRUCT,COPY]
 	ENDIF

;	===> REMOVABLE DRIVES
	drives	=	GET_DRIVE_LIST(/REMOVABLE)
	IF drives[0] NE '' THEN BEGIN
 		COPY = REPLICATE(TEMPLATE,N_ELEMENTS(drives))
 		COPY.DRIVE = drives
 		COPY.TYPE  = 'REMOVABLE'
 		STRUCT=[STRUCT,COPY]
 	ENDIF

;	===> CDROM DRIVES
	drives	=	GET_DRIVE_LIST(/CDROM)
	IF drives[0] NE '' THEN BEGIN
 		COPY = REPLICATE(TEMPLATE,N_ELEMENTS(drives))
 		COPY.DRIVE = drives
 		COPY.TYPE  = 'CDROM'
 		STRUCT=[STRUCT,COPY]
 	ENDIF

	drives	=	GET_DRIVE_LIST(/REMOTE)
 	IF drives[0] NE '' THEN BEGIN
 		COPY = REPLICATE(TEMPLATE,N_ELEMENTS(drives))
 		COPY.DRIVE = drives
 		COPY.TYPE  = 'REMOTE'
 		STRUCT=[STRUCT,COPY]
 	ENDIF


;	===> Remove the first (dummy) record from STRUCT
	IF N_ELEMENTS(STRUCT) GE 2 THEN STRUCT=STRUCT(1:*)

;	===> Extract the NAME (drive letter) from the drive
	STRUCT.NAME = STRMID(STRUCT.DRIVE,0,1)

;	===> Add the Computer Name (Hostname) to all drive types except the REMOTE drives
	OK=WHERE(STRUCT.TYPE NE 'REMOTE',COUNT)
	IF COUNT GE 1 THEN STRUCT[OK].COMPUTER = (GET_COMPUTER())[0]



;	***********************************************************************************
;	*** See of there is a DRIVE_ID.TXT file at the root folder of REMOVABLE drives  ***
;	*** If so then read the DRIVE NAME from the DRIVE_ID.TXT and REPLACE the  			***
;	*** STRUCT.NAME with this specific DRIVE_NAME from DRIVE_ID.TXT									***
;	***********************************************************************************


	OK=WHERE(STRUCT.TYPE EQ 'REMOVABLE',COUNT, NCOMPLEMENT=ncomplement,COMPLEMENT=complement)
	IF COUNT GE 1 THEN BEGIN
;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR nth=0,COUNT-1 DO BEGIN
			SUB = OK[NTH]
;			===> Ignore the Floppy Drive (We should not expect to find a DRIVE_ID.TXT on the FLOPPY drive
			IF STRUCT(sub).DRIVE EQ FLOPPY_DRIVE THEN CONTINUE ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

			DRIVE_ID = STRUCT(sub).DRIVE+'DRIVE_ID.TXT'

;			===> See if a file 'DRIVE_ID.TXT' exists at the root base folder for each drive
			IF FILE_TEST(DRIVE_ID) EQ 1 THEN BEGIN
				TXT=READ_TXT(DRIVE_ID)
;				===> Replace the previous NAME with that from DRIVE_ID.TXT
				IF N_ELEMENTS(TXT) GE 1 THEN STRUCT(sub).NAME=TXT[0]
			ENDIF
		ENDFOR
	ENDIF



;	***********************************************************
;	*** The HDD drives show up as 'FIXED' so check on these ***
;	***********************************************************
	OK_FIXED=WHERE(STRUCT.TYPE EQ 'FIXED',COUNT_FIXED )
	IF COUNT_FIXED GE 1 THEN BEGIN
;		LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR nth=0,COUNT_FIXED-1 DO BEGIN
			SUB = OK_FIXED[NTH]

			DRIVE_ID = STRUCT(sub).DRIVE+'DRIVE_ID.TXT'

;			===> See if a file 'DRIVE_ID.TXT' exists at the root base folder for each drive
			IF FILE_TEST(DRIVE_ID) EQ 1 THEN BEGIN
				TXT=READ_TXT(DRIVE_ID)
;				===> Replace the previous NAME with that from DRIVE_ID.TXT
				IF N_ELEMENTS(TXT) GE 1 THEN BEGIN
					OK= WHERE_STRING(TXT,'HDD',COUNT)
					IF COUNT EQ 1 THEN STRUCT(sub).NAME=TXT[0]
				ENDIF
			ENDIF
		ENDFOR
	ENDIF

	RETURN,STRUCT

END; #####################  End of Routine ################################




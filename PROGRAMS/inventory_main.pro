; $ID:	INVENTORY_MAIN.PRO,	2020-06-30-17,	USER-KJWH	$

	PRO INVENTORY_MAIN, ERROR = error

;+
; NAME:
;		INVENTORY_MAIN
;
; PURPOSE:
;
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE:
;
; INPUTS:
;		NONE
;
; OPTIONAL INPUTS:
;		Parm2:	Describe optional inputs here. If you don't have any, just delete this section.
;
; KEYWORD PARAMETERS:
;		KEY1:	Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;		This function returns the
;
; OPTIONAL OUTPUTS:
;		ERROR:     Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; COMMON BLOCKS: If no common blocks then delete this line
; SIDE EFFECTS:	 If no side effects then delete this line
; RESTRICTIONS:  If no restrictions then delete this line
;
;	PROCEDURE:
;			This is usually a description of the method, or any data manipulations
;
; EXAMPLE:
;
;	NOTES:
;		This routine will display better if you set your tab to 2 spaces:
;	  (Preferences, Editor, The TAB Number of spaces to indent for each Tab: 2)

;		Citations or any other useful notes
;
;
; MODIFICATION HISTORY:
;			Written June 15, 2010 T.Ducas
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'INVENTORY_MAIN'

; SWITCHES

	DO_SEAWIFS_L1A      					= 0
	DO_SEAWIFS_L2       					= 0
	DO_SEAWIFS_L1A_PROCESSING     = 1
	DO_SEAWIFS_SAVE     					= 0
	DO_MOVIES											= 0



; *************************************************************
	IF DO_SEAWIFS_L1A GE 1 THEN BEGIN
; *************************************************************

STOP
		CSVFILE='D:\IDL\INVENTORY\SEAWIFS_MLAC_L1A_INVENTORY.csv'
		DIR_IN='K:\SEAWIFS-MLAC-L1A\Z\'
		targets=['hdf.bz2','hdf.gz']
		FILES_Z=FILE_SEARCH(DIR_IN+'S*'+targets)
		IF FILES_Z[0] NE '' THEN BEGIN
			FA=PARSE_IT(FILES_Z)
			FILES_Z=FA.FIRST_NAME
			TEMP=CREATE_STRUCT('NAME','')
			TEMP=REPLICATE(TEMP,N_ELEMENTS(FILES_Z))
			TEMP.NAME=FILES_Z
			STRUCT_2CSV,CSVFILE,TEMP
		ENDIF


	ENDIF;IF DO_SEAWIFS_L1A GE 1 THEN BEGIN



; *************************************************************
	IF DO_SEAWIFS_L2 GE 1 THEN BEGIN
; *************************************************************

STOP
		CSVFILE='D:\IDL\INVENTORY\SEAWIFS_MLAC_L2_INVENTORY.csv'
		DIR_IN='T:\OC-SEAWIFS-MLAC-L2\Z\'
		FILES_Z=FILE_SEARCH(DIR_IN+'S*.L2_1KM.gz')
		IF FILES_Z[0] NE '' THEN BEGIN
			FA=PARSE_IT(FILES_Z)
			FILES_Z=FA.FIRST_NAME
			TEMP=CREATE_STRUCT('NAME','')
			TEMP=REPLICATE(TEMP,N_ELEMENTS(FILES_Z))
			TEMP.NAME=FILES_Z
			STRUCT_2CSV,CSVFILE,TEMP
		ENDIF

;   check EXCLUDE folder
		CSVFILE='D:\IDL\INVENTORY\SEAWIFS_MLAC_L2_EXCLUDE_INVENTORY.csv'
		DIR_IN='T:\OC-SEAWIFS-MLAC-L2\EXCLUDE\'
		FILES=FILE_SEARCH(DIR_IN+'!S_*.TXT')
		IF FILES[0] NE '' THEN BEGIN
			FA=PARSE_IT(FILES)
			FILES=FA.FIRST_NAME
			TEMP=CREATE_STRUCT('NAME','')
			TEMP=REPLICATE(TEMP,N_ELEMENTS(FILES))
			TEMP.NAME=FILES
			STRUCT_2CSV,CSVFILE,TEMP
		ENDIF

	ENDIF;IF DO_SEAWIFS_L2 GE 1 THEN BEGIN


; *************************************************************
	IF DO_SEAWIFS_L1A_PROCESSING GE 1 THEN BEGIN
; *************************************************************

STOP
		DO_CSV        = 1
		DO_COPY_L1A   = 1

		CSVFILE       ='D:\IDL\INVENTORY\SEAWIFS_MLAC_L1A_NEEDS_PROCESSING_INVENTORY.csv'
		CSV_L1A       ='D:\IDL\INVENTORY\SEAWIFS_MLAC_L1A_INVENTORY.csv'
	 	CSV_L2        ='D:\IDL\INVENTORY\SEAWIFS_MLAC_L2_INVENTORY.csv'


		IF KEYWORD_SET(DO_CSV) THEN BEGIN
			EXIST_L1A=FILE_TEST(CSV_L1A)
			EXIST_L2 =FILE_TEST(CSV_L2)
			IF EXIST_L1A EQ 1 AND EXIST_L2 EQ 1 THEN BEGIN
				FILES_L1A =READ_CSV(CSV_L1A)
				FILES_L2  =READ_CSV(CSV_L2)
				NAMES_L1A =FILES_L1A.NAME
				NAMES_L2  =FILES_L2.NAME
				OK=WHERE_IN(NAMES_L1A,NAMES_L2,COUNT,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)
				IF NCOMPLEMENT GE 1 THEN BEGIN
					FILES = FILES_L1A(COMPLEMENT)
				ENDIF ELSE BEGIN
					FILES=''
				ENDELSE
				STRUCT_2CSV,CSVFILE,FILES
			ENDIF
		ENDIF;IF KEYWORD_SET(DO_CSV) THEN BEGIN

		IF KEYWORD_SET(DO_COPY_L1A) THEN BEGIN
			DIR_L1A='K:\SEAWIFS-MLAC-L1A\Z\'
			DIR_L1A_PROCESS='I:\OC-SEAWIFS-MLAC-L1A-PROCESSING\'
			TARGETS=READ_CSV(CSVFILE)
			TARGETS=TARGETS.NAME

STOP
			DIR_L1A='K:\SEAWIFS-MLAC-L1A\Z\'
			FILES_Z=FILE_SEARCH(DIR_L1A+'S*.hdf.*')
			IF FILES_Z[0] NE '' AND TARGETS[0] NE '' THEN BEGIN
				FA=PARSE_IT(FILES_Z)
				NAMES_Z=FA.FIRST_NAME
				OK=WHERE_IN(NAMES_Z,TARGETS,COUNT,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT)
				IF COUNT GE 1 THEN BEGIN
					FILES_Z=FILES_Z[OK]
					FOR _FILE=5,N_ELEMENTS(FILES_Z) -1L DO BEGIN
						AFILE=FILES_Z(_FILE)
						FILE_COPY_2FOLDER,AFILE,DIR_OUT=DIR_L1A_PROCESS

					ENDFOR
				ENDIF
			ENDIF

		ENDIF;IF KEYWORD_SET(DO_COPY_L1A) THEN BEGIN
	ENDIF;IF DO_SEAWIFS_L1A_NEEDS_PROCESSING GE 1 THEN BEGIN

END; #####################  End of Routine ################################


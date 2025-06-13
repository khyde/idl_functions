; $ID:	NARR_SHARK_SURVEY_MAIN.PRO,	2020-07-08-15,	USER-KJWH	$
PRO NARR_SHARK_SURVEY_MAIN, STRUCT
;+
; NAME:
; 	NARR_SHARK_SURVEY

;		This Program Reads a CSV Database file of Narragansett Lab Shark Survey locations

;		Standard EC map domain.
;		OUTPUT:

; HISTORY:
;     July 4, 2006  Written by: J.E. O'Reilly
;-
; *************************************************************************

	ROUTINE_NAME='NARR_SHARK_SURVEY_MAIN'

	DATA_SET = 'NARR_SHARK_SURVEY'

	DISK = 'D:'
  DELIM=DELIMITER(/PATH)
  PATH=DISK+'\'+'PROJECTS\NARR_SHARK_SURVEY'+'\'
  FOLDERS = ['DATA','DOC','BROWSE','PLOTS','SAVE','STATS','STATS_BROWSE']
  FILE_PROJECT, PATH=PATH,FOLDERS=FOLDERS

	DIR_IMAGES='D:\IDL\IMAGES\'


; *******************************************
; Set up color system defaults
	SETCOLOR
	PAL_36



; ********************************************************************************
; ***** U S E R    S W I T C H E S  Controlling which Processing STEPS to do *****
; ********************************************************************************
;	0 (Do not do the step)
;	1 (Do the step)
; 2 (Do the step and OVERWRITE any output if it alread exists)

; ===>
	DO_DATA_2SAVE     =   1
  DO_READ_DATA_AND_PLOT_LON_LAT =	1
  DO_DATE_RANGES_4_MOVIES = 2


; **************************************************************
 	IF DO_DATA_2SAVE GE 1 THEN BEGIN
; **************************************************************
		OVERWRITE = DO_DATA_2SAVE GE 2
		 PRINT, 'S T E P:    DO_DATA_2SAVE'

		FILE = !DIR_DATA+'Shark_Survey_LAT_LON.csv'
		SAVEFILE=!DIR_SAVE+'Shark_Survey_Stations.save'


    exist = FILE_TEST(SAVEFILE)
    IF exist EQ 0 OR OVERWRITE GE 1 THEN BEGIN
 			DB = CSV_READ(FILE)
 			OK=WHERE(DB.LON GT 0,COUNT)
 			IF COUNT GE 1 THEN DB[OK].LON = -1.0*DB[OK].LON
;			===> IF file is huge then only want to read it once, then save  the variables of interest
		 	SAVE,FILENAME=SAVEFILE,DB,/COMPRESS
		ENDIF
	END



; **************************************************************
 	IF DO_READ_DATA_AND_PLOT_LON_LAT GE 1 THEN BEGIN
; **************************************************************
		OVERWRITE = DO_READ_DATA_AND_PLOT_LON_LAT GE 2
		 PRINT, 'S T E P:    DO_READ_DATA_AND_PLOT_LON_LAT'

	 	SAVEFILE=!DIR_SAVE+'Shark_Survey_Stations.save'
		PSFILE=!DIR_PLOTS+'Shark_Survey_Stations.ps'

    exist = FILE_TEST(PSFILE)
    IF exist EQ 0 OR OVERWRITE GE 1 THEN BEGIN
 			DB = IDL_RESTORE(SAVEFILE)
;			===> IF file is huge then only want to read it once, then save  the variables of interest


		SETS=WHERE_SETS(DB.YEAR)
			PSPRINT,FILENAME=PSFILE,/COLOR,/FULL
		FOR _SET = 0,N_ELEMENTS(SETS)-1 DO BEGIN
			ASET=SETS(_SET)
			SUBS=WHERE_SETS_SUBS(ASET)
			D=DB(SUBS)
			TITLE='Narr Shark Survey Stations ' + STRTRIM(ASET[0].VALUE,2)

		PAL_36
		MAPIT, D.LON,D.LAT, MAP='EC' ,TITLE=TITLE,COLOR_PSYM=21


		ENDFOR
		PSPRINT
		ENDIF
	ENDIF



; **************************************************************
 	IF DO_DATE_RANGES_4_MOVIES GE 1 THEN BEGIN
; **************************************************************
		OVERWRITE = DO_DATE_RANGES_4_MOVIES GE 2
		 PRINT, 'S T E P:    DO_DATE_RANGES_4_MOVIES'

		SAVEFILE=!DIR_SAVE+'Shark_Survey_Stations.save'
	 	CSV_FILE=!DIR_SAVE+'Shark_Survey_Stations_date_range.CSV'

stop
    exist = FILE_TEST(CSV_FILE)
    IF exist EQ 0 OR OVERWRITE GE 1 THEN BEGIN
 			DB = IDL_RESTORE(SAVEFILE)
;			===> IF file is huge then only want to read it once, then save  the variables of interest
		  SETS=WHERE_SETS(DB.YEAR)


;			LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
			FOR _SET = 0,N_ELEMENTS(SETS)-1 DO BEGIN
				ASET=SETS(_SET)
				SUBS=WHERE_SETS_SUBS(ASET)
				D=DB(SUBS)
		    JD_RANGE = DATE_2JD(MINMAX(D.DATE))
		    DATE_RANGE = JD_2DATE([ JD_2JD(JD_RANGE[0] - 15,/MONTH,/START), JD_2JD(JD_RANGE[1] + 15,/MONTH,/END)])
		    PRINT, DATE_RANGE

			ENDFOR
			ENDIF


  ENDIF ; IF DO_READ_DATA_AND_PLOT_LON_LAT GE 1 THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||









PRINT,'END OF NARR_SHARK_SURVEY.PRO'

END; #####################  End of Routine ################################

; $ID:	STATS_SETS.PRO,	2020-06-30-17,	USER-KJWH	$

		FUNCTION STATS_SETS, 	Data, ID,  STD=std,ERROR=error

;+
; NAME:
;		STATS_SETS
;
; PURPOSE:;
;		This function Computes Statistics on Sequential Groups of Data where the size of each group is defined by the Width
;
; CATEGORY:
;		STATISTICS
;
; CALLING SEQUENCE:
;
;		Result = STATS_SETS(Data, Width)
;
; INPUTS:
;		DATA:	Array
;		ID:		The value to use in forming similar sets
;
;
; KEYWORD PARAMETERS:
;		STD:		Also compute Standard Deviation for each set
;		ERROR:		Error code: 0=ok, 1=error

; OUTPUTS:
;		This function returns a Structure with Statistical Results for each of the Sets
;
;
; EXAMPLE:
;
;	NOTES:
;
;
; MODIFICATION HISTORY:
;			Written Jan 5, 2006 by J.O'Reilly, 28 Tarzwell Drive, NMFS, NOAA 02882 (Jay.O'Reilly@NOAA.GOV)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'STATS_SETS'
	ERROR = 0
	ERR_MSG = ''

	DELIMS = ",;"

	IF N_ELEMENTS(Data) EQ 0 OR N_ELEMENTS(ID) EQ 0 OR N_ELEMENTS(Data) NE N_ELEMENTS(ID) THEN BEGIN
		ERROR = 1
		PRINT, 'ERROR: MUST PROVIDE ARRAY AND WIDTH'
		RETURN,-1L
	ENDIF

;	===> Get the Sets based on G
	SETS =WHERE_SETS(ID)
	N_SETS= N_ELEMENTS(SETS)
	STRUCT_STATS=STATS([MISSINGS(0.0)] ,QUIET=quiet)
	STRUCT_STATS=STRUCT_COPY(STRUCT_STATS,TAGNAMES=['N','MIN','SUB_MIN','MAX','SUB_MAX','MED','MEAN','STD'])


;	===> Create structure to hold the Statistics, a record for each set
	STATS_SETS_STRUCT = REPLICATE(CREATE_STRUCT('SET','','SUBS','',STRUCT_STATS),N_SETS)
	STATS_SETS_STRUCT.SET 	= SETS.VALUE

	STATS_SETS_STRUCT.SUBS 	= SETS.SUBS


;	===> Dimension STATS_SETS_MATRIX to maximum obs per period (cols) by number of periods (rows), initializing to !VALUES.F_NAN
	MAX_N = MAX(SETS.N)
	STATS_SETS_MATRIX= REPLICATE(!VALUES.D_NAN,MAX_N,N_SETS)

	SETS_SUBS_MATRIX= WHERE_SETS_SUBS_MATRIX(SETS)
	SETS_SUBS 			= WHERE(SETS_SUBS_MATRIX NE MISSINGS(SETS_SUBS_MATRIX))


;	===> ASSIGN DATA to STATS_SETS_MATRIX After changing any missing to NAN
	STATS_SETS_MATRIX(SETS_SUBS) = MISSING_2NAN(DATA(SETS_SUBS_MATRIX(SETS_SUBS)))

;	===> Compute MIN, MAX, MEDIAN for each row of the STATS_SETS_MATRIX
	STATS_SETS_STRUCT.MIN	=	MIN(		STATS_SETS_MATRIX,SUBS_MIN, /NAN		,DIMENSION=1)
	STATS_SETS_STRUCT.MAX	=	MAX(		STATS_SETS_MATRIX,SUBS_MAX, /NAN		,DIMENSION=1)
	STATS_SETS_STRUCT.MED	=	MEDIAN(	STATS_SETS_MATRIX,					/EVEN		,DIMENSION=1)


;	===> Compute the jd_min, jd_max
 	STATS_SETS_STRUCT.sub_min = SETS_SUBS_MATRIX(subs_min)
 	STATS_SETS_STRUCT.sub_max = SETS_SUBS_MATRIX(subs_max)

;	===> Compute the TOTAL for each row
	_SUM	= TOTAL(STATS_SETS_MATRIX,/NAN,1)

;	===> Compute the Number of non-missing observations for each row
	STATS_SETS_STRUCT.N  = TOTAL( FINITE(STATS_SETS_MATRIX),1)

;	===> Compute the MEAN for each row
	STATS_SETS_STRUCT.MEAN = _SUM /STATS_SETS_STRUCT.N ;


;	===> ? STD then add STD (which doubles the run time)
	IF KEYWORD_SET(STD) THEN BEGIN
		ROWS = N_ELEMENTS(STATS_SETS_MATRIX(0,*))
;		LLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR NTH=0L,ROWS-1L DO BEGIN
			OK=WHERE(FINITE(STATS_SETS_MATRIX(*,NTH)),COUNT)
			IF COUNT GE 2 THEN BEGIN
 				STATS_SETS_STRUCT[NTH].STD = STDEV(STATS_SETS_MATRIX(OK,NTH))
			ENDIF
		ENDFOR
	ENDIF

;	===> Change any NAN's to INFINITY
	RETURN, NAN_2INFINITY(STATS_SETS_STRUCT)



END; #####################  End of Routine ################################

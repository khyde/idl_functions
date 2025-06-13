; $ID:	STATS_GROUPS.PRO,	2020-06-30-17,	USER-KJWH	$

		FUNCTION STATS_GROUPS, 	Data, Width, ERROR=error

;+
; NAME:
;		STATS_GROUPS
;
; PURPOSE:;
;		This function Computes Statistics on Sequential Groups of Data where the size of each group is defined by the Width
;
; CATEGORY:
;		STATISTICS
;
; CALLING SEQUENCE:
;
;		Result = STATS_GROUP(Data, Width)
;
; INPUTS:
;		DATA:	Array
;		WIDTH:	The size of each group
;
;
; KEYWORD PARAMETERS:
;		ERROR:		Error code: 0=ok, 1=error

; OUTPUTS:
;		This function returns a Structure with Statistical Results for each of the Groups
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
	ROUTINE_NAME = 'STATS_GROUPS'
	ERROR = 0
	ERR_MSG = ''

	DELIMS = ",;"

	IF N_ELEMENTS(Data) EQ 0 OR N_ELEMENTS(WIDTH) EQ 0 THEN BEGIN
		ERROR = 1
		PRINT, 'ERROR: MUST PROVIDE ARRAY AND WIDTH'
		RETURN,-1L
	ENDIF

;	===> Get the sequential group ID's
	G = GROUP(Data, Width)

;	===> Get the Sets based on G
	SETS =WHERE_SETS(G)
	N_SETS= N_ELEMENTS(SETS)
	STRUCT_STATS=STATS([MISSINGS(0.0)] ,QUIET=quiet)
	STRUCT_STATS=STRUCT_COPY(STRUCT_STATS,TAGNAMES=['N','MIN','SUB_MIN','MAX','SUB_MAX','MED','MEAN','STD'])

stop
;	===> Create structure to hold the Statistics, a record for each set
	STATS_GROUP_STRUCT = REPLICATE(CREATE_STRUCT('GROUP','','SUBS','',STRUCT_STATS),N_SETS)
	STATS_GROUP_STRUCT.GROUP 	= SETS.VALUE

	STATS_GROUP_STRUCT.SUBS 		= SETS.SUBS



;	===> Dimension STATS_GROUP_MATRIX to maximum obs per period (cols) by number of periods (rows), initializing to !VALUES.F_NAN
	MAX_N = MAX(SETS.N)
	STATS_GROUP_MATRIX= REPLICATE(!VALUES.D_NAN,MAX_N,N_SETS)

	GROUP_SUBS_MATRIX= WHERE_SETS_SUBS_MATRIX(SETS)
	GROUP_SUBS 			= WHERE(GROUP_SUBS_MATRIX NE MISSINGS(GROUP_SUBS_MATRIX))


;	===> ASSIGN DATA to STATS_GROUP_MATRIX After changing any missing to NAN
	STATS_GROUP_MATRIX(GROUP_SUBS) = MISSING_2NAN(DATA(GROUP_SUBS_MATRIX(GROUP_SUBS)))

;	===> Compute MIN, MAX, MEDIAN for each row of the STATS_GROUP_MATRIX
	STATS_GROUP_STRUCT.MIN	=	MIN(		STATS_GROUP_MATRIX,SUBS_MIN, /NAN		,DIMENSION=1)
	STATS_GROUP_STRUCT.MAX	=	MAX(		STATS_GROUP_MATRIX,SUBS_MAX, /NAN		,DIMENSION=1)
	STATS_GROUP_STRUCT.MED	=	MEDIAN(	STATS_GROUP_MATRIX,					/EVEN		,DIMENSION=1)


;	===> Compute the jd_min, jd_max
 	STATS_GROUP_STRUCT.sub_min = GROUP_SUBS_MATRIX(subs_min)
 	STATS_GROUP_STRUCT.sub_max = GROUP_SUBS_MATRIX(subs_max)

;	===> Compute the TOTAL for each row
	_SUM	= TOTAL(STATS_GROUP_MATRIX,/NAN,1)

;	===> Compute the Number of non-missing observations for each row
	STATS_GROUP_STRUCT.N  = TOTAL( FINITE(STATS_GROUP_MATRIX),1)

;	===> Compute the MEAN for each row
	STATS_GROUP_STRUCT.MEAN = _SUM /STATS_GROUP_STRUCT.N ;


;	===> ? STD then add STD (which doubles the run time)
	IF KEYWORD_SET(STD) THEN BEGIN
		ROWS = N_ELEMENTS(STATS_GROUP_MATRIX(0,*))
;		LLLLLLLLLLLLLLLLLLLLLLLLLLL
		FOR NTH=0L,ROWS-1L DO BEGIN
			OK=WHERE(FINITE(STATS_GROUP_MATRIX(*,NTH)),COUNT)
			IF COUNT GE 2 THEN BEGIN
 				STATS_GROUP_STRUCT[NTH].STD = STDEV(STATS_GROUP_MATRIX(OK,NTH))
			ENDIF
		ENDFOR
	ENDIF

;	===> Change any NAN's to INFINITY
	RETURN, NAN_2INFINITY(STATS_GROUP_STRUCT)



END; #####################  End of Routine ################################

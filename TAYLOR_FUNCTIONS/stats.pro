; $Id:	stats.pro,	October 28 2009	$

FUNCTION STATS ,array,$
							 PROD=prod,$
							 MATH=math,$
               MISSING=missing,$
               PARAMS=params,$
               DECIMALS=decimals,$
               FILE=file,$
               APPEND=append,$
               NO_HEADING=no_heading,$
               NOTES=notes,$
               EVEN=even,$
               SHOW=SHOW,$
               TRANSFORM=transform,$
               _EXTRA=_extra
;+
; NAME:
;       stats
;
; PURPOSE:
;      Computes:
;      Minimum
;      Maximum
;      Median (50%)
;      Arithmetic mean
;      Variance
;      Standard Deviation
;      Mean Absolute Deviation
;      Coefficient of Variation
;      Skewness
;      Kurtosis
;
;
; CATEGORY:
;      STATISTICS
;
; CALLING SEQUENCE:
;       Result = stats(a)
;       Result = stats(a, missing = -9)
;
; EXAMPLES:
;       stats = STATS(RANDOMN(SEED,20000))
;       PRINT, STATS
;       HELP,/STRU,STATS
;
;       a = stats([1,2,3,4,5,6],/SHOW) & HELP,/STRUCT, A

; INPUTS:
;       Array
;
; KEYWORD PARAMETERS:
;
;       Missing:   value for missing data (This value will be excluded from the statistics.
;
;       Params:    A vector indicating which statistical results,
;                  (and their sequence or order), will be ppaced into
;                  the tag string variable: STATSTRING
;                  for subsequent use by the program calling stats
;
;                  (Note the user may specify values for PARAMS in any order:
;            0:    N (number of observations in array)
;            1:    Minimum
;						 2:		 Subscript of the minimum value
;            3:    Maximum
;						 4:		 Subscript of the maximum value
;            5:    Median (50%)
;            6:    Mean (if STATS_TRANSFORM is set, then the mean = Geometric mean, else mean = Arithmetic mean)
;            7:    Variance
;            8:    Standard Deviation
;            9:    Coefficient of Variation
;           10:    Arithmetic mean (will be returned as MISSINGS if STATS_TRANSFORM = '')
;           11:    Geometric mean (will be returned as MISSINGS if STATS_TRANSFORM = '')
;           12:    Mean Absolute Deviation
;           13:    Skewness
;           14:    Kurtosis
;						15:		 Transformation type (ALOG, ALOG10, '')
;
;       Decimals:  Number of desired decimal places in tag STATSTRING
;                  (Does not influence format of other structure tags)
;
;       File:      Full name of file to write all statistical results
;
;       Append:    Appends statistics to existing file
;
;       No_heading: Supresses heading (2 lines)
;
;       Notes:     User may add text string identifying subset or any other identifyer
;                  to first line of heading
;
;       EVEN:      If this keyword is used then when array has even number of elements
;                  the median is the average of the middle 2 elements.
;                  (This is same as IDL EVEN keyword when using MEDIAN
;
;				PROD:			 Product to input to SD_USE_TRANSFORM
;
;				MATH:			 Used for special case PRODS such as GRAD_MAG_RATIO
;
;				TRANSFORM: Use this keyword to transform the data (ALOG or ALOG10) prior to calculating the MEAN
;
;       SHOW:      Prints statistics to Command Log
;
;
;
; OUTPUTS:
;       A structure containing the various statistics:
;       N = number of observations in array
;       Minimum,,Maximum,Median (50%),Arithmetic mean,Variance,
;       Standard Deviation,Mean Absolute Deviation,Coefficient of Variation
;       Skewness,Kurtosis
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
;
; ====================>
; Other Programs called:
; IDL Function MIN,MAX is called to obtain minimum and maximum
; IDL Function SORT    is called to sort (ascending)  the data
; IDL Function REVERSE is called to sort (descending) the data
;
; MODIFICATION HISTORY:
;       Written October 24,1994, J.E. O'Reilly, NOAA, Narragansett, RI
;       Modified: April 27,1995 				returns stats
;       Modified: May 20,1995 					returns stats.n = 0 if only 1
;                              					observation and it is equal to missing)
;       Modified: Jan 30,1996  					Eliminates infinite data from array before computing statistics
;                              					If missing not supplied then sets missing to infinity (!VALUE.D_INFINITY);
;                              					Added keyword MIDDLE (median is average of the two middle values in an even-numbered array
;       Modified: July 17,1996  				Added statstring to structure (useful with IDL'S XYOUTS)
;       Modified: August 9,1996 				Added PARAMS,FILE,ETC. SO STATS WORKS LIKE STATS2.PRO
;       Modified: December 4,1997 			REPLACED keyword MIDDLE with EVEN to match IDL MEDIAN program
;                       								Also no longer sort data to find middle for median when providing an even-numbered array
;       Modified: April 11,2000   			Changed 'if keyword_set(missing) to IF N_ELEMENTS(MISSING) NE 1 THEN
;       Modified: June 2, 2003 		TD 		replace strtrim(string with strtrim if format not specific
;       Modified: June 14, 2006   JOR 	added sub_min and sub_max
;       Modified: October 5, 2006	KJHW 	fixed the output text string to include sub_min and sub_max
;       Modified: Jan 3, 2007 		JOR 	Eliminated keyword QUIET, now using SHOW if want to display results
;       Modified: April 2, 2009		KJWH 	Added TRANSFORM, PROD & MATH keywords and AMEAN & GMEAN to the stats structure
;				Modified: Oct 27,2009     TD    Get STAT_TRANSFORM from SD_USE_TRANSFORM first, then check if TRANSFORM keyword set
;-
;

; ====================>
; Check keyword missing
; If value for missing not provided make missing !VALUES.D_INFINITY
  IF N_ELEMENTS(MISSING) NE 1 THEN MISSING = MISSINGS(0.0D) ELSE MISSING = DOUBLE(MISSING)

;	Check for TRANSFORM keyword
	STAT_TRANSFORM = SD_USE_TRANSFORM(PROD,MATH=MATH)
	IF KEYWORD_SET(TRANSFORM) THEN IF TRANSFORM EQ '1' THEN STAT_TRANSFORM = 'ALOG' ELSE STAT_TRANSFORM = TRANSFORM

; ====================>
; Construct a  STRUCTURE to hold statistical results
  STAT = {  N:0L,MIN:MISSING,$
  							SUB_MIN:MISSING,$
                MAX:MISSING,$
                SUB_MAX:MISSING,$
                MED:MISSING,$
                MEAN:MISSING,$
                VAR:MISSING,$
                STD:MISSING,$
                CV:MISSING,$
                AMEAN:MISSING,$
                ASTD:MISSING,$
                GMEAN:MISSING,$
                GSTD:MISSING,$
                MDEV:MISSING,$
                SKEW:MISSING,$
                KURT:MISSING,$
                TRANSFORM:'',$
                STATSTRING:''}

; ====================>
; Copy array into data variable (This keeps original array unchanged)
  DATA = (DOUBLE(ARRAY))

; ====================>
; Remove data values equal to missing value or infinity
  OK = WHERE(DATA NE missing AND FINITE(DATA),COUNT)  ; Check for missing input data
  IF COUNT GE 1 THEN DATA = TEMPORARY(DATA(OK)) ELSE DATA = MISSING


;  ====================>
; Check keyword DECIMALS
  IF N_ELEMENTS(DECIMALS) EQ 1 THEN BEGIN
    IF DECIMALS GE 1 AND DECIMALS LE 14 THEN FORMAT='(D30.'+ STRTRIM(DECIMALS,2) + ')' ELSE FORMAT=''
  ENDIF
; ====================>
; Begin filling structure stats with various statistics

  STAT.N = N_ELEMENTS(DATA)
  S = SIZE(DATA)
  IF STAT.N EQ 1 AND S(0) EQ 0 THEN STAT.N = 0
  IF STAT.N EQ 1 AND DATA(0) EQ MISSING THEN STAT.N = 0


  CASE 1 OF
    (STAT.N GE 2): BEGIN
;    MINIMUM,MAXIMUM
     STAT.MIN    	= MIN(DATA,SUB_MIN, MAX=MAXDATA, SUBSCRIPT_MAX=SUB_MAX,/NAN)
     STAT.SUB_MIN = SUB_MIN
     STAT.MAX    	= MAXDATA
     STAT.SUB_MAX = SUB_MAX

;    median

     STAT.MED = MEDIAN(DATA, EVEN=EVEN)  ;  If EVEN is set then pass it to MEDIAN

;    The following taken from IDL's MOMENT.PRO
;    (Modified to deal with variance of zero).

;    MEAN
     AMEAN = TOTAL(DATA) / STAT.N
     IF STAT_TRANSFORM EQ 'ALOG10' THEN GMEAN = 10^(TOTAL(ALOG10(DATA))/STAT.N) ELSE GMEAN = EXP(TOTAL(ALOG(DATA))/STAT.N)
     IF STAT_TRANSFORM NE '' THEN BEGIN
     	STAT.MEAN = GMEAN
     	STAT.AMEAN = AMEAN
     	STAT.GMEAN = GMEAN
     ENDIF ELSE STAT.MEAN = AMEAN
     STAT.TRANSFORM = STAT_TRANSFORM

;    RESIDUAL
     RESID = DATA - STAT.MEAN

;    Mean absolute deviation
     STAT.MDEV = TOTAL(ABS(RESID)) / STAT.N

;    Variance
     R2 = TOTAL(RESID^2)
     VAR1 = r2 / (STAT.N-1.0)
     VAR2 = (r2 - (TOTAL(RESID)^2)/STAT.N)/(STAT.N-1.0)
     STAT.VAR =  (VAR1 + VAR2)/2.0

 ;   Standard deviation
     ASTD = SQRT(STAT.VAR)     
     IF STAT_TRANSFORM NE '' THEN BEGIN
       IF STAT_TRANSFORM EQ 'ALOG10' THEN GSTD = 10^(STDDEV(ALOG10(DATA))) ELSE GSTD = EXP(STDDEV(ALOG(DATA)))
     	 STAT.STD = GSTD
     	 STAT.ASTD = ASTD
     	 STAT.GSTD = GSTD
     ENDIF ELSE STAT.STD = ASTD

;    Skewness and Kurtosis
     IF STAT.VAR NE 0 THEN BEGIN
       STAT.SKEW = TOTAL(RESID^3) / (STAT.N * STAT.STD ^ 3)
       STAT.KURT = TOTAL(RESID^4) / (STAT.N * STAT.STD ^ 4) - 3.0
     ENDIF ELSE BEGIN
       STAT.SKEW = !VALUES.D_INFINITY
       STAT.KURT = !VALUES.D_INFINITY
     ENDELSE

;    Coefficient of Variation
     STAT.CV     = 100.0*STAT.STD/STAT.MEAN
    ENDCASE


  (STAT.n eq 1): BEGIN
    STAT.MIN    	= DATA(0)
    STAT.SUB_MIN 	= MISSING
    STAT.MAX    	= DATA(0)
    STAT.SUB_MAX 	= MISSING
    STAT.MEAN   	= DATA(0)
    STAT.MED 			= DATA(0)
    STAT.STD    	= MISSING
    STAT.CV    		= MISSING
  ENDCASE

  (STAT.n eq 0): BEGIN
    STAT.MIN    	= MISSING
    STAT.SUB_MIN 	= MISSING
    STAT.MAX    	= MISSING
    STAT.SUB_MAX 	= MISSING
    STAT.MEAN   	= MISSING
    STAT.MED			= MISSING
    STAT.STD 		  = MISSING
    STAT.CV     	= MISSING
  ENDCASE

  ENDCASE

; ====================>
; Fill statstring
  TAGNAMES=TAG_NAMES(STAT)
  N_TAGNAME=N_ELEMENTS(tagnames)
  IF N_ELEMENTS(PARAMS) EQ 0 THEN PARAMS=INDGEN(N_TAGNAME) ELSE BEGIN ; DEFAULT IS ALL REGRESSION PARAMETERS
    OK = WHERE(PARAMS GE 0 AND PARAMS LE (N_TAGNAME-2),COUNT)
    IF COUNT GE 1 THEN PARAMS = PARAMS(OK) ELSE PARAMS=INDGEN(N_TAGNAME)
  ENDELSE
  FOR I = 0,N_ELEMENTS(PARAMS)-1 DO BEGIN
  	J = PARAMS(I)
    IF KEYWORD_SET(DECIMALS) AND J GE 1 AND J LE 10 THEN $
      STAT.STATSTRING = STAT.STATSTRING+ '!C' + STRTRIM(TAGNAMES(J),2)+ ': ' + STRTRIM(STRING(STAT.(J),FORMAT=FORMAT),2) ELSE $
      STAT.STATSTRING = STAT.STATSTRING+ '!C' + STRTRIM(TAGNAMES(J),2)+ ': ' + STRTRIM(STAT.(J),2)
  ENDFOR

 IF N_ELEMENTS(NOTES) EQ 0 THEN NOTES = SYSTIME() ELSE $
                                NOTES = NOTES +' ' + SYSTIME()

 IF NOT KEYWORD_SET(NO_HEADING) THEN BEGIN
;   User may add annotation to first line of header (notes)
    HEADING=        '        N'
    HEADING=HEADING+'        Min                Subs_Min'
    HEADING=HEADING+'           Max                 Subs_Max'
    HEADING=HEADING+'       Median             Mean'
    HEADING=HEADING+'              Variance           STD'
    HEADING=HEADING+'               CV                    Mdev'
    HEADING=HEADING+'               Skew               Kurt'
  ENDIF

; =================>
; Open a file for writing statistical results
  IF KEYWORD_SET(FILE) THEN BEGIN
;   If Keyword APPEND is set then add to the file
;   otherwise, open a NEW file (rewrite)
    IF KEYWORD_SET(append) THEN OPENU,lun,FILE,/GET_LUN,/APPEND ELSE $
                                OPENW,lun,FILE,/GET_LUN
    IF NOT KEYWORD_SET(no_heading) THEN PRINTF,lun, [notes,heading] ELSE $
                                        PRINTF,lun, [notes]
  ENDIF

  IF KEYWORD_SET(SHOW) EQ 1 AND N_ELEMENTS(no_heading) EQ 0 THEN PRINT,heading

  IF KEYWORD_SET(FILE) THEN BEGIN
    FOR i = 0,N_ELEMENTS(STAT) -1 DO BEGIN
      PRINTF,lun,STAT(i).(0),$
                 STAT(i).(1),$
                 STAT(i).(2),$
                 STAT(i).(3),$
                 STAT(i).(4),$
                 STAT(i).(5),$
                 STAT(i).(6),$
                 STAT(i).(7),$
                 STAT(i).(8),$
                 STAT(i).(9),$
                 STAT(i).(10),$
                 STAT(i).(11),$
                 STAT(i).(12),$
                 STAT(i).(13),$
                 STAT(i).(14),$
                 STAT(i).(15),$
                 STAT(i).(16),$
                 STAT(i).(17),$
                 STAT(i).(18),$
                 STAT(i).(19),$
                 FORMAT='(I10,12G16.8)'
    ENDFOR
    CLOSE,LUN
    FREE_LUN,LUN
  ENDIF

  IF KEYWORD_SET(SHOW) THEN BEGIN
    FOR i = 0,N_ELEMENTS(STAT) -1 DO BEGIN
      PRINT,     STAT(i).(0),$
                 STAT(i).(1),$
                 STAT(i).(2),$
                 STAT(i).(3),$
                 STAT(i).(4),$
                 STAT(i).(5),$
                 STAT(i).(6),$
                 STAT(i).(7),$
                 STAT(i).(8),$
                 STAT(i).(9),$
                 STAT(i).(10),$
                 STAT(i).(11),$
                 STAT(i).(12),$
                 STAT(i).(13),$
                 STAT(i).(14),$
                 STAT(i).(15),$
                 STAT(i).(16),$
                 STAT(i).(17),$
                 STAT(i).(18),$
                 STAT(i).(19),$
                 FORMAT='(I10,12G16.8)'
    ENDFOR
  ENDIF


  RETURN, STAT

 END ; End of Program


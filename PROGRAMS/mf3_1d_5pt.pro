; $ID:	MF3_1D_5PT.PRO,	2020-07-08-15,	USER-KJWH	$

	FUNCTION MF3_1D_5PT, IMG, EPSILON=EPSILON, ITER=iter, P5_MAX=P5_MAX, P5_MIN=P5_MIN, FILTERED=filtered, DIF_8=DIF_8, VERBOSE=verbose, ERROR = error

;+
; NAME:
;		MF3_1D_5PT
;
; PURPOSE:
;		This function applies a special Median filter to noisy images
;
; CATEGORY:
;		CATEGORY
;
; CALLING SEQUENCE:
;
;		Result = MF3_1D_5PT(Image)
;
; INPUTS:
;		Image:	A 2-d image array
;
; OPTIONAL INPUTS:
;		NONE:
;
; KEYWORD PARAMETERS:
;		EPSILON....	The value to use when determining peaks (sst = 1)
;
; OUTPUTS:
;		This function returns a median-filtered Image array
;
; OPTIONAL OUTPUTS:
;		ITER.......	The number of iterations used to achieve convergence criteria
;		P5_MIN ....	An image of the number of times a 5-point valley 	was found to be centered over each pixel
;		P5_MAX ....	An image of the number of times a 5-point peak 		was found to be centered over each pixel
;		FILTERED...	An image of the locations where the median altered the original input data (0=orig, 1=altered)
;		DIF_8......	An image of the Difference between the original point and its surrounding 8 neighbors, before median
;		ERROR:      Any Error messages are placed in ERROR, if no errors then ERROR = ''
;
; RESTRICTIONS:
;
;	PROCEDURE:
;			PEAK TEST USES 5-POINT SLICES in 4 DIRECTIONS: WE, NS, NWSE, NESW
;
; EXAMPLE:
;
;	NOTES:
;	
; Copyright (C) 2015, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.  
;   This routine is provided AS IS without any express or implied warranties whatsoever.  
;	
; This program was written by Igor Belkin, Unveristy of Rhode Island, Narragansett, RI, igormbelkin@gmail.com
;                             John E. O'Reilly, DOC/NOAA/NMFS/NEFSC Narragansett, RI
;                             Kimberly Hyde, DOC/NOAA/NMFS/NEFSC Narragansett, RI, kimberly.hyde@noaa.gov
; For questions about the code, contact kimberly.hyde@noaa.gov
; For questions regarding the method, contact igormbelkin@gmail.com
;
; MODIFICATION HISTORY:
;			A new algorithm
;			Written April 23, 2007  Igor Belkin, University of Rhode Island
;			Translated into IDL by J.O'Reilly (NOAA, Narragansett, RI)
;			Aug 24, 2015 - KJWH: Added VERBOSE keyword and changed input parameter IMAGE to IMG to avoid conflicts with IDL's new graphics procedure
;			Nov 12, 2015 - KJWH: Now returning the ERROR text when there is an error found
;			Nov 13, 2015 - KJWH: Changed FILTERED to a byte array: FILTERED = BYTARR(NCOLS,NROWS)
;			                     Changed FILTERER to now return 0's (not filtered) and 1's (filtered) as indicated above.
;			Dec 30, 2015 - KJWH: Removed TIC and TOC calls   
;			                     Removed NAR LAB functions [i.e. KEY() and MISSINGS()] so that it can be easily shared without needing additional functions                  
;
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'MF3_1D_5PT'

; ===> Constants
	STOP_FACTOR=1000
	ITER=0;
	FLAG=1;
	SW = 1;

;	===> Indices relating to the central and surrounding pixels in a 3x3 box
	CENTER_PIX = 4
	OTHER_PIXS  = [0,1,2,3,5,6,7,8]
	AROUND_XPS = [-1, 0, 1,  -1,1,   -1,0,1]
	AROUND_YPS = [-1,-1,-1,   0,0, 	  1,1,1]

;	===> Get the Size of the image and ensure that it is 2-d
	SZ=SIZE(IMG,/STRUCT)
	IF SZ.N_DIMENSIONS NE 2 THEN BEGIN
		ERROR = 'IMAGE Must be 2 dimensions'
		RETURN,ERROR
	ENDIF

	IF N_ELEMENTS(EPSILON) NE 1 THEN BEGIN
		ERROR = 'Must provide EPSILON' ; 	EPSILON = 1;
		RETURN,ERROR
	ENDIF

;	===> Make a copy of the input image
	A=IMG

;	===> Number of Columns and Rows in the Image
	NCOLS = SZ.DIMENSIONS[0]
	NROWS = SZ.DIMENSIONS[1]

;	===> Change values that are not finite to NANs
	OK=WHERE(FINITE(A) EQ 0, COUNT, NCOMPLEMENT=NCOMPLEMENT, COMPLEMENT=COMPLEMENT)  
	IF COUNT GE 1 THEN A[OK] = !VALUES.F_NAN

;	===> If all image values are bad then return
	IF NCOMPLEMENT EQ 0 THEN BEGIN
		ERROR='No valid values in the input Image'
		RETURN,ERROR
	ENDIF

	B=A
	AA=A

;	===> Make an image to indicate those pixels which are altered by median filter
	FILTERED = BYTARR(NCOLS,NROWS) 

;	===> Make a floating-point image initialized to INFINITY to hold the Difference between the Filtered and the max/min of surrounding 8 points
	DIF_8 = REPLICATE(!VALUES.F_INFINITY,NCOLS,NROWS)

;	===> diff_L1 is the maximum value in the image
	diff_L1			=	MAX(A,/NAN);
	diff_MIN_L1	= FLOAT(diff_L1)/STOP_FACTOR;
	diff_l2			=	TOTAL(A,/NAN);
	diff_MIN_L2	=	diff_l2/STOP_FACTOR;

	TXT1 = 'diff_L1=' 		+ STRTRIM(diff_L1,2) 			+ 'diff_l2=' + STRTRIM(diff_l2,2);
	TXT2 = 'diff_MIN_L1='	+ STRTRIM(diff_MIN_L1,2)	+	'  diff_MIN_L2='+ STRTRIM(diff_MIN_L2,2)

; *** END of INITIALIZATION  ***

;	WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
	WHILE diff_L1 GT diff_MIN_L1 DO BEGIN
    ITER=ITER+1;

;		===> Shift the image over the 8 pixels surrounding the center pixel within a 3x3 box
		SHIFT_E  = SHIFT(A, 1, 0)
		SHIFT_W  = SHIFT(A,-1, 0)
		SHIFT_N  = SHIFT(A, 0, 1)
		SHIFT_S  = SHIFT(A, 0,-1)
		SHIFT_NE = SHIFT(A, 1, 1)
		SHIFT_SW = SHIFT(A,-1,-1)
		SHIFT_NW = SHIFT(A,-1, 1)
		SHIFT_SE = SHIFT(A, 1,-1)

; *************************************************************************************************
;	*** Determine number of adjacent values that are above or below the center pixel in a 3x3 box ***
; *************************************************************************************************
;	===> Determine Number of Neighbors less than the central pixel of a 3x3 box
		P3_MAX =  $
						+ ((A - SHIFT_E) 	GT EPSILON) $
	  				+ ((A - SHIFT_W) 	GT EPSILON) $
						+ ((A - SHIFT_N) 	GT EPSILON) $
		 				+ ((A - SHIFT_S) 	GT EPSILON) $
		 				+ ((A - SHIFT_NE) GT EPSILON) $
		  			+ ((A - SHIFT_SW) GT EPSILON) $
		  			+ ((A - SHIFT_NW) GT EPSILON) $
		  			+ ((A - SHIFT_SE) GT EPSILON)

;	===> Determine Number of Neighbors greater than the central pixel of a 3x3 box
	  P3_MIN =  $
	  			+ ((SHIFT_E -  A) GT EPSILON) $
	 				+ ((SHIFT_W -  A) GT EPSILON) $
					+ ((SHIFT_N -  A) GT EPSILON) $
					+	((SHIFT_S -  A) GT EPSILON) $
					+	((SHIFT_NE - A) GT EPSILON) $
					+ ((SHIFT_SW - A) GT EPSILON) $
					+ ((SHIFT_NW - A) GT EPSILON) $
					+ ((SHIFT_SE - A) GT EPSILON)

;		===> Correct (set to zero) the outside edge values which are incorrect due to wraparound of the image during the SHIFT function above
		P3_MIN(*,0) 				= 0 ; Bottom Edge
		P3_MIN(*,NROWS-1) 	= 0 ; Top Edge
		P3_MIN(0,*)					= 0 ; Left Side
		P3_MIN(NCOLS-1,*) 	= 0 ; Right Side
		P3_MAX(*,0) 				= 0 ; Bottom Edge
		P3_MAX(*,NROWS-1) 	= 0 ; Top Edge
		P3_MAX(0,*)					= 0 ; Left Side
		P3_MAX(NCOLS-1,*) 	= 0 ; Right Side

;		**************************************************************************
; 	*** Determine which of the directional 1-d transects are 5-point peaks ***
;		**************************************************************************
;		===> East-West Peak
		EW = ((A - SHIFT_E) GT EPSILON) AND ((SHIFT_E - SHIFT(SHIFT_E, 1, 0)) GT EPSILON) AND $
				 ((A - SHIFT_W) GT EPSILON) AND ((SHIFT_W - SHIFT(SHIFT_W,-1, 0)) GT EPSILON)

;		===> North-South Peak
		NS = ((A - SHIFT_N) GT EPSILON) AND ((SHIFT_N - SHIFT(SHIFT_N, 0, 1)) GT EPSILON) AND $
				 ((A - SHIFT_S) GT EPSILON) AND ((SHIFT_S - SHIFT(SHIFT_S, 0,-1)) GT EPSILON)

;		===> Northeast-Southwest Peak
		NESW=((A - SHIFT_NE) GT EPSILON) AND ((SHIFT_NE - SHIFT(SHIFT_NE, 1, 1)) GT EPSILON) AND $
				 ((A - SHIFT_SW) GT EPSILON) AND ((SHIFT_SW - SHIFT(SHIFT_SW,-1,-1)) GT EPSILON)

;		===> Northeast-Southeast Peak
		NWSE=((A - SHIFT_NW) GT EPSILON) AND ((SHIFT_NW - SHIFT(SHIFT_NW,-1, 1)) GT EPSILON) AND $
				 ((A - SHIFT_SE) GT EPSILON) AND ((SHIFT_SE - SHIFT(SHIFT_SE, 1,-1)) GT EPSILON)

;		===> P5_MAX is the number of times a 5-point peak was found to be centered over each pixel
		P5_MAX = EW + NS + NESW + NWSE

;		==> Null the sides 2 pixels wide
		P5_MAX(*,0:1) 							= 0 ; Bottom Edge
		P5_MAX(*,NROWS-2:NROWS-1) 	= 0 ; Top Edge
		P5_MAX(0:1,*)								= 0 ; Left Side
		P5_MAX(NCOLS-2:NCOLS-1,*) 	= 0 ; Right Side

;		****************************************************************
;		*** Determine which of the directional transects are valleys ***
;		****************************************************************

;		===> East-West Valley
		EW = ((SHIFT_E - A) GT EPSILON) AND ((SHIFT(SHIFT_E, 1, 0) - SHIFT_E)  GT EPSILON) AND $
				 ((SHIFT_W - A) GT EPSILON) AND ((SHIFT(SHIFT_W,-1, 0) - SHIFT_W)  GT EPSILON)

;		===> North-South Valley
		NS = ((SHIFT_N - A) GT EPSILON) AND ((SHIFT(SHIFT_N, 0, 1) - SHIFT_N) GT EPSILON) AND $
				 ((SHIFT_S - A) GT EPSILON) AND ((SHIFT(SHIFT_S, 0,-1) - SHIFT_S) GT EPSILON)

;		===> Northeast-Southwest Valley
		NESW=((SHIFT_NE - A) GT EPSILON) AND ((SHIFT(SHIFT_NE, 1, 1) - SHIFT_NE) GT EPSILON) AND $
				 ((SHIFT_SW - A) GT EPSILON) AND ((SHIFT(SHIFT_SW,-1,-1) - SHIFT_SW) GT EPSILON)

;		===> Northeast-Southwest Valley
		NWSE=((SHIFT_NW - A) GT EPSILON) AND ((SHIFT(SHIFT_NW,-1, 1) - SHIFT_NW) GT EPSILON) AND $
				 ((SHIFT_SE - A) GT EPSILON) AND ((SHIFT(SHIFT_SE, 1,-1) - SHIFT_SE) GT EPSILON)

;		===> P5_MIN is the number of times a 5-point valley was found to be centered over each pixel
		P5_MIN = EW + NS + NESW + NWSE

;		==> Null the sides 2 pixels wide
		P5_MIN(*,0:1) 							= 0 ; Bottom Edge
		P5_MIN(*,NROWS-2:NROWS-1) 	= 0 ; Top Edge
		P5_MIN(0:1,*)								= 0 ; Left Side
		P5_MIN(NCOLS-2:NCOLS-1,*) 	= 0 ; Right Side

;		*********************************************
;		*** Conserve all 5-Point Peaks or Valleys ***
;		*********************************************
		OK=WHERE(P5_MAX GT 0 OR P5_MIN GT 0,COUNT)
		IF COUNT GE 1 THEN B[OK] = A[OK]

;		***************************************************************************************************
;		*** Replace Pixels that do not have 5-point VALLEY with median when number of neighbors =8
;		***************************************************************************************************
		OK = WHERE((P5_MAX EQ 0 AND P5_MIN EQ 0)  AND (P3_MIN EQ 8),COUNT)

		IF COUNT GE 1 THEN BEGIN
;			===> Obtain the x,y image coordinates from the OK subscripts found with the WHERE command
			XY = ARRAY_INDICES(A, OK)

	;		LLLLLLLLLLLLLLLLLLLLLLLLLLL
			FOR NTH =0,COUNT-1 DO BEGIN
				_COL=XY(0,NTH)
				_ROW=XY(1,NTH)

;				===> Get subscripts for the 8 pixels surrounding the central pixel in a 3x3 box and
;				ensure XP,YP subscripts are within NCOLS-1 AND NROWS-1
				XP= 0 > _COL+around_xps < (NCOLS-1)
				YP= 0 > _ROW+around_yps < (NROWS-1)

;				===> Determine the MIN difference between the center and its surrounding 8 pixels,
;				before the median is applied. Update DIF_8 but only for the first iteration
;				(Change sign so that the value stored is negative (below the surrounding 8 pixels)
				IF FILTERED(_COL,_ROW) EQ 0 THEN BEGIN

;					===> Store the FILTERED value
					FILTERED(_COL,_ROW) = 1 ; A(_COL,_ROW)
					DIF_8(_COL,_ROW) = -MIN(A(XP,YP) - A(_COL,_ROW),/NAN)
				ENDIF
;				===> Update B image with the median
				B(_COL,_ROW) = MEDIAN(A(_COL-1:_COL+1, _ROW-1:_ROW+1))
			ENDFOR
		ENDIF


;		***************************************************************************************************
;		*** Replace Pixels that do not have 5-point PEAK with median when number of neighbors =8
;		***************************************************************************************************
		OK = WHERE( (P5_MAX EQ 0 AND P5_MIN EQ 0)  AND (P3_MAX EQ 8),COUNT)

		IF COUNT GE 1 THEN BEGIN
;			===> Obtain the x,y image coordinates from the OK subscripts found with the WHERE command
			XY = ARRAY_INDICES(A, OK)

	;		LLLLLLLLLLLLLLLLLLLLLLLLLLL
			FOR NTH =0,COUNT-1 DO BEGIN
				_COL=XY(0,NTH)
				_ROW=XY(1,NTH)

;				===> Get subscripts for the 8 pixels surrounding the central pixel in a 3x3 box and
;				ensure XP,YP subscripts are within NCOLS-1 AND NROWS-1
				XP= 0 > _COL+around_xps < (NCOLS-1)
				YP= 0 > _ROW+around_yps < (NROWS-1)

;				===> Determine the MAX difference between the center and its surrounding 8 pixels,
;				before the median is applied. Update DIF_8 but only for the first iteration
;				(change sign so difference between the center max and surrounding values is positive)
				IF FILTERED(_COL,_ROW) EQ 0 THEN BEGIN
;					===> Store the FILTERED value
					FILTERED(_COL,_ROW) = 1 ; A(_COL,_ROW)
					DIF_8(_COL,_ROW) = MAX( -(A(XP,YP) - A(_COL,_ROW)),/NAN)
				ENDIF

;				===> Update B image with the median
				B(_COL,_ROW) = MEDIAN(A(_COL-1:_COL+1, _ROW-1:_ROW+1))
			ENDFOR
		ENDIF

;		== SAVE B in EITHER B1 or B2: ============================================
    IF SW EQ 1 THEN B1=B;
    IF SW EQ 2 THEN B2=B;
    IF SW EQ 1 THEN BEGIN
    	SW=SW+1;
    ENDIF ELSE BEGIN
    	SW=SW-1;
    ENDELSE

;		==========================================================================
    diff_L1 = MAX(ABS(A-B),/NAN);
    diff_l2 = TOTAL(ABS(A-B),/NAN)
    IF KEYWORD_SET(VERBOSE) THEN PRINT, 'ITER='+STRTRIM(ITER,2) +' diff_L1=' +STRTRIM(diff_L1,2) + '  diff_l2='+ STRTRIM(diff_l2,2)

;		===> Make A equal to B
		A = B

;		==========================================================================
    IF ITER GT 1 THEN BEGIN
        diff_AA_B1=MAX(AA-B1,/NAN);
        diff_AA_B2=MAX(AA-B2,/NAN);

        IF (diff_AA_B1 LT 0.001 OR diff_AA_B2 LT 0.001) THEN BEGIN
           FLAG=0;
        ENDIF ELSE BEGIN
           AA=A;
        ENDELSE;
    ENDIF;

	ENDWHILE ; WHILE diff_L1 GT diff_MIN_L1 DO BEGIN

	RETURN, A
END; #####################  End of Routine ################################

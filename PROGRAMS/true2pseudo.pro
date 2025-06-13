; $ID:	TRUE2PSEUDO.PRO,	2020-07-08-15,	USER-KJWH	$
FUNCTION true2pseudo, trueColorArr, r=R, g=G, b=B

;FILENAME:
;          true2pseudo.pro
;
;PURPOSE:
;          For a given color palette, convert 2-D true-color image to pseudo-color one
;
;CATEGORY:
;          Image, Color palette
;
;INPUT:
;          [1] true color image array with dimensions of
;                 (3, m, n) ;pixel interweave
;             or  (m, 3, n) ;line interweave
;             or  (m, n, 3) ;image interweave
;	   (2) [R, G, B] of given palette
;
;KEYWORD PARAMETERS:
;          R: 256-element vector for red color channel
;          G: 256-element vector for green color channel
;          B: 256-element vector for blue color channel
;
;OUTPUT:   2D array holding color index of each image pixel
;
;CALLS:
;          NONE
;
;CALLED BY:
;          (independent)
;
;CALLING SEQUENCE:
;	      array2D = true2pseudo(trueColorArr, r=R, g=G, b=G)
;
;SIDE EFFECTS:
;           NONE
;
;MODIFICATION HISTORY:
;    	    Written by Z. Yang, July 26, 2001.
;

 ; Examine whether keyword parameters are correctly set
 IF KEYWORD_SET(r) AND KEYWORD_SET(g) AND KEYWORD_SET(b) THEN BEGIN

     szR=LONG(SIZE(r, /DIMENSIONS))
     szG=LONG(SIZE(g, /DIMENSIONS))
     szB=LONG(SIZE(b, /DIMENSIONS))

     IF (szR[0] NE 256) OR (szG[0] NE 256) OR (szB[0] NE 256) THEN BEGIN
	 PRINT, " "
         PRINT, "------------------------------------"
         PRINT, "Sizes of vectors R, B, G are not all correct!"
         PRINT, "Program quits!"
	 PRINT, "------------------------------------"
	 PRINT, " "
	 RETURN, 0
     ENDIF

  ENDIF ELSE BEGIN
      PRINT, " "
      PRINT, "------------------------------------"
      PRINT, "Not all of R, G, B vectors are set!"
      PRINT, "Program quits!"
      PRINT, "------------------------------------"
      PRINT, " "

      RETURN, 0
  ENDELSE

 ;examine the input true color array (3D)
  nDimArr = SIZE(trueColorArr, /N_DIMENSIONS)
  dimArr = SIZE(trueColorArr, /DIMENSIONS)

  IF (nDimArr[0] EQ 3) THEN BEGIN

      ;colorTab = R + 256L*(G + 256L*B)

      dimInterWeave = WHERE(dimArr EQ 3)
      IF(dimInterWeave[0] EQ 0) THEN BEGIN
       	rArr = LONG(REFORM(trueColorArr[0,*,*]))
	  		gArr = LONG(REFORM(trueColorArr[1,*,*]))
 	   		bArr = LONG(REFORM(trueColorArr[2,*,*]))

      ENDIF ELSE BEGIN
	  		IF (dimInterWeave[0] EQ 1) THEN BEGIN
					rArr = LONG(REFORM(trueColorArr[*,0,*]))
	  			gArr = LONG(REFORM(trueColorArr[*,1,*]))
 	   			bArr = LONG(REFORM(trueColorArr[*,2,*]))

      	ENDIF ELSE BEGIN
	      	rArr = LONG(REFORM(trueColorArr[*,*,0]))
	  	gArr = LONG(REFORM(trueColorArr[*,*,1]))
 	   	bArr = LONG(REFORM(trueColorArr[*,*,2]))
	  ENDELSE
      ENDELSE

      szDim = SIZE(rArr, /DIMENSIONS)
      indexArr = INTARR(szDim[0], szDim[1])

      FOR tCol = 0, szDim[0]-1    DO BEGIN
        FOR tRow = 0, szDim[1]-1  DO BEGIN
           sumAbs =  ABS(R - rArr[tCol, tRow]) $
		   + ABS(G - gArr[tCol, tRow]) $
		   + ABS(B - bArr[tCol, tRow])

         tmp = MIN(sumAbs, tIdx)
         indexArr[tCol, tRow] = tIdx

        ENDFOR
      ENDFOR

  ENDIF ELSE BEGIN
      PRINT, " "
      PRINT, "------------------------------------"
      PRINT, "Input Array is not 3-Dimensional!"
      PRINT, "Program quits!"
      PRINT, "------------------------------------"
      PRINT, " "
      RETURN, 0
  ENDELSE

 RETURN, indexArr

END

; $ID:	MEDIAN_DIAGONAL.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;	This Function Returns the Median of a 2-d image using a moving DIAGONAL Box
; SYNTAX:;
;	 	Result = MEDIAN_DIAGONAL(Image,Width)
; OUTPUT:
;		Median of image
; ARGUMENTS:
; 	Image:	A 2-dimension array
; 	Width:	The size of the neighborhood to be used for the median filter.
;						A Width of 3 means that a pattern of 3x3 will be used, width of 5 = pattern 5x5
;						(A width of 5 means that the median_diagonal will be computed based on 13 values extracted from a 5x5 pattern.)
;           (Note that a conventional median,3 computes the median based on 9 values).
; KEYWORDS:
;
; EXAMPLE:
;		Result = MEDIAN_DIAGONAL(Image,5) ; for smoothing image striping in OCTS
;
; CATEGORY:
;		IMAGE
; NOTES:
; 	Potentially useful for dealing with Regular Patterns of Horizontal Scan Stripes (e.g. OCTS)
; 	Improvements Needed: An algorithm is needed to make the Diagonal Pattern automatically, and for any Width
;       (Presently the Pattern is limited to Width of between 3 and 13.
; VERSION:
;		July 24, 2001
; HISTORY:
;		July 11, 2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

FUNCTION MEDIAN_DIAGONAL,Image,Width, SHOW=show, TEST=test,NUM=NUM,_EXTRA=_extra
  ROUTINE_NAME='MEDIAN_DIAGONAL'


  IF KEYWORD_SET(TEST) THEN BEGIN
     Image = [[0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10],$
              [1, 2, 3, 4, 5, 6, 7, 8, 9,10, 0],$
              [10,0, 1, 2, 3, 4, 5, 6, 7, 8, 9],$
              [5, 6, 7, 8, 9,10, 0, 1, 2, 3, 4],$
              [3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3],$
              [10,9, 8, 7, 6, 5, 4, 3, 2, 1, 0],$
              [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],$
              [3, 2, 1, 0, 3, 2, 1, 0, 3, 2, 1],$
              [10,8, 6, 6, 6, 8, 8,10, 6, 3, 3],$
              [1, 2, 3, 4, 5, 6, 7, 8, 9,10, 0],$
              [3, 4, 3, 4, 3, 4, 3, 4, 3, 4, 3]]
              print, image
  ENDIF


; ====================>
  SZ=SIZE(Image,/STRUCT)
  IF SZ.N_DIMENSIONS NE 2 THEN BEGIN
    PRINT,'ERROR: Image must be 2-dimensional array'
    RETURN,-1
  ENDIF
; ====================>
  IF N_ELEMENTS(Width) NE 1 THEN BEGIN
    PRINT,'ERROR: Must provide Width of median box'
    RETURN, -1
  ENDIF

; ==================> Make width fixed
  iwidth = FIX(width)

; ====================> Ensure iwidth is odd and between 3 and 13
  IF iwidth MOD 2 EQ 0 OR iwidth LT 3 OR iwidth GT 13 THEN BEGIN
    PRINT,'ERROR: Width must be odd number between 3,13'
    RETURN, -1
  ENDIF

; ====================> Get image pixel dimensions -1
  nth_X	=	SZ.DIMENSIONS[0]-1
  nth_Y	=	SZ.DIMENSIONS[1]-1

  half = iwidth /2 ; Integer Divide (If iwidth is 5 then half is 2)

  _iwidth = iwidth -1

 	IF iwidth EQ 3 THEN BEGIN
    PATTERN = [[0,1,0],$
         		   [1,1,1],$
         		   [0,1,0]]
  ENDIF

  IF iwidth EQ 5 THEN BEGIN
    PATTERN = [[0,0,1,0,0],$
         		   [0,1,1,1,0],$
         		   [1,1,1,1,1],$
         		   [0,1,1,1,0],$
         		   [0,0,1,0,0]]
  ENDIF

	IF iwidth EQ 7 THEN BEGIN
    PATTERN = [[0,0,0,1,0,0,0],$
         	  	 [0,0,1,1,1,0,0],$
         	  	 [0,1,1,1,1,1,0],$
         	  	 [1,1,1,1,1,1,1],$
         		   [0,1,1,1,1,1,0],$
         		   [0,0,1,1,1,0,0],$
         		   [0,0,0,1,0,0,0]]
  ENDIF

	IF iwidth EQ 9 THEN BEGIN
  PATTERN = [[0,0,0,0,1,0,0,0,0],$
         		 [0,0,0,1,1,1,0,0,0],$
         		 [0,0,1,1,1,1,1,0,0],$
         		 [0,1,1,1,1,1,1,1,0],$
         		 [1,1,1,1,1,1,1,1,1],$
         		 [0,1,1,1,1,1,1,1,0],$
         		 [0,0,1,1,1,1,1,0,0],$
         		 [0,0,0,1,1,1,0,0,0],$
         		 [0,0,0,0,1,0,0,0,0]]
  ENDIF

	IF iwidth EQ 11 THEN BEGIN
  	PATTERN = [[0,0,0,0,0,1,0,0,0,0,0],$
      	   		 [0,0,0,0,1,1,1,0,0,0,0],$
       	  		 [0,0,0,1,1,1,1,1,0,0,0],$
        	 		 [0,0,1,1,1,1,1,1,1,0,0],$
         			 [0,1,1,1,1,1,1,1,1,1,0],$
         			 [1,1,1,1,1,1,1,1,1,1,1],$
         			 [0,1,1,1,1,1,1,1,1,1,0],$
         			 [0,0,1,1,1,1,1,1,1,0,0],$
         			 [0,0,0,1,1,1,1,1,0,0,0],$
         			 [0,0,0,0,1,1,1,0,0,0,0],$
         			 [0,0,0,0,0,1,0,0,0,0,0]]

  ENDIF

 IF iwidth EQ 13 THEN BEGIN
  	PATTERN =[[0,0,0,0,0,0,1,0,0,0,0,0,0],$
  						[0,0,0,0,0,1,1,1,0,0,0,0,0],$
  						[0,0,0,0,1,1,1,1,1,0,0,0,0],$
  						[0,0,0,1,1,1,1,1,1,1,0,0,0],$
  						[0,0,1,1,1,1,1,1,1,1,1,0,0],$
  						[0,1,1,1,1,1,1,1,1,1,1,1,0],$
  						[1,1,1,1,1,1,1,1,1,1,1,1,1],$
  						[0,1,1,1,1,1,1,1,1,1,1,1,0],$
  						[0,0,1,1,1,1,1,1,1,1,1,0,0],$
  						[0,0,0,1,1,1,1,1,1,1,0,0,0],$
  						[0,0,0,0,1,1,1,1,1,0,0,0,0],$
  						[0,0,0,0,0,1,1,1,0,0,0,0,0],$
  						[0,0,0,0,0,0,1,0,0,0,0,0,0]]
  ENDIF


  OK = WHERE(PATTERN EQ 1)
  STOP
  IF KEYWORD_SET(NUM) THEN RETURN,N_ELEMENTS(OK)

  IF KEYWORD_SET(SHOW) THEN PRINT, STRCOMPRESS(STRING(PATTERN))
  COUNT = iwidth*iwidth

; ====================> Make a copy of the input image
  COPY=IMAGE

; *********************************************************************
; ***** P r o c e s s   I n t e r i o r   o f  I m a g e  *************
; *********************************************************************
  image_left 		= 0 		+ half
  image_right 	= nth_X - half
  image_bottom 	= 0 		+ half
  image_top    	= nth_Y - half
  PAT = PATTERN(0:*,0:*) ; Use Full pattern, do not process sides of image
  OK = WHERE(PAT EQ 1)   ; Find subscripts in pat for median_diagonal to use
  FOR Y=image_bottom,image_top DO BEGIN
    bottom	= y	-	half
    top   	=	y	+	half
   	FOR X=image_left,image_right  DO BEGIN
  		Left 			= x - half
    	Right 		= x + half
      BOX 			= IMAGE(left:right,bottom:top)
      COPY(X,Y) = MEDIAN(BOX[OK])
  	ENDFOR
  ENDFOR


; *********************************************************************
; ********   P r o c e s s   E d g e s   of  I m a g e  ***************
; *********************************************************************


  POS = [$
  			[0,							nth_X,					0,							half-1],$
  			[0,     				nth_X,    			nth_y-half+1,		nth_Y ],$
  			[0,  						half-1,  				0, 							nth_Y ],$
				[nth_X-half+1,	nth_x,					0,							nth_Y ]]



; ====================> Process bottom,top,left,right sides of image
	FOR side=0,3 DO BEGIN

  	image_left 	= pos(0,side)
  	image_right = pos(1,side)
  	image_bot 	= pos(2,side)
  	image_top 	= pos(3,side)


 		FOR Y=image_bot,image_TOP DO BEGIN
 		  bot			=	y-half
      top   	=	y+half
      B_BOT 	= 0 > bot < nth_Y
      B_top   = 0 > top < nth_Y
      p_bot   = ABS(bot < 0)
      P_TOP =  (_iwidth - (TOP - nth_Y)) < _iwidth

  		FOR X=image_left,image_right  DO BEGIN
  	 		B_Left= 0 > (x-half) < nth_X
  	 		B_right=0 > (x+half) < nth_X
      	Left =  x - half
      	Right = x + half
      	p_left =  ABS(left < 0)

      	P_RIGHT =  (_iwidth - (RIGHT - nth_x)) < _iwidth

      	PAT = PATTERN(p_left:p_right,p_bot:p_top)
      	BOX = IMAGE(B_left:B_right,B_bot:B_top)
      	OK = WHERE(PAT EQ 1)
      	COPY(X,Y) = MEDIAN(BOX[OK])

      	;print, b_left,b_right,b_bot,b_top,' box'
      	;print, p_left,p_right,p_bot,p_top,' pattern'
      	;print, 'pat',pat
        ;print, 'box',box
        ;print, 'box ok',box(ok)
      	;print, MEDIAN(BOX(OK)),' median'
      	 print,rotate(pat,7)
      	 print
      	 stop
  		ENDFOR
  	ENDFOR
	ENDFOR


  RETURN,COPY


END; #####################  End of Routine ################################

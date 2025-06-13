; $ID:	HIST_2D_IDL_DEMO.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;#############################################################################################################
	PRO HIST_2D_IDL_DEMO,FILE,FILTER=FILTER

;
; PURPOSE: DEMO FOR IDL HIST2D FUNCTION
;
; CATEGORY:	DEMO
;
; CALLING SEQUENCE: HIST_2D_IDL_DEMO
;
; INPUTS: STRUCTURE
;		
; OPTIONAL INPUTS:
;		NONE:	
;		
; KEYWORD PARAMETERS:
;		NONE:

; OUTPUTS: 
;		
; EXAMPLES: 
;
; MODIFICATION HISTORY:
;			APR 24,2014,   WRITTEN BY J.O'REILLY
;			
;			
;			
;#################################################################################
;
;-
;********************************
ROUTINE_NAME  = 'HIST_2D_IDL_DEMO'
;********************************
; Read an RGB image of a rose.

file = FILE_WHICH('rose.jpg')
rose = READ_IMAGE(file)
; Compare the red versus green bands of the image, in 5 x 5 bins.
red_band = rose[0,*,*]
green_band = rose[1,*,*]
h2d = HIST_2D(red_band, green_band, bin1=5, bin2=5)
; Resize (with nearest-neighbor sampling) the
; output array of bins to the original range of
; intensities in the red and green bands, [0-255].

h2d = CONGRID(h2d, MAX(red_band), MAX(green_band))
; Squash peaks by displaying logs of bins.
h2d = BYTSCL(ALOG10(h2d > 1))
; Plot the 2D histogram.
ct = COLORTABLE(0, /REVERSE)
CT = RGBS(PAL='PAL_SW3')
_SMOOTH = 1
SZ = SIZEXYZ(H2D) & PX = SZ.PX & PY = SZ.PY

  H2D  = CONGRID(H2D, PX*_SMOOTH, PY*_SMOOTH,/CENTER,INTERP=0)
OK = WHERE(H2D EQ 0,COUNT) & IF COUNT GE 1 THEN H2D[OK] = 255
g0 = IMAGE(h2d, RGB_TABLE=ct, AXIS_STYLE=2, MARGIN=0.1, $
XTITLE='Red band pixel intensity', $
YTITLE='Green band pixel intensity', $
TITLE='Density plot of red vs green intensities in $\bf rose.jpg$')
;g1 = IMAGE(rose, POSITION=[0.20, 0.65, 0.40, 0.85], /CURRENT)
STOP

END; #####################  END OF ROUTINE ################################

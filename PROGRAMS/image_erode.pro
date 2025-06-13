; $Id: IMAGE_ERODE.pro,  J.E.O'Reilly Exp $

pro IMAGE_ERODE, IMAGE
;+
; NAME:
;       IMAGE_ERODE
;
; PURPOSE:
;
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = template(a)
;
; INPUTS:
;
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
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
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Jan, 1995.
;-


;IMAGE = DIST(512)
;_MAX = MAX(IMAGE)
;IMAGE = BYTSCL(IMAGE)

arr = readall('f:/sst_necw/MED1998JAN.ARR')
image = bytscl(arr,min=0,max=3200)


MASK = IMAGE eq 0	;Threshold and make binary image.
MASK = IMAGE
ok = where(image eq 0)
mask(ok) =255
S = REPLICATE(1, 21, 21)	;Create the shape operator.
values = s
values(*,*) = 1
;DILATED = DILATE(ERODE(MASK, S,/GRAY,values=values), S,/gray,values=values)	;"Opening" operator.
;DILATED = ERODE(MASK, S,/GRAY,values=values)

ERODED= ERODE(MASK, S,/GRAY,values=values)
DIALTED= DILATE(ERODED, S,/GRAY,values=values)
slidew, ERODED, title='ERODED'	;Show the result.
slidew, DILATED, title='DIALATED'	;Show the result.

STOP


END
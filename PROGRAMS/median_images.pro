; $ID:	MEDIAN_IMAGES.PRO,	2020-07-08-15,	USER-KJWH	$

 FUNCTION MEDIAN_IMAGES, ARRAY
;+
; NAME:
;       MEDIAN_IMAGES
;
; PURPOSE:
;       Compute the median of data in the first dimension of
;       a 3-dimensional array and output a 2-d array of median values
;
; CATEGORY:
;       Statistics, Image
;
; CALLING SEQUENCE:
;       Result = MEDIAN_IMAGES(array)
;
; INPUTS:
;       A 3 d array with the first dimension the number of images and
;       wih the second and third dimensions the pixel x and pixel y data
;       for each image
;
; KEYWORD PARAMETERS:
;       NONE
;
; OUTPUTS:
;       A 2-D ARRAY CONTAINING THE MEDIAN VALUES computed from data from the first
;       dimension of the input 3-d array.
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       Median is computed using Data in the first dimension of the 3-d array
;       Present version does not average the two middle values of an even-numbered array
;       (works like IDL MEDIAN without EVEN keyword)
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Feb 21,1999

; ===============>
; Check that the input array is 3-dimensions
  s=SIZE(ARRAY)
  IF S[0] NE 3 THEN BEGIN
   A= DIALOG_MESSAGE('ARRAY MUST BE 3 DIMENSIONS')
  ;  RETURN,-1
  ENDIF

; =================>
  NDIM = S[1]
  PX   = S(2)
  PY   = S(3)
  N    = S(5)

; ====================>
; Compute the median of each element of the refomed array
  DATA =  MEDIAN(REFORM(TEMPORARY(ARRAY),N),NDIM)
; Extract the middle values
  DATA =  TEMPORARY(DATA(LINDGEN(PX*PY)*NDIM + NDIM/2L))
; Reform the middle values into a 2-d array
  RETURN, REFORM(TEMPORARY(DATA),PX,PY)

  END ; END OF PROGRAM


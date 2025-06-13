; $ID:	HIST_3D.PRO,	2020-06-30-17,	USER-KJWH	$
; Copyright (c) 1992, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.
;
function hist_3d, im1, im2, im3
;+
; NAME:
;	HIST_3d
;
; PURPOSE:
;	Return the density function (histogram) of two variables.
;
; CATEGORY:
;	Image processing, statistics, probability.
;
; CALLING SEQUENCE:
;	Result = hist_3d(V1, V2 , V3)
; INPUTS:
;	V1 and V2 and V3 = arrays containing the variables.  They must be
;		of byte, integer, or longword type, and contain
;		no negative elements.
;
; OUTPUTS:
;	The three dimensional density function of the two variables,
;	a longword array of dimensions (MAX(v1)+1, MAX(v2)+1,MAX(v3)+1).  Result(i,j,k)
;	is equal to the number of sumultaneous occurences of V1 = i,
;	and V2 = j, and V3 = k at the same element.
;
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	None.
; RESTRICTIONS:
;	Data must be in byte, integer, or longword form.  To use with
;	floating point data, scale into the range of integers.
;
; PROCEDURE:
;	Creates a combines array from the two variables, equal to the
;	linear subscript in the resulting 3d histogram, then applies
;	the standard histogram function.
;
;	The following pseudo-code shows what the result contains,
;	not how it is computed:
;		r = LONARR(MAX(v1)+1, MAX(v2)+1, MAX(v3)+1)  ;Result
;		FOR i=0, N_ELEMENTS(v1)-1 DO $
;		  r(v1(i), v2(i)) = r(v1(i), v2(i)) +1

; EXAMPLE:
;	Return the 3d histogram of three byte images:
;		R = HIST_3d(image1, image2, image3)

;
; MODIFICATION HISTORY:
; 	Written by:
;	DMS, Sept, 1992		Written
;   Copied from IDL's hist_2d, and modified to handle 3 dimensions JOR NOV 17,1995
;-

; Form the 3 dimensional histogram of three byte, integer, or longword
;  images.  They must not contain negative numbers.
; Result(i,j,k) = density of pixel value i in im1, and pixel value j
;	in im2 and pixel value k in im3.
; Input images must be, of course, the same size....
;

s1 = size(im1)		;Check types
s2 = size(im2)
s3 = size(im3)
if (s1(s1[0]+1) gt 3) or (s2(s2[0]+1) gt 3) or (s3(s3[0]+1) gt 3) then $
	message, 'Arrays must be byte, integer, or longword'


m1 = max(im1, min=mm1)+1L	;Get size of resulting rows / columns
m2 = max(im2, min=mm2)+1L
m3 = max(im3, min=mm3)+1L

if mm1 lt 0 or mm2 lt 0 or mm3 lt 0 then message,'Arrays contain negative elements'

 ;sum = m1 * im2 + im1		;Combine with im1 in low part & im2 in high
sum = m1*m2 * im2*im3 + im1
print,sum &help,sum
h = histogram(sum, min = 0, max= m1 * m2 *m3 -1 )  ;Get the 1D histogram


return, reform(h, m1, m2, m3, /overwrite) ;and make it 3d
;return, reform(h, [m1, m2], /overwrite) ;and make it 3d
end

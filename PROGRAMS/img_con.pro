; $ID:	IMG_CON.PRO,	2020-07-08-15,	USER-KJWH	$

pro img_con, a,b, WINDOW_SCALE = window_scale,$
                  ASPECT = aspect, $
                  INTERP = interp, $
                  nocontour=NOCONTOUR,$
                  _EXTRA=_extra



;+
; NAME:
;       IMG_CON
;       Modified from IDL image_cont.pro
;
; PURPOSE:
;       Overlay an image and a contour plot.
;
; CATEGORY:
;       General graphics.
;
; CALLING SEQUENCE:
;       IMG_CON, A,B
;
; INPUTS:
;       A:      The two-dimensional array to display super pixels of array.
;       B:      A Second two-dimensional array to use for overlaying contours.

;
; KEYWORD PARAMETERS:
; WINDOW_SCALE: Set this keyword to scale the window size to the image size.
;               Otherwise, the image size is scaled to the window size.
;               This keyword is ignored when outputting to devices with
;               scalable pixels (e.g., PostScript).
;
;       ASPECT: Set this keyword to retain the image's aspect ratio.
;               Square pixels are assumed.  If WINDOW_SCALE is set, the
;               aspect ratio is automatically retained.
;
;       INTERP: If this keyword is set, bilinear interpolation is used if
;               the image is resized.

; OUTPUTS:
;       No explicit outputs.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       The currently selected display is affected.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       If the device has scalable pixels, then the image is written over
;       the plot window.
;
; MODIFICATION HISTORY:
;       DMS, May, 1988.
;       J.O'Reilly, December 4,1994:  added additional parameter (b).  Image is made from
;                                     array (a) while line contours are made from array (b).
;                                     Also added keyword _EXTRA to pass other contouring
;                                     parameters into the program.
;
;-


on_error,2                      ;Return to caller if an error occurs
sz = size(a)                    ;Size of image
if sz[0] lt 2 then message, 'Parameter not 2D'


        ;set window used by contour
 contour,[[0,0],[1,1]],/nodata, xstyle=4, ystyle = 4,_EXTRA=_extra

;PLOT,!X.CRANGE, !Y.CRANGE,/nodata, xstyle=4, ystyle = 4,_EXTRA=_extra




px = !x.window * !d.x_vsize     ;Get size of window in device units
py = !y.window * !d.y_vsize
swx = px[1]-px[0]               ;Size in x in device units
swy = py[1]-py[0]               ;Size in Y
six = float(sz[1])              ;Image sizes
siy = float(sz(2))
aspi = six / siy                ;Image aspect ratio
aspw = swx / swy                ;Window aspect ratio
f = aspi / aspw                 ;Ratio of aspect ratios



if (!d.flags and 1) ne 0 then begin     ;Scalable pixels?
  if keyword_set(aspect) then begin     ;Retain aspect ratio?
                                ;Adjust window size
        if f ge 1.0 then swy = swy / f else swx = swx * f
        endif

;  tvscl,a,px[0],py[0],xsize = swx, ysize = swy, /device
   tv,   a,px[0],py[0],xsize = swx, ysize = swy, /device


endif else begin        ;Not scalable pixels
   if keyword_set(window_scale) then begin ;Scale window to image?
        tv,a,px[0],py[0]      ;Output image
        swx = six               ;Set window size from image
        swy = siy
    endif else begin            ;Scale window
        if keyword_set(aspect) then begin
                if f ge 1.0 then swy = swy / f else swx = swx * f
                endif           ;aspect
        tv,poly_2d(a,$  ;Have to resample image
                [[0,0],[six/swx,0]], [[0,siy/swy],[0,0]],$
                keyword_set(interp),swx,swy), $
                px[0],py[0]
        endelse                 ;window_scale
  endelse                       ;scalable pixels

;mx = !d.n_colors-1              ;Brightest color
;colors = [0]       ;color vector
;colors = [mx,mx,mx,0,0,0]

IF KEYWORD_SET(NOCONTOUR) EQ 0 THEN BEGIN
contour,b,/noerase,/xst,/yst,$  ;Do the contour
           pos = [px[0],py[0], px[0]+swx,py[0]+swy],/dev,$
           _EXTRA = _extra
ENDIF


RETURN
end

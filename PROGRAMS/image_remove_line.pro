PRO IMAGE_REMOVE_LINE

FILE='C:\AANON\1998_229_0840_n14_er_s7_AVHRR_UNNAV__NEC_SST.png'
STOP
; Import image from file into IDL.
image = READ_PNG(file)

;_IMAGE= IMAGE((1024-256):*,(1024-256):*)
_IMAGE= IMAGE(0:300,0:300)

; Determine size of image.
imageSize = SIZE(_image, /DIMENSIONS)

STOP
; Display cropped image
SLIDEW, _IMAGE


; Mask intensity image to highlight power lines.
mask = _IMAGE GE 1 AND _IMAGE LE 250

; Determine size of intensity image.
intensitySize = IMAGESIZE



; Transform mask.
transform = HOUGH(IMAGE, RHO = rho, THETA = theta)

STOP
; Scale transform to obtain just the power lines.
transform = (TEMPORARY(transform) - 100) > 0

; Backproject to compare with original image.
backprojection = HOUGH(transform, /BACKPROJECT, $
   RHO = rho, THETA = theta, $
   NX = intensitySize[0], NY = intensitySize[1])

; Reverse color table to clarify lines. If you are on
; a TrueColor display, set the DECOMPOSED keyword to 0
; before using any color table related routines.
DEVICE, DECOMPOSED = 0
LOADCT, 0
TVLCT, red, green, blue, /GET
TVLCT, 255 - red, 255 - green, 255 - blue

; Display results.
WINDOW, 1, XSIZE = intensitySize[0], $
   YSIZE = intensitySize[1], $
   TITLE = 'Resulting Power Lines'
TVSCL, backprojection

END


SLIDEW, backprojection

END


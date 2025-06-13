; $Id: IMAGE_WELD_DEMO.pro $  VERSION: Sept 4,2003
;+
;	This Program Demonstrates combining 8-bit and 24-bit (true color) images by using IMAGE_WELD.PRO
;	IMAGE_WELD_DEMO

; HISTORY:
;		June 4, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;		Sept 3 2003 add portrait
;-
; *************************************************************************

PRO IMAGE_WELD_DEMO,FILES
  ROUTINE_NAME='IMAGE_WELD_DEMO'


FILES=FILELIST('D:\WORK\!Y_*-!YEAR-PP-VGPM2A-NEC-PXY_1024_1024-PPD-MEANS-RATIO-LEG.PNG')

LIST, FILES










STOP
STOP


; ******************************************************************************
; *** Weld two 8-bit grayscale paletted images together and write a png file ***
; ******************************************************************************
  image1=BYTSCL(DIST(512))
  image2=BYTSCL(DIST(256))+50
  IMAGE2=IMAGE2(0:150,75:250)

; ===> Get a palette r,g,b
; NOTE: to sidestep the limited number of colors (236 instead of 256) available with the default graphics
;       window, set the graphics window to the Z device, where all 256 colors are available
  OLD_DEVICE = !D.NAME
  SET_PLOT,'Z' & DEVICE, SET_COLORS=256
  LOADCT,31 & TVLCT,R,G,B,/GET

;	===> Weld images and write a pngfile
  both  = IMAGE_WELD(image1,image2, SPACE=10,background=255)
  pngfile = ROUTINE_NAME+'_8bit_portrait.png'
  WRITE_PNG,pngfile,both,r,g,b
  SET_PLOT, old_device


; ****************************************************************************************
; *** Weld two 8-bit grayscale paletted images together (REVERSE) and write a png file ***
; ****************************************************************************************
  image1=BYTSCL(DIST(512))
  image2=BYTSCL(DIST(256))+50
  IMAGE2=IMAGE2(0:150,75:250)
; ===> Get a palette r,g,b
; NOTE: to sidestep the limited number of colors (236 instead of 256) available with the default graphics
;       window, set the graphics window to the Z device, where all 256 colors are available
  OLD_DEVICE = !D.NAME
  SET_PLOT,'Z' & DEVICE, SET_COLORS=256
  LOADCT,31 & TVLCT,R,G,B,/GET

;	===> Weld images and write a pngfile
  both  = IMAGE_WELD(image1,image2, SPACE=10,background=255,/REVERSE)
  pngfile = ROUTINE_NAME+'_8bit_Portrait_Reverse.png'
  WRITE_PNG,pngfile,both,r,g,b
  SET_PLOT, old_device


; ******************************************************************************
; *** Weld two 8-bit grayscale paletted images together LANDSCAPE and write a png file ***
; ******************************************************************************
  image1=BYTSCL(DIST(512))
  image2=BYTSCL(DIST(256))+50
  IMAGE2=IMAGE2(0:150,75:250)
; ===> Get a palette r,g,b
; NOTE: to sidestep the limited number of colors (236 instead of 256) available with the default graphics
;       window, set the graphics window to the Z device, where all 256 colors are available
  OLD_DEVICE = !D.NAME
  SET_PLOT,'Z' & DEVICE, SET_COLORS=256
  LOADCT,31 & TVLCT,R,G,B,/GET

;	===> Weld images and write a pngfile
  both  = IMAGE_WELD(image1,image2, SPACE=10,background=255,/LANDSCAPE)
  pngfile = ROUTINE_NAME+'_8bit_landscape.png'
  WRITE_PNG,pngfile,both,r,g,b
  SET_PLOT, old_device


; **************************************************************************************************
; *** Weld two 8-bit grayscale paletted images together LANDSCAPE & REVERSE and write a png file ***
; **************************************************************************************************
  image1=BYTSCL(DIST(512))
  image2=BYTSCL(DIST(256))+50
  IMAGE2=IMAGE2(0:150,75:250)
; ===> Get a palette r,g,b
; NOTE: to sidestep the limited number of colors (236 instead of 256) available with the default graphics
;       window, set the graphics window to the Z device, where all 256 colors are available
  OLD_DEVICE = !D.NAME
  SET_PLOT,'Z' & DEVICE, SET_COLORS=256
  LOADCT,31 & TVLCT,R,G,B,/GET

;	===> Weld images and write a pngfile
  both  = IMAGE_WELD(image1,image2, SPACE=10,background=255,/LANDSCAPE,/REVERSE)
  pngfile = ROUTINE_NAME+'_8bit_Landscape_Reverse.png'
  WRITE_PNG,pngfile,both,r,g,b
  SET_PLOT, old_device





; ******************************************************************************
; ******* Weld two 24-bit TRUE COLOR images together and write a png file ******
; ******************************************************************************
  image1=BYTSCL(DIST(512))
  image2=BYTSCL(DIST(1024))
  IMAGE2=IMAGE2(0:150,75:250)
; ===> Get a palette r,g,b
; NOTE: to sidestep the limited number of colors (236 instead of 256) available with the default graphics
;       window, set the graphics window to the Z device, where all 256 colors are available
  OLD_DEVICE = !D.NAME
  SET_PLOT,'Z' & DEVICE, SET_COLORS=256

; ===> Get the r,g,b values to apply to the image1
  LOADCT,31 & TVLCT,R,G,B,/GET
; ===> Make image1 a true color image
	image1=IMAGE_2TRUE(image1,r,g,b)

; ===> Get the r,g,b values to apply to the image2
  LOADCT,0 & TVLCT,R,G,B,/GET
; ===> Make image1 a true color image
	image2=IMAGE_2TRUE(image2,r,g,b)

;	===> Weld images and write a pngfile
  both  = IMAGE_WELD(image1,image2, SPACE=10,background=255)
  pngfile = ROUTINE_NAME+'_24bit_Portrait.png'
  WRITE_PNG,pngfile,both,r,g,b
  SET_PLOT, old_device


; ****************************************************************************************************
; ******* Weld two 24-bit TRUE COLOR images together (LANDSCAPE & REVERSE) and write a png file ******
; ****************************************************************************************************
  image1=BYTSCL(DIST(512))
  image2=BYTSCL(DIST(1024))
  IMAGE2=IMAGE2(0:150,75:250)
; ===> Get a palette r,g,b
; NOTE: to sidestep the limited number of colors (236 instead of 256) available with the default graphics
;       window, set the graphics window to the Z device, where all 256 colors are available
  OLD_DEVICE = !D.NAME
  SET_PLOT,'Z' & DEVICE, SET_COLORS=256

; ===> Get the r,g,b values to apply to the image1
  LOADCT,31 & TVLCT,R,G,B,/GET
; ===> Make image1 a true color image
	image1=IMAGE_2TRUE(image1,r,g,b)

; ===> Get the r,g,b values to apply to the image2
  LOADCT,0 & TVLCT,R,G,B,/GET
; ===> Make image1 a true color image
	image2=IMAGE_2TRUE(image2,r,g,b)

;	===> Weld images and write a pngfile
  both  = IMAGE_WELD(image1,image2, SPACE=10,background=255,/LANDSCAPE,/REVERSE)
  pngfile = ROUTINE_NAME+'_24bit_Landscape_Reverse.png'
  WRITE_PNG,pngfile,both,r,g,b
  SET_PLOT, old_device

END; #####################  End of Routine ################################

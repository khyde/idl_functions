PRO IMAGE_DEMO

;+
; NAME:
;   IMAGE_DEMO
;
; PURPOSE:;
;   This procedure is to test the new plotting and image routines in IDL 8.0
;
; NOTES:
;
; MODIFICATION HISTORY:
;     Written May 16, 2011 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'IMAGE_DEMO'
  
  file1 = FILEPATH('Night.jpg', SUBDIRECTORY=['examples','data'])
  file2 = FILEPATH('Day.jpg',   SUBDIRECTORY=['examples','data'])
  
  ; The image spans [-180,180], [-90,90], with a lower-left pixel at [-180,-90]. Restrict the range to one hemisphere.
  im1 = IMAGE(file1,BACKGROUND_COLOR='white',IMAGE_DIMENSIONS=[360,180],IMAGE_LOCATION=[-180,-90],XRANGE=[-180,0],YRANGE=[-90,90],DIMENSIONS=[512,512], MARGIN=0)

  ; Overplot another image, same dimensions.
  im2 = IMAGE(file2, /OVERPLOT,IMAGE_DIMENSIONS=[360,180],IMAGE_LOCATION=[-180,-90],TRANSPARENCY=50)

  t = TEXT(-175, 80, '$\it Day/Night$',/DATA, FONT_SIZE=20, color='white')
  ; Fade between the two.
  for i=-100,100 do im2.TRANSPARENCY=abs(i)
 

  


  

  
  stop
  
  
  END
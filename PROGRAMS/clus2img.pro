; $ID:	CLUS2IMG.PRO,	2020-06-26-16,	USER-KJWH	$

PRO CLUS2IMG,avhrr=avhrr,czcs=czcs,output=output,NUMBER=NUMBER,ITER=ITER,shrink=SHRINK
;+
; NAME:
;       clus2img
;
; PURPOSE:
;       clusters two DSP imageS into homogeneous domains
;		AVHRR and CZCS images of the same area may be input to program
;
; CATEGORY:
;       Statistics, Image
;
; CALLING SEQUENCE:
;       clus2img,number=5,iter=10
;
; INPUTS:
;       DSP image files
;
; KEYWORD PARAMETERS:
;
;		AVHRR :  name of DSP AVHRR IMAGE FILE
;		CZCS  :  name of DSP CZCS IMAGE FILE
;		NUMBER:  The number of desired output clusters (subareas), passed to kmeans.pro
;		ITER  :  The number of iterations in the clustering program, passed to kmeans.pro
;
; OUTPUTS:
;      	CLUSTERED IMAGE WITH BYTE VALUES OF 1,2,3,4,... REPRESENTING THE SUBAREAS
;       OR, an output dsp image file
;
; SIDE EFFECTS:
;       Takes a lot of computation time .
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, April, 1995.
;       Modified: December 5,1995, added OK to cluster just non zeros and non clouds
;		to speed up program
;
;-

; fudge ===>
; avhrr= '/c1/pathfdr6/globec/czcs/M82125181755.gnm'
; czcs= '/c1/pathfdr6/globec/czcs/clk_nm/c82125155446.clk_nm'
  avhrr='d:\czcs_cal\M8212518.gnm'
  czcs='d:\czcs_cal\c8212515.clk'
  landimage='d:\czcs_cal\dsp\globland.dsp'

; ====================>
; start timer
  TIMER,/START

; ====================>
  GETLAND:
  READ_DSP,file = landimage,image=GLOBLAND,/quiet

; ====================>
; Check keywords

IF KEYWORD_SET(ITER)   EQ 0 THEN ITER   = 1
IF KEYWORD_SET(NUMBER) EQ 0 THEN NUMBER = 2
IF KEYWORD_SET(AVHRR)  EQ 0 THEN AVHRR  = PICKFILE(/READ)
IF KEYWORD_SET(CZCS)   EQ 0 THEN CZCS   = PICKFILE(/READ)
IF KEYWORD_SET(SHRINK) EQ 0 THEN SHRINK = 512
print, 'avhrr file= ', avhrr
print, 'czcs file = ', czcs

; ====================>
; Read the two dsp files
  READ_DSP,FILE=AVHRR,IMAGE=IMAGE1,/QUIET
  READ_DSP,FILE=CZCS ,IMAGE=IMAGE2,/QUIET

;  i1 = image1
;  i2 = image2
;  copyglob=globland


  copy1    = CONGRID(image1,shrink,shrink)
  copy2    = CONGRID(image2,shrink,shrink)
  copyglob = CONGRID(GLOBLAND,shrink,shrink)

; ====================>
; Determine where the (mutually inclusive) good pixels are over water:
  ok = WHERE(copyglob NE 0 AND $
             copy1    GE 5 AND copy1 LT 255 AND $
             copy2    GE 1 AND copy2 LE 249)


; ====================>
; ; MAKE i1,i2 float arrays
  i1=FLOAT(copy1)
  i2=FLOAT(copy2)

; ====================>
; MAKE ALL VALUES NOT A NUMBER (MISSING)
  i1(*,*) = !VALUES.F_NAN
  i2(*,*) = !VALUES.F_NAN

; ====================>
; Fill in image array with ok values
  i1(ok)=FLOAT(copy1(ok))
  i2(ok)=FLOAT(copy2(ok))

; ====================>
; Smooth images to minimize noise, ignores nan's
  smooth_i1 = smooth(i1,3,/NAN)
  smooth_i2 = smooth(i2,3,/NAN)
; ===================>
; Now get rid of nan's
  ii1=FLOAT(copy1)
  ii2=FLOAT(copy2)
  ii1(*,*) = 0
  ii2(*,*) = 0
  ii1(ok) = smooth_i1(ok)
  ii2(ok) = smooth_i2(ok)
 stop
; ====================>
; Create an array to hold all good pixel values for the avhrr and czcs image
  XY = DBLARR(2,N_ELEMENTS(OK))
  XY(0,*)=Ii1[OK]
  XY(1,*)=Ii2[OK]

;  concat = LONG(FIX(XY(0,*)))*1000 + LONG(FIX(XY(1,*)))
 ; concat = REFORM(concat)
; ====================>
; Run IDL program kmeans.pro

; clustest,XY,CLUSTER,NUMBER=NUMBER,ITER=ITER,/NOPRINT
  clustest,XY,CLUSTER,NUMBER=NUMBER,/NOPRINT


; ====================>
; Make copy of image1, and set all pixels to zero
  COPY = i1
  COPY(*) = 0B

; ====================>
; Now replace pixels in copy with the cluster value +1
  COPY[OK] = BYTE(CLUSTER+1)

; ====================>
; Display resulting image showing subareas128,12

  TV,BYTSCL(CONGRID(COPY,512,512)),/ORDER

  TIMER,/STOP
  fname = parse_it(czcs)
  output = 'd:\aaa\' + fname.name + '.'  + STRTRIM(STRING(NUMBER),2) + '-' + STRTRIM(STRING(ITER),2)

  print, output
  OPENW,LUN,OUTPUT,/get_lun
  WRITEU,LUN,COPY
  CLOSE,LUN
  FREE_LUN,LUN


STOP
END

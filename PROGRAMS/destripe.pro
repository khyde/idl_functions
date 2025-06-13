; $ID:	DESTRIPE.PRO,	2020-07-08-15,	USER-KJWH	$
;Viewing contents of file '/net/www/deutsch/idl/idllib/ghrs/pro/destripe.pro'

pro destripe,angle1,angle2,bckgr,new_bckgr
;+
;  NAME: DESTRIPE
;  CATEGORY: IRAS Image Processing routine:  removes periodic stripes
;  CALLING SEQUENCE:
; destripe,angle1,angle2,bckgr,new_bckgr
;  PARAMETERS:
; ANGLE1, ANGLE2: (REQ) (I) (R) [0]
;		Purp: Defines minimum and maximum angle at which stripes
;		      are observed.
; BCKGR: (REQ) (I) (R) (2 .. 2-D array)
;		Purp: Contains data to be destriped.
; NEW_BCKGR: (REQ) (O) (R) (2.. 2-D array)
;		Purp: will contain destriped data upon return
;
;  INTERACTIVE INPUT: none.
;  SUBROUTINES CALLED: none
;  COMMON BLOCKS: none
;
;  SIDE EFFECTS:  Because of FFT, a lot of memory is required. If not
;	   	  enough memory available, will bomb. Ask your systems
;		  manager to increase your page fault quotas.
;
;  RESTRICTION: Should work for IDL version 1 and version 2
;
;  PROCEDURE:  DESTRIPE transforms input image to Fourier domain then
;	       sets wedge betwenn "angle1" and "angle2" (in degrees)
;	       to zero and transforms array back to spatial domain.
;
;  CALLED BY "IRAS_DESTRIPE"
;
;  MODIFICATION HISTORY:  Gitta Domik and Jose Ruiz: July 1990
;-
; make angle1 < angle1
if angle1 gt angle2 then begin
  h=angle1
  angle1=angle2
  angle2=h
 endif
angle1=angle1/!radeg
tanangle1=tan(angle1)
angle2=angle2/!radeg
tanangle2=tan(angle2)
s=size(bckgr)
;
; Step 1: Calculate fft of image
;
print,'--Step 1: Calculate fft of image...'
;
; Expand image first to 512 x 512 (calculates faster fft)
;
new_bckgr=fltarr(512,512)
new_bckgr(0,0)=bckgr
bckgr=0
fbckgr=fft(new_bckgr,-1)
new_bckgr=0
fbckgr=shift(fbckgr,256,256); shift (0,0) to center
;
; Step 2: Prepare mask
;
print,'--Step 2: Prepare mask...'
;
mask=bytarr(512,512)
mask=mask+1b
for u=0,255 do begin
  for v=nint(float(u)*tanangle1),nint(float(u)*tanangle2) do begin
     mask((256+u)<511,(256+v)<511)=0b
     mask((255-u)>0,(256-v)>0)=0b
  endfor
endfor
;
; Step 3: Multiply with mask and take inverse fft
;
print,'--Step 3: Multiply with mask and take inverse fft...'
fbckgr=fbckgr*mask
mask=0
;
fbckgr=shift(fbckgr,-256,-256); shift fourier image back
new_bckgr=float(fft(fbckgr,1))
fbckgr=0
new_bckgr=new_bckgr(0:s[1]-1,0:s(2)-1)
return
end


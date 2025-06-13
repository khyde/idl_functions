pro gridimg
image=bytarr(800,600)

image(*,*) = 255b

FOR I = 0,799, 100 DO BEGIN
FOR J = 0,599, 100 DO BEGIN

  IMAGE(I:I+1,*) = 0
  IMAGE(*,J:J+1) = 0
ENDFOR
ENDFOR
IMAGE(798:799,*)=0
IMAGE(*,598:599)=0

FOR I = 0,799, 10 DO BEGIN
FOR J = 0,599, 10 DO BEGIN

  IMAGE(I,*) = 0
  IMAGE(*,J) = 0
ENDFOR
ENDFOR

SLIDEW,IMAGE
XYOUTS2,.51,.51,'800 x 600 Pixels',align=[.5,.5],/NORMAL,color=0, CHARSIZE=4,charthick=2
LOADCT,0
TVLCT,R,G,B,/GET
WRITE_GIF,'C:\IDL\JAY\GRIDIMG.GIF',TVRD(),R,G,B


END
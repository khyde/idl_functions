PRO PAL_10, R,G,B
R=BYTARR(256) & G=BYTARR(256) & B=BYTARR(256)
R(  0)=  0 & G(  0)=  0 & B(  0)=  0 &
R(  1)=128 & G(  1)=  0 & B(  1)=128 &
R(  2)=128 & G(  2)=  0 & B(  2)=255 &
R(  3)=  0 & G(  3)=128 & B(  3)=255 &
R(  4)=  0 & G(  4)=255 & B(  4)=255 &
R(  5)=  0 & G(  5)=255 & B(  5)=  0 &
R(  6)=128 & G(  6)=255 & B(  6)=  0 &
R(  7)=255 & G(  7)=255 & B(  7)=  0 &
R(  8)=255 & G(  8)=128 & B(  8)=  0 &
R(  9)=255 & G(  9)=  0 & B(  9)=  0 &
R( 10)=255 & G( 10)=128 & B( 10)=255 &
R(11:*) = 255
G(11:*) = 255
B(11:*) = 255
TVLCT,R,G,B  
END 

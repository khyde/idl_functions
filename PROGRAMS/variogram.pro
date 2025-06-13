; THIS PROGRAM IS STILL IN DRAFT STATE

PRO VARIOGRAM,V, LO,HI

; FROM JIM YODER MATLAB

; Program calculates the semi-variogram for a vector ('v').
; Only data greater than 'lo' and less than 'hi' are included in the
; calculations.
; After creating a new temporary vector ('w', the program determines
; the length ('len') of the new vector.
; Then, the program calculates statistics for lags up to half
; of the length ('lenhaf').
; After the calculations, the program destroys the temporary vector and
; most other variables used in the calculations.  However, the variable
; 'lenhaf' is not destroyed, since it can be used to correctly plot
; the semi-variogram.
; Note that the original vector ('v') is not affected by this program.
;
; NOTE:  THIS PROGRAM ASSUMES THAT THE MAXIMUM LENGTH OF THE
; VARIOGRAM IS 250 LAGS. IF MORE LAGS ARE REQUIRED, THEN CHANGE
; THE LIMITS OF THE FIRST 'FOR' LOOP SO THAT OLD VALUES FOR 'SEMI'
; AND 'COUNT' ARE ALWAYS ZEROED OUT.
;
;
w=v;
len=N_ELEMENTS(w);
lenhaf=FIX(len/2);
;
;Set up variables
;

  N = N_ELEMENTS(W)
  semi= FLTARR(N)
  count = FLTARR(N)
        ;
;       Calculating
;
; 'main' is the lag distance.
;
   FOR MAIN=1,lenhaf DO BEGIN
;
; 'nend' is the number of calc per row, which changes for each lag.
;
     nend=len-main;
     FOR k=0L, nend-1L DO BEGIN
       IF(w(k)>lo AND w(k)<hi AND w(k+main)>lo AND w(k+main)<hi) THEN BEGIN
         count(main)=count(main)+1;
         semi(main)=semi(main) +(w(k)-w(k+main))^2;
       ENDIF

;
     ENDFOR; FOR k=1, nend DO BEGIN
;
     ENDFOR
; end of 'main' loop.
;
       IF(count(main)>0) THEN BEGIN
        semi(main)=semi(main)/(2.*count(main));
;
; end of 'if' statement
;
        ENDIF

 ;       count=count';
         STOP

END ; END OF PROGRAM
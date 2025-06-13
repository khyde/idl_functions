; $ID:	MODIFIED_COMMUNITY.PRO,	2020-07-08-15,	USER-KJWH	$
PRO modified_community,B,x,y,w,VERBOSE=verbose

;====define a function to remove negative values in the output phytoplankton community=======

B=regress2(x,y,w,RELATIVE_WEIGHT=relative_weight,VERBOSE=verbose)


goto,end_1


        SX        = SIZE( x )
         SY        = SIZE(y )
         nterm     = SX[1]
         npts      = SY[1]

         if (N_ELEMENTS(w) NE SY[1]) OR $
            (SX[0] NE 2) OR (SY[1] NE SX(2)) THEN $
              message, 'Incompatible arrays.'

         WW   = REPLICATE(1.,nterm) # w
         curv = ( x*WW ) # TRANSPOSE( x )
         beta = x # (y*w)

         if nterm eq 1 then begin
              sigma  = 1./sqrt(curv)
              X_coeff= beta/curv
         endif else begin
              err     = INVERT( curv, status )

              if (status eq 1) then begin
                   print,'det( Curvature matrix )=0 .. Using REGRESS'
             ;print,err
print,'y: ', y
             ; stop
                   X1   = x
                   linechk   = x(0,0) - x(0,fix( npts*randomu(seed) ))
                   if linechk eq 0 then begin
                        print,'Cannot determine sigma for CONSTANT'
                        X1  = X1(1:nterm-1,*)
                   endif
              endif
 
         endelse
         









IF B[0] lt 0.0 THEN BEGIN
	B=fltarr(n_elements(y))-1.0	
	goto,end_process
ENDIF

end_1:
negative_value_class=where(B lt 0.0)
label_number=indgen(n_elements(y))
x_new=fltarr(n_elements(y))

WHILE negative_value_class[0] ne -1 DO BEGIN

	;IF (B(9) le 0.0 or B(10) le 0.0) and ((B(9)+B(10)) gt 0.0)  THEN BEGIN
	IF (B(9)+B(10)) le 0.0 THEN BEGIN
		;B(9)=B(9)+B(10)
		B(10)=0.0
		x(10,*)=0.0
	ENDIF
				
	zero_value_class=where(B le 0.0)
	positive_class=where(B gt 0.0)
	B(zero_value_class)=0.0
	
	IF n_elements(positive_class) lt 1.0 THEN BEGIN
		goto,end_process
	ENDIF ELSE BEGIN
		x_new=x(positive_class,*)
		good_label=label_number(positive_class)
	
		B_new=regress2(x_new,y,w,RELATIVE_WEIGHT=relative_weight)
		For k=0,n_elements(positive_class)-1 DO BEGIN
			B(positive_class(k))=B_new(k)
		ENDFOR

		negative_value_class=where(B lt 0.0)
	ENDELSE
ENDWHILE
goto,end_process

end_process:

END

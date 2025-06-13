pro nir_arnone_demo  ; March 28,2003
; patterned after seadas get_rhown_nir

chl_A = INTERVAL([-10,6],BASE=2,0.01)
pal36,r,g,b
!Y.MARGIN=[6,5]
!x.thick=2
!y.thick=2

  lambda = [670,765,865]

; =====>Absorption and backscattering of Water at 670,750,865
 	aw =[0.4458,2.9532,4.8683];/     ! Unit (1/m)
 	bbw= [4.26E-4, 2.38E-4, 1.49E-4] ;/! Unit (1/m)

; =====> Phytoplankton absorption at 670nm
 	aPh670 = 0.017388*CHL_A^0.813791 ; FROM BRICAUD ET AL TABLE

; =====> Particulate absorption at 670nm
 	ap670 = 0.01989*CHL_A^0.817742 ; FROM BRICAUD ET AL TABLE

; IF( Rrs555 GT 0.0 AND Rrs670 GT 0.0 ) THEN BEGIN
;   adg670 = 0.15 - 0.19*(Rrs555 - Rrs670)/Rrs555
; ENDIF

	PSPRINT,/half,/COLOR
	!P.MULTI=0
 	PLOT, CHL_A,ap670,xtitle=UNITS('CHLOR_A',/NAME,/UNIT),YTITLE='a670'+UNITS('ABS'),xrange=[0,70],/xstyle,/nodata


 OPLOT, CHL_A,APH670,COLOR=21,thick=3
 OPLOT, CHL_A,AP670,COLOR=26,thick=3
 OPLOT, CHL_A,REPLICATE(0.4458,N_ELEMENTS(CHL_A)), COLOR=8

 XYOUTS, 33,0.1,'Phytoplankton (Bricaud et al. 1998)',/data,color=21,charsize=1
 XYOUTS, 33,0.15,'Particulate (Bricaud et al. 1998)',/data,color=26,charsize=1
 XYOUTS, 33,0.15,'Water',/data,color=26,charsize=1





CAPTION,"J.O'R"
PSPRINT




stop
end
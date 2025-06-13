; $ID:	ROBUST_REG_DEMO.PRO,	2014-12-18	$

  PRO ROBUST_REG_DEMO
;+
; NAME:
;       ROBUST_REG_DEMO
;
; PURPOSE:
;
;
; CATEGORY:
;
;
; CALLING SEQUENCE:
;       Result = ROBUST_REG_DEMO(a)
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, Sept 30, 2003
;-
 ROUTINE_NAME='ROBUST_REG_DEMO'
 N=100
 PAL_36
 XARRAY=RANDOMU(SEED,N)
 YARRAY= 2* XARRAY+RANDOMN(SEED,N)
 GOOD=ROBUST_REG(xarray,yarray,SHOW=0.05	,RSQ= 0.8,rejects=rejects)
 print, rejects
 oplot,xarray(rejects),yarray(rejects),color=21,PSYM=1
 oplot,xarray(GOOD),yarray(GOOD),color=13,PSYM=1


STOP
 GOOD=ROBUST_REG(xarray,yarray,SHOW=0.05	 ,rejects=rejects,TRIM=3)
 print, rejects
 oplot,xarray(rejects),yarray(rejects),color=21,PSYM=1
 oplot,xarray(GOOD),yarray(GOOD),color=13,PSYM=1
STOP

GOOD=ROBUST_REG(xarray,yarray,SHOW=0.05	 ,rejects=rejects,TRIM=10,/PERCENT)
 print, rejects
 oplot,xarray(rejects),yarray(rejects),color=21,PSYM=1
 oplot,xarray(GOOD),yarray(GOOD),color=13,PSYM=1
STOP

GOOD=ROBUST_REG(xarray,yarray,SHOW=0.05	 ,rejects=rejects,RSQ=0.8,MAX_TRIM= 2 )
 print, rejects
 oplot,xarray(rejects),yarray(rejects),color=21,PSYM=1
 oplot,xarray(GOOD),yarray(GOOD),color=13,PSYM=1
STOP

END; OF PROGRAM

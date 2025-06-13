; $ID:	GCHLRAD_DEMO.PRO,	2020-06-30-17,	USER-KJWH	$
;+
;	This Program Demonstrates Characteristics of the GCHLRAD Model (Gordan 88 Semi-Analytic Model)
; SYNTAX:
;			GCHLRAD_DEMO
; OUTPUT:
;		DISPLAY, PNG, PS
; ARGUMENTS:;
; KEYWORDS:
;		PNG:	Write a PNG graphics file
;		PS		Write a Postscript File
;		DIR_OUT: Directory for any output files
; EXAMPLE:
; CATEGORY:
;		SeaWiFS
; NOTES:
; VERSION:
;		April 10, 2001
; HISTORY:
;	 	Feb 19, 1997 	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO GCHLRAD_DEMO,PNG=PNG, PS=PS, DIR_OUT=dir_out
  ROUTINE_NAME='GCHLRAD_DEMO'
  IF N_ELEMENTS(DIR_OUT) NE 1 THEN DIR_OUT ='D:\IDL\PROGRAMS\'

  CHL_LABEL= 'Chl '+UNITS('CHLM3')

  chl = [0.01,0.05, 0.1, 0.2, 0.5, 1.0, 2, 10,32, 64]
  N_CHL=N_ELEMENTS(CHL)
  lams=  [412.,    443.,    490.,    510.,    555.,    670.,    765.,    865.]  ; seawifs
  MINX=375
  MAXX=890
  XTICKV = [MINX,LAMS,maxx]
  XTICKNAME=NUM2STR(XTICKV,TRIM=2)

  XTICKNAME[0]=' '
  XTICKNAME(9)=' '
  XTICKNAME(3) = XTICKNAME(3)+' '
  XTICKNAME(4) = ' '+XTICKNAME(4)
  CHL_ = STRTRIM(STRING(CHL,FORMAT='(F7.3)'),2)
  CHL_=NUM2STR(CHL_,TRIM=2)

; ====================> Load in palette (rainbow)
  PAL_36

; **************************************************************
; ******************* Full Spectrum Plot ***********************
; **************************************************************
  IF KEYWORD_SET(PS) THEN 	PSPRINT,filename=outname+'_a.ps',/COLOR,/FULL
 	!p.multi=[0,1,2]
  !P.THICK=3

  TITLE=	'Simulated SeaWiFS Radiance, Gordon Semi-Analytical Model'
	SUBTITLES=['Kw(Smith & Baker)','Kw(POPE)']
  YTICKV=[0.01,0.1,1.0,10.0]
  YTICKNAME=NUM2STR(YTICKV,TRIM=2)
  YTICKS=N_ELEMENTS(YTICKV)-1

  FOR nth = 0, 1 DO BEGIN
    IF nth EQ 0 THEN lwn = gchlrad(chl,/SMITH)
    IF nth EQ 1 THEN lwn = gchlrad(chl)
   PLOT,LAMS , /NODATA,YRANGE=[.004,14],XRANGE=[MINX,maxx],$
  	XSTYLE=1,YSTYLE=1 ,/YLOG ,/xlog,BACKGROUND=35,$
    TITLE=TITLE,XGRIDSTYLE=1,YGRIDSTYLE=1,XTICKLEN=1,YTICKLEN=1,xticks=8,$
    YTITLE='Lwn', XTITLE='Wavelength (nm)',xtickv=XTICKV,$
    YTICKV=YTICKV,YTICKS=YTICKS,YTICKNAME=YTICKNAME,$
     XTICKNAME=XTICKNAME

    XYOUTS,410,0.008,/DATA,chl_label ,ALIGN=.3 ,CHARSIZE=1.3
    XYOUTS,560,1.3,/DATA,SUBTITLES(nth),CHARSIZE=1.5

    FOR _N = 0, N_CHL -1 DO BEGIN
      OPLOT,LAMS,lwn(*,_n),COLOR=255, THICK=1*!p.thick
      OPLOT,LAMS,lwn(*,_n),COLOR= 2+ _N*2.5, THICK=2*!P.THICK
      XYOUTS,410,LWN(0,_N),/DATA,CHL_(_N),ALIGN=1,COLOR= 2+ _N*2.5
    ENDFOR
  ENDFOR
  XYOUTS,.83,.02,/NORMAL,"J.O'Reilly, NOAA" ,CHARSIZE=.5

  IF KEYWORD_SET(PNG) THEN BEGIN
   PAL_36,R,G,B
   WRITE_PNG,DIR_OUT+ROUTINE_NAME+'_a.PNG',TVRD(),R,G,B
  ENDIF
  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP


; ******************************************
; ********* BLOWUP OF 412-555 Range ********
; ******************************************
	IF KEYWORD_SET(PS) THEN 	PSPRINT,filename=outname+'_b.ps',/COLOR,/FULL
  !p.multi=[0,1,2]
  TITLE=	'Simulated SeaWiFS Radiance, Gordon Semi-Analytical Model'
	SUBTITLES=['Kw(Smith & Baker)','Kw(POPE)']
  !P.THICK=3
  lwn = gchlrad(chl )
  lams=  [412.,    443.,    490.,    510.,    555.,    670.,    765.,    865.]  ; seawifs
  lams= LAMS(0:4)
  PRINT,LAMS; seawifs
  MINX=395
  MAXX=572
  XTICKV = [MINX,LAMS,MAXX ]
  XTICKNAME=STRTRIM(STRING(XTICKV),2)
  XTICKNAME[0]=' '
  XTICKNAME(6)=' '

  FOR nth = 0, 1 DO BEGIN
    IF nth EQ 0 THEN lwn = gchlrad(chl,/SMITH)
    IF nth EQ 1 THEN lwn = gchlrad(chl)

    PLOT,LAMS ,lwn(0:4,0), /NODATA,XRANGE=[MINX,MAXX],YRANGE=[.004,14],$
       XSTYLE=1,YSTYLE=1 ,/YLOG,background=35,$
       TITLE=TITLE,$
       XGRIDSTYLE=1,YGRIDSTYLE=1,XTICKLEN=1,YTICKLEN=1,xticks=5,$
       YTITLE='Lwn', XTITLE='Band'  ,$
       YTICKV=YTICKV,YTICKS=YTICKS,YTICKNAME=YTICKNAME,$
     		XTICKNAME=XTICKNAME

      XYOUTS,410,0.008,/DATA,chl_label ,ALIGN=.3 ,CHARSIZE=1.3
      XYOUTS,492, 3,/DATA,SUBTITLES(nth),CHARSIZE=1.5
    FOR _N = 0, N_CHL -1 DO BEGIN
      XYOUTS,410,LWN(0,_N),/DATA,CHL_(_N),ALIGN=1,COLOR= 2+ _N*2.5
      OPLOT,LAMS,lwn(0:4,_n),COLOR= 2+ _N*2.5, THICK=2
 ;    PRINT, LWN(2,_N)/LWN(4,_N)
    ENDFOR

ENDFOR

  XYOUTS,.83,.02,/NORMAL,"J.O'Reilly, NOAA" ,CHARSIZE=.5
  IF KEYWORD_SET(PNG) THEN BEGIN
   PAL_36,R,G,B
   WRITE_PNG,DIR_OUT+ROUTINE_NAME+'_b.PNG',TVRD(),R,G,B
  ENDIF
  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP



; ******************************************
; ********* Band Ratios (to 555)    ********
; ******************************************
	IF KEYWORD_SET(PS) THEN 	PSPRINT,filename=outname+'_c.ps',/COLOR,/FULL
  !p.multi=[0,1,2]
  TITLE=	'Simulated SeaWiFS Radiance, Gordon Semi-Analytical Model'
	SUBTITLES=['Kw(Smith & Baker)','Kw(POPE)']
  !P.THICK=3
  lwn = gchlrad(chl )
  lams=  [412,    443,    490,    510,    555,    670,    765,    865]  ; seawifs
  lams= LAMS(0:4)
  PRINT,LAMS; seawifs
  MINX=395
  MAXX=572
  XTICKV = [MINX,LAMS,MAXX ]
  XTICKNAME=STRTRIM(STRING(XTICKV),2)
  XTICKNAME[0]=' '
  XTICKNAME(6)=' '

  FOR nth = 0, 1 DO BEGIN
    IF nth EQ 0 THEN lwn = gchlrad(chl,/SMITH)
    IF nth EQ 1 THEN lwn = gchlrad(chl)

    PLOT,[555,555],[.1,.2]  , /NODATA,XRANGE=[MINX,MAXX],YRANGE=[.2,60],$
       XSTYLE=1,YSTYLE=1 ,/YLOG,background=35,$
       TITLE=TITLE,$
       XGRIDSTYLE=1,YGRIDSTYLE=1,XTICKLEN=1,YTICKLEN=1,xticks=5,$
       YTITLE='Lwn Ratio', XTITLE='Band',$
       xtickv=XTICKV ,xtickname  = xtickname

      XYOUTS,410,0.3,/DATA,chl_label ,ALIGN=.3 ,CHARSIZE=1.3
      XYOUTS,492, 23,/DATA,SUBTITLES(nth),CHARSIZE=1.5
    FOR _N = 0, N_CHL -1 DO BEGIN

      XYOUTS,410,LWN(0,_N)/LWN(4,_N),/DATA,CHL_(_N),ALIGN=1,COLOR= 2+ _N*2.5

      OPLOT,LAMS,lwn(0:4,_n)/lwn(4,_n),COLOR= 2+ _N*2.5, THICK=2
 ;    PRINT, LWN(2,_N)/LWN(4,_N)
    ENDFOR
ENDFOR
  XYOUTS,.83,.02,/NORMAL,"J.O'Reilly, NOAA" ,CHARSIZE=.5
  IF KEYWORD_SET(PNG) THEN BEGIN
   PAL_36,R,G,B
   WRITE_PNG,DIR_OUT+ROUTINE_NAME+'_c.PNG',TVRD(),R,G,B
  ENDIF
	  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP


; ******************************************************************
; ********* Band Ratios 412/555, 443/555, 490/555, 510/555  ********
; ******************************************************************
	IF KEYWORD_SET(PS) THEN 	PSPRINT,filename=outname+'_d.ps',/COLOR,/FULL
  !p.multi=[0,1,2]
  TITLE=	'Simulated SeaWiFS Radiance, Gordon Semi-Analytical Model'
	SUBTITLES=['Kw(Smith & Baker)','Kw(POPE)']
  !P.THICK=3
   chl = INTERVAL([-9.,6.1],.5,BASE=2)

  lams=  [412,    443,    490,    510,    555,    670,    765,    865]  ; seawifs
  lams= LAMS(0:4)
  PRINT,LAMS; seawifs
  XTICKV=[.3,.4,.5,.6,.7,.8,.9,1,2,3,4,5,6,7,8,9,10,20,30,40,50]
  XTICKNAME=NUM2STR(XTICKV)

  MINX=395
  MAXX=572
  FOR nth = 0, 1 DO BEGIN
    IF nth EQ 0 THEN lwn = gchlrad(chl,/SMITH)
    IF nth EQ 1 THEN lwn = gchlrad(chl)
		 PLOT,LWN(1,*)/LWN(4,*),CHL,/XLOG,/YLOG,XSTYLE=1,YSTYLE=1,background=35,$/NODATA ,$
       TITLE=TITLE,XRANGE=[0.3,50],YRANGE=[0.01,100],$
       XGRIDSTYLE=1,YGRIDSTYLE=1,XTICKLEN=1,YTICKLEN=1,$
       XTICKV=xtickv,xtickname=xtickname,$
       xticks=20,$
       XTITLE='Lwn Ratio', YTITLE=CHL_LABEL

       OPLOT,LWN(0,*)/LWN(4,*),CHL, COLOR = 4,  THICK=5
       OPLOT,LWN(1,*)/LWN(4,*),CHL, COLOR = 10, THICK=5
       OPLOT,LWN(2,*)/LWN(4,*),CHL, COLOR = 16, THICK=5
       OPLOT,LWN(3,*)/LWN(4,*),CHL, COLOR = 21 ,THICK=5

       XYOUTS,4.1, 23,/DATA,SUBTITLES(nth),CHARSIZE=1.5
       XYOUTS,MAX(LWN(0,*)/LWN(4,*)),0.05,/DATA,'412/555',ALIGN= 1.15,COLOR = 4
       XYOUTS,MAX(LWN(1,*)/LWN(4,*)),0.012,/DATA,'443/555',ALIGN= 1.15,COLOR = 10
       XYOUTS,MAX(LWN(2,*)/LWN(4,*)),0.012,/DATA,'490/555',ALIGN= 1.15,COLOR = 16
       XYOUTS,MAX(LWN(3,*)/LWN(4,*)),0.012,/DATA,'510/555',ALIGN= 1.15,COLOR = 21

	ENDFOR
  XYOUTS,.83,.02,/NORMAL,"J.O'Reilly, NOAA" ,CHARSIZE=.5
  IF KEYWORD_SET(PNG) THEN BEGIN
   PAL_36,R,G,B
   WRITE_PNG,DIR_OUT+ROUTINE_NAME+'_d.PNG',TVRD(),R,G,B
  ENDIF
	  IF KEYWORD_SET(PS) THEN PSPRINT ELSE STOP



stop

; =================>

  PLOTRVSCHL:

!P.MULTI=0
 PLOT,LWN(1,*)/LWN(4,*),CHL,/XLOG,/YLOG,/NODATA ,$
       TITLE='Simulated SeaWiFS Radiance, Gordon Semi-Analytical Model, Kw(POPE)',$
       xtitle='Lwn Ratio',ytitle='Chl a (!8u!Xg/l)' ,$
       XTICKLEN=1,YTICKLEN=1,XGRIDSTYLE=1,YGRIDSTYLE=1
 OPLOT,LWN(1,*)/LWN(4,*),CHL, COLOR = 4,  THICK=5
 OPLOT,LWN(2,*)/LWN(4,*),CHL, COLOR = 16, THICK=5
 OPLOT,LWN(3,*)/LWN(4,*),CHL, COLOR = 21 ,THICK=5

 ;XYOUTS,LWN(1,0)/LWN(4,0),CHL[0],'Lwn443/!CLwn555',color=4 ,charsize=1.25 ,align=1.1
 XYOUTS,LWN(2,0)/LWN(4,0),CHL[0],'Lwn490/!CLwn555',color=16 ,charsize=1.25,align=1.1
 ;XYOUTS,LWN(3,0)/LWN(4,0),CHL[0],'Lwn510/!CLwn555',color=21 ,charsize=1.25,align=1.1

 ;ENDFOR ; FOR MAIN LOOP
  XYOUTS,.83,.02,/NORMAL,"J.O'Reilly, NOAA" ,CHARSIZE=.5

  IF KEYWORD_SET(PNG) THEN BEGIN
   TVLCT,R,G,B,/GET
   WRITE_PNG,Dir_work+'gchlrad_c.PNG',TVRD(),r,g,b
  ENDIF
END; #####################  End of Routine ################################

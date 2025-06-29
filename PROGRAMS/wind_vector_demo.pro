
PRO WIND_VECTOR_DEMO

ROUTINE_NAME='WIND_VECTOR_DEMO'
PSFILE = ROUTINE_NAME+'.PS'
PSPRINT,FILENAME=PSFILE,/COLOR,/FULL,/TIMES
!P.MULTI=[0,1,2]


; EXAMPLE 1
R = FINDGEN(360)*2
A = FINDGEN(360)
POLREC, R, A, X, Y, /degrees		; Convert radius (in degrees) and angle into X & Y coordinates
VELX = X
VELY = Y

POSX = FINDGEN(360)							; X position on plot
POSY = REPLICATE(0,360)					; Y position on plot

PLOT,[0,400],[-50,50],YTITLE='',YRANGE=[-50,50],/XSTYLE,/YSTYLE,YMARGIN=YMARGIN,XMARGIN=XMARGIN,CHARSIZE=1.25,/NODATA
	;XTICKS=AX.TICKS,XTICKNAME=AX.TICKNAME,XTICKV=AX.TICKV,XTICK_GET=XTICK_GET,
PARTVELVEC,VELX,VELY,POSX,POSY,/OVER;,LENGTH=1000;,VECCOLORS=WC


; EXAMPLE 2
DIR = FINDGEN(36)*10
SPEED = FINDGEN(36)+1

POLREC, SPEED, DIR, X, Y, /degrees

stop


VELX = X
VELY = Y

DATE = CREATE_DATE(19990214,19990321)			; get a list of dates to make up the X axis position
DDATE = DATE_2JD([19990210,19990331])
POSX = DATE_2JD(DATE)
AX = DATE_AXIS(DDATE,/DAY)
POSY = REPLICATE(0,N_ELEMENTS(POSX))

; MAKE COLOR ARRAY
WC = LONARR(N_ELEMENTS(SPEED))
OKC = WHERE(DIR GE 315 OR DIR LT 45,COUNT)	& IF COUNT GE 1 THEN WC(OKC) = 4
OKC = WHERE(DIR GE 45 AND DIR LT 135,COUNT)	& IF COUNT GE 1 THEN WC(OKC) = 12
OKC = WHERE(DIR GE 135 AND DIR LT 225,COUNT)	& IF COUNT GE 1 THEN WC(OKC) = 18
OKC = WHERE(DIR GE 225 AND DIR LE 315,COUNT)	& IF COUNT GE 1 THEN WC(OKC) = 22

PLOT,AX.JD,[-2,2],YTITLE='',YRANGE=[-2,2],/XSTYLE,/YSTYLE,YMARGIN=YMARGIN,XMARGIN=XMARGIN,$
	XTICKS=AX.TICKS,XTICKNAME=AX.TICKNAME,XTICKV=AX.TICKV,XTICK_GET=XTICK_GET,CHARSIZE=0.7,/NODATA
OPLOT, AX.JD,[0,0],COLOR=0,THICK=2
PARTVELVEC,VELX,VELY,POSX,POSY,/OVER,VECCOLORS=WC


PSPRINT
END

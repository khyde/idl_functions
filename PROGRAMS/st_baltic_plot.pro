; $ID:	ST_BALTIC_PLOT.PRO,	2020-07-08-15,	USER-KJWH	$
pro ST_BALTIC_PLOT

 SETCOLOR,255
 PAL_36,R,G,B
  dir_work='D:\SEATRUTH\baltic\'

  FILE = ['Biomchla.dbf']
  FILE = DIR_WORK+ FILE

  DB = READ_DB(FILE)


; ===================>
; Sort stations
  DB.STATION = STRTRIM(DB.STATION,2)
  DB.OBSDEPTH = STRTRIM(DB.OBSDEPTH,2)


; ===================>
; Eliminate SL GG
  ok = where(STRPOS(db.station,'SL') EQ -1)
  DB=DB[OK]

  s=SORT(DB.STATION)
  DB=DB(S)


; ===================>
; DATE TIME STRUCTURE
  dt=dt_date2dt(db.date_s)

; ====================>
; Get uniq stations
  U=UNIQ(DB.STATION)

  GOTO, BYJDY

 ; SET_PMULTI,N_ELEMENTS(U)
  SET_PMULTI,12



; **************************************************
  FOR NTH = 0,N_ELEMENTS(U)-1L DO BEGIN
    STATION = DB(U[NTH]).STATION
    OK = WHERE(DB.STATION EQ STATION AND STRPOS(DB.OBSDEPTH,'0') EQ 0)
    D=DB[OK]
    _DT = DT[OK]

    xlabel=DT_AXIS(_DT.JULIAN,/MONTH,ROOM=[0,1],/ALPHA)

  IF N_ELEMENTS(D) GE 12 THEN BEGIN
    plot, [_DT.JULIAN,_DT.JULIAN],[d.CHLAMGM3,d.CHLAMGM3], xstyle=3,/ystyle,$
         xtitle=xtitle, ytitle= 'C (mg/m3)', color=0, title= STATION,$
         XTICKS=xlabel.XTICKS,XTICKV=xlabel.XTICKV,XTICKNAME=xlabel.XTICKNAME,psym=1,$
         yrange=[0.01,100],/ylog,/NODATA

    PLOTS, _DT.JULIAN,D.CHLAMGM3,PSYM=1,THICK=2


    ENDIF

  ENDFOR




BYJDY:

 SET_PMULTI,12

 XTICKV=CUMULATE(DT_DAYS_MONTH())
 XTICKNAMES=NUM2STR(XTICKV)
 XTICKS = N_ELEMENTS(XTICKNAMES)

  ALL_LAT=0.0
  ALL_LON=0.0
  all_station=' '
 ; **************************************************
  FOR NTH = 0,N_ELEMENTS(U)-1L DO BEGIN
    STATION = DB(U[NTH]).STATION


    OK = WHERE(DB.STATION EQ STATION AND STRPOS(DB.OBSDEPTH,'0') EQ 0)
     D=DB[OK]
    _DT = DT[OK]
    DOY=DAY_OF_YEAR(_DT)
    S = SORT(DOY)
    DOY=DOY(S)
    D=D(S)
    _DT=_DT(S)


    LAT  = STRING(DMS2DEG(D[0].LATITUDEN),FORMAT='(F8.3)')
    LON  = STRING(DMS2DEG(D[0].LONGITUDE),FORMAT='(F8.3)')

    DATE_RANGE= STRTRIM(STRING(MIN(_DT.YEAR)),2) +'-'+ STRTRIM(STRING(MAX(_DT.YEAR)),2)
    DEPTH = STRING(D[0].OBSDEPTH)
    TXT =''
    TXT = TXT + 'LAT: ' + LAT +'!C'
    TXT = TXT + 'LON: ' + LON +'!C'
    TXT = TXT + 'YEARS: '+DATE_RANGE + '!C'
    TXT = TXT + 'DEPTHS: '+DEPTH + '!C'


   IF N_ELEMENTS(D) GE 12 THEN BEGIN
     plot, [DOY,DOY],[d.CHLAMGM3,d.CHLAMGM3],  /xstyle,/ystyle,$
         XTITLE='DOY', ytitle= 'C (mg/m3)', color=0, title= STATION,$
         XTICKV=XTICKV,XTICKNAME=XTICKNAME,XTICKS=XTICKS,XRANGE=[0,366],yrange=[0.01,100],/ylog,/NODATA
     GRIDS,XTICKV,[0.01,.1,1,10,100],COLOR=35
     PLOTS, DOY,D.CHLAMGM3,PSYM=1,THICK=2
     NN = CEIL(N_ELEMENTS(D)/10.0)
     SM=SMOOTH(D.CHLAMGM3,NN)
     OPLOT, DOY,SM,COLOR=21, THICK=4
     XYOUTS, 121,0.10,/DATA,TXT ,CHARSIZE=0.6
      all_station=[all_station,station]
      ALL_LAT = [ALL_LAT,LAT]
      ALL_LON = [ALL_LON,LON]
  ENDIF
  ENDFOR
     all_station=all_station(1:*)
     all_lat = all_lat(1:*)
     all_lon = all_lon(1:*)

  CAPTION,"J.O'Reilly, NOAA, "

 ; SLIDEW,[2000,1000]
 ; MAP_GLOBAL_EQUIDISTANT
 ; SETCOLOR,255
 ; ERASE
 ; MAP_CONTINENTS,/COAST

stop
  SETCOLOR,255
  ERASE
  slidew,[1024,1024] & map_baltic & map_continents,/coast,/hires

  PLOTS, ALL_LON,ALL_LAT,COLOR=6,PSYM=1,SYMSIZE=2,thick=2
  XYOUTS, ALL_LON,ALL_LAT,all_station,CHARSIZE=3,COLOR=6,charthick=2
  LIST, ALL_LON
  LIST,ALL_LAT

STOP


; ***************************
  XYZ=CONVERT_COORD(ALL_LON,ALL_LAT,/DATA,/TO_DEVICE)

  XP = ROUND(XYZ[0])
  YP = ROUND(XYZ[1])

  SUMMER_REPRO_2=readall('d:\bioopt\seawifs_project\chlor_a_baseline_summer.gif',RED=R,GREEN=G,BLUE=B)
  SUMMER_REPRO_2 = SUMMER_REPRO_2(0:999,75:574)
  CUT= REBIN(SUMMER_REPRO_2(500:619, 385:454), 960,560,  /SAMPLE)

  WRITE_GIF,'d:\bioopt\seawifs_project\chlor_a_baseline_summer_B.gif',CUT,R,G,B

  SUMMER_REPRO_3=readall('d:\bioopt\seawifs_project\Chlor_a_msl12_nirs_v5_oc4v4_summer.gif',RED=R,GREEN=G,BLUE=B)
  LEGEND = SUMMER_REPRO_3(1000:*,*)
  SUMMER_REPRO_3 = SUMMER_REPRO_3(0:999,0:499)
   CUT= REBIN(SUMMER_REPRO_3(500:619, 385:454), 960,560,  /SAMPLE)
  WRITE_GIF,'d:\bioopt\seawifs_project\Chlor_a_msl12_nirs_v5_oc4v4_summer_B.gif',CUT,R,G,B

; MAKE OUTPUT GIFS



  slidew, SUMMER_REPRO_3
  map_global_equidistant


  FOR LL = 0,N_ELEMENTS(ALL_LAT)-1L DO BEGIN
    FOR around = 0,3 DO BEGIN
      ALON = ALL_LON(LL)
      ALAT = ALL_LAT(LL)
      ASTA = ALL_STATION(LL)
      sw_chl= MAP_DEG2IMAGE(SUMMER_REPRO_3,ALON,ALAT,  X=x, Y=y,AROUND=around)
      S     = stats(seadasgrey(sw_chl),/QUIET,MISSING=0.01)
      print,ASTA, AROUND, S.N,S.MIN,S.MAX,S.MED,S.MEAN
    ENDFOR
   ENDFOR



  END ; OF PROGRAM

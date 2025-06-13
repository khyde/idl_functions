; $ID:	PLATT1.PRO,	2020-07-29-14,	USER-KJWH	$
PRO PLATT1,FILE=FILE, data = DATA

; program EXTRACTS chl and phaeo from files provided by Trevor Platt
; Bedford Inst Oceanog
;   bod.bpz
;The file bod.bzp contains 162 chlorophyll profiles from the North Atlantic
;(35-46N, 62-77W) from 1978-1986.

;Of the 162 profiles, 139 were successfully fitted by our Gaussian fitting
;routine. It was previously indicated that this number was 141, but 2 of the
;profiles in the 47BIOSARGASS data set were duplicated.

;Only 53 of the 162 profiles have phaeophytin values.

;Was a different method used for records having chl but no phaeo?

;Answer:
;It was indicated in the table sent Nov 1, 1995 entitled NORTH ATLANTIC
;CHLOROPHYLL PROFILES that all the BIO profiles had phaeophytin values.
;As noted above, this is not so.
;Profiles with fewer than 25 sampling depths are from discrete-depth pump or
;bottle stations. At each depth extracted chl measurements were made. For some
;of these samples, the phaeo wasn't recorded.
;Profiles with more than 100 depths are from CTD stations. They are continuous
;fluorescence traces that have been calibrated against a few extracted
;chlorophyll samples. There are no phaeo values.
;
;--------------------------------------------------------------------------------
;Format of bod.bzp:

;Header:
;CRUISE STATION LAT LONG DAY MON YEAR TIME NPTS_IN_PROF FIT_FLAG GMT_FLAG
;FORMAT(2X,A8,2x,A5,2(2x,F8.3),2X,2(I2,1x),I4,2x,i4,2x,I4,3X,A1,3X,A3)
;TIME is local time except where GMT_FLAG = GMT.
;FIT_FLAG = * indicates that the profile was not successfully fitted by our
;Gaussian fitting routine.

;Data:
;z(m)  Chla(mg/m3)  Phaeo(mg/m3)
;FORMAT(2x,f8.1,2x,2f8.2)

;Missing value is -99.



  CLOSE,/ALL  ; Close any open units


   NFILE=' '
  IF KEYWORD_SET(FILE) EQ 0 THEN BEGIN
    READ,nfile,PROMPT='Enter Name of Input File:  '
  ENDIF ELSE BEGIN
    nfile = file
  ENDELSE
    OPENR,1,nfile

;
;***************************************************************
;CRUISE STATION LAT LONG DAY MON YEAR TIME NPTS_IN_PROF FIT_FLAG GMT_FLAG
; CREATE A STORAGE STRUCTURE FOR THE PROFILE
  TEMPLATE={CR:'',STA:'',LATITUDE:MISSINGS(0.0),LONGITUDE:MISSINGS(0.0),$
             DAY:MISSINGS(0),MONTH:MISSINGS(0),YEAR:MISSINGS(0),$
            _time:MISSINGS(0),NPTS:MISSINGS(0L),FIT_FLAG:'',GMT_FLAG:'',$
            DEPTH:MISSINGS(0.0),CHL:MISSINGS(0.0),pha:MISSINGS(0.0), $
            date:'',time:MISSINGS(0),total_pig:MISSINGS(0.0) }

; CREATE A STORAGE STRUCTURE FOR THE ENTIRE DATA SET OF PROFILES
  RECORD = TEMPLATE
  DATA = REPLICATE(TEMPLATE,20000)


  TXT = ' '
  COUNT = 0L
  DEPTH = 9. & CHL = 9. & PHA = 9.
  cruise = ' '
  station = ' '
  lat = 9.
  long = 9.
  day = 0
  mon = 0
  year = 0
  time = 0
  hour = 0
  minute = 0
  npts = 0L
  fit_flag = '   '
  gmt_flag = '   '
  HEADER = 0L
  WHILE NOT EOF[1] DO BEGIN  ; READ ENTIRE FILE
; NOTE THAT THE INPUT FILE BOD.BZP IS FORMATTED BUT RECORD LENGTH VARIES DEPENDING
; ON WHETHER FIT_FLAG IS PRESENT AND WHETHER GMT_FLAG IS PRESENT

   READF,1,Q,CRUISE,STATION, LAT, LONG, DAY, MON, YEAR, TIME, NPTS, FIT_FLAG, GMT_FLAG,$
      FORMAT='(Q,2X,A8,2x,A5,2(2x,F8.3),2X,2(I2,1x),I4,2x,i4,2x,I4,3X,A1,3X,A3)'

    HEADER = HEADER + 1L
    DATA(COUNT).cr = cruise
    DATA(COUNT).sta = station
    DATA(COUNT).latitude = lat
    DATA(COUNT).longitude = long
    DATA(COUNT).day = day
    DATA(COUNT).month = mon
    DATA(COUNT).year = year
    DATA(COUNT)._time = time
    DATA(COUNT).npts = npts
    DATA(COUNT).fit_flag = fit_flag
    DATA(COUNT).gmt_flag = gmt_flag

;    PRINT, COUNT, ' ',Q,' ',FIT_FLAG,' ',GMT_FLAG
   IF Q EQ 61 THEN BEGIN
     DATA(COUNT).fit_flag = '   '
     DATA(COUNT).gmt_flag = '   '
   ENDIF
   IF Q EQ 65 THEN BEGIN
     DATA(COUNT).gmt_flag = '   '
   ENDIF

   IF Q NE 61 AND Q NE 65 AND Q NE 71 THEN BEGIN
     PRINT, 'Potential error: ',count, 'reclen = ', q
   ENDIF
   IF DATA(COUNT).FIT_FLAG EQ ' ' THEN DATA(COUNT).FIT_FLAG = '   '
   IF DATA(COUNT).GMT_FLAG EQ ' ' THEN DATA(COUNT).GMT_FLAG = '   '

   DATA(COUNT:COUNT+NPTS-1) = DATA(COUNT)


   FOR _NPTS = 1,NPTS DO BEGIN

   READF,1,DEPTH,CHL,PHA,FORMAT='(2x,f8.1,2x,2f8.2)'
    DATA(COUNT).DEPTH = DEPTH
    DATA(COUNT).CHL = CHL
    DATA(COUNT).PHA = PHA
  ;  PRINT,DEPTH,CHL,PHA,FORMAT='(2x,f8.1,2x,2f8.2)'
    COUNT = COUNT + 1L
  ENDFOR


ENDWHILE ; WHILE ieof EQ 0 DO BEGIN

; NOW elimate empty records.

 OK = WHERE(DATA.LATITUDE GE 20. AND DATA.LATITUDE NE MISSINGS(DATA.LATITUDE))
 DATA = TEMPORARY(DATA[OK])


; Now replace any -99 with idl missing codes

  OK = WHERE(DATA.PHA LT -1,count)
  if count ge 1 then data(ok).pha = missings(data(ok).pha)
  OK = WHERE(DATA.CHL LT -1,count)
  if count ge 1 then  data(ok).chl = missings(data(ok).chl)
; make time missing if negative
  OK = WHERE(DATA._time lt 0,count)
  if count ge 1 then data(ok)._time = missings(data(ok)._time)

; MAKE MISSING TIMES 0800 IF NOT GMT (DBASE WILL ADD 4HRS LATER)
; AND 1200 IF GMT
  ok = where(data._time EQ missings(data._time) AND STRTRIM(data.gmt_flag,2) NE 'GMT',count)
  if count ge 1 then DATA[OK]._TIME = 0800
  ok = where(data._time EQ missings(data._time) AND STRTRIM(data.gmt_flag,2) EQ 'GMT',count)
  if count ge 1 then DATA[OK]._TIME = 1200


; now determine where total_pig is possible
  ok = WHERE(data.chl NE MISSINGS(data.chl) AND data.pha NE MISSINGS(data.pha) ,count)
  if count ge 1 then data(ok).total_pig = data(ok).chl + data(ok).pha


; now fill in the date tag
  NTH = N_ELEMENTS(DATA)-1
  FOR I = 0, NTH DO BEGIN
  YR  = STRMID(STRING(DATA(I).YEAR ,FORMAT='(I4)'),2,2)
  MONTH = STRTRIM(STRING(DATA(I).MONTH , FORMAT='(I2)'),2)
  DAY   = STRTRIM(STRING(DATA(I).DAY   , FORMAT='(I2)'),2)

  DATA(I).DATE = MONTH + '/' + DAY + '/' + YR

   ENDFOR

WRITE_DB,'D:\AAA\PLATT1.DBF',DATA
END ; END OF MAIN PROGRAM


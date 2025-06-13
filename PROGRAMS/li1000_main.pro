; $ID:	LI1000_MAIN.PRO,	2020-07-08-15,	USER-KJWH	$
;+
;		This Program Calculates PAR from LICOR 1000 datalogger and edits data
; SYNTAX:
;		LI1000_MAIN, Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
;	Result = LI1000_MAIN(Param1, Param2 [,/KEY1] [,/KEY2] [KEY3=KEY3] )
; OUTPUT:
; ARGUMENTS:
; 	Parm1:
; 	Parm2:
; KEYWORDS:
;	KEY1:
;	KEY2:
;	KEY3:
; EXAMPLE:
; CATEGORY:
;	DT
; NOTES:
; VERSION:
;		June 25,2001
; HISTORY:
;			June 25,2001	Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO LI1000_MAIN
  ROUTINE_NAME='LI1000_MAIN'
  ; ************

; Directories for LI100 PAR data
; comment out any line(s) (directories) you do not want to process
  DISK = 'G:\' & SUB_DIR = 'FRRF\NARBAY\'
  SETCOLOR,255
  PAL_36,R,G,B

  FOLDERS = [$
 ; 'NB20010622', $
 ; 'NB20010816' $
  ;'NB20010914' $
  ;'NB20011011', $
  ;'NB20020312', $
  'NB20020409'$
  ]


  DT_FMT = 'MDY'


  DIRS = DISK+SUB_DIR+FOLDERS+'\' ;;

  TYPE = ['M','I'] ; mean, integral


  DO_LI1000_SAVE    	=1

  DO_LI1000_EDIT    	=1
  DO_LI1000_PLOT   	=1



; ***********************************************************
; ***********************************************************
  FOR _DIR = 0L,N_ELEMENTS(DIRS)-1L DO BEGIN
    DIR=DIRS(_DIR)
    FN=PARSE_IT(DIR)
    AFOLDER = FN.SUB
    PRINT
    PRINT, 'WORKING ON FILES IN DIRECTORY: '+DIR
    CLOSE,/ALL

    TARGETS=['M','L','H','I'] ; LOGING PERIODS


;   ***************************************************
;       LI1000   F I L E S
;   *************************************************

 		FILES=DIR+'LI1000_*.TXT'
    FILES = FILELIST(FILES)
;
    FILE=FILES[0]
    FN=PARSE_IT(FILE)
    SAVEFILE=FN.DIR+FN.NAME+'.save'
    EDITFILE=FN.DIR+FN.NAME+'_edit.save'
    PSFILE=FN.DIR+FN.NAME+'_edit.ps'

    txt=READALL(FILE)
    struct=CREATE_STRUCT('DATE','','PERIOD_M','','PAR_M',0.0,'PERIOD_L','','PAR_L',0.0,'PERIOD_H','','PAR_H',0.0,'PERIOD_I','','PAR_I',0.0)

    struct=STRUCT_2MISSINGS(STRUCT)
    struct = REPLICATE(struct,N_ELEMENTS(txt))
;   ===================> Keep only records with 'M' (mean)
;    OK = WHERE(STRPOS(txt,'M') GE 0,COUNT)
;    IF COUNT EQ 0 THEN STOP
;    TXT = TXT[OK]
    TXT=STRTRIM(STRCOMPRESS(TXT),2)
    FOR NTH = 0,N_ELEMENTS(TXT)-1L DO BEGIN
      LINE = TXT[NTH]
      IF STRLEN(LINE) LT 40 THEN CONTINUE
      T    = STR_SEP(LINE,' ')
      YY   = STRMID(T[0],0,2)
      IF FIX(YY) GT 76 THEN CEN = '19' ELSE CEN = '20'
      MM   = STRMID(T[0],2,2)
      DD   = STRMID(T[0],4,2)
      HH = STRMID(T[1],0,2)
      MINUTE = STRMID(T[1],2,2)

      struct(nth).date = CEN+YY+MM+DD+HH+Minute+'00'
;     FIND THE LOGGING PERIOD:
      FOR _TYPE = 0,N_ELEMENTS(TYPE)-1 DO BEGIN
        atype = TYPE(_type)
        POS = STRPOS(line,ATYPE)
        ok = WHERE(POS GE 0,COUNT)
        IF COUNT EQ 1 THEN  LOG = ATYPE
      ENDFOR

      FOR _targets = 0,N_ELEMENTS(TARGETS)-1 DO BEGIN
      	ATARGET = TARGETS(_targets)
      	OK = WHERE(STRPOS(T,ATARGET) GE 0,COUNT)
      	IF COUNT EQ 1 THEN BEGIN
        	ITEM = T(OK[0])
        	PERIOD = STR_SEP(ITEM,ATARGET)
        	CMD = 	'STRUCT[NTH].PERIOD_'+ATARGET+' = PERIOD[0]'
        	A=EXECUTE(CMD)
        	CMD = 'STRUCT[NTH].PAR_'+ATARGET+'= T(OK[0]+1)'
        	A=EXECUTE(CMD)
      	ENDIF
      ENDFOR
    ENDFOR

;   ===================> Eliminate records with no data
    subs = LONARR(N_ELEMENTS(STRUCT))
    subs(*) = 0
    FOR nth=2,N_TAGS(STRUCT)-1,2 DO BEGIN ; SKIP DATE
      OK = WHERE(STRUCT.(nth) NE MISSINGS(struct.(nth)),COUNT)
      IF COUNT GE 1 THEN subs(ok) = SUBS[OK]+1
    ENDFOR

    OK = WHERE(SUBS GE 1,COUNT)
    IF COUNT GE 1 THEN STRUCT=STRUCT[OK] ELSE STOP





;  *********************************************
;  ********* DO_LI1000_SAVE  *******************
;  *********************************************
    IF DO_LI1000_SAVE EQ 1 THEN BEGIN
      PRINT, 'SAVING LI1000 DATA'
      SAVEFILE=FN.DIR+FN.NAME+'.save'
      SAVE,FILENAME=savefile, Struct
      SAVE_2CSV,savefile
    ENDIF


;  *********************************************
;  ********* DO_LI1000_EDIT  *******************
;  *********************************************
    IF DO_LI1000_EDIT EQ 1   THEN BEGIN
       PRINT, ' DO_LI1000_EDIT'
       S=READALL(SAVEFILE)
       IF AFOLDER EQ 'NB20020312' THEN BEGIN
         S.DATE = DT_JULIAN2DATE(1.0/24.0 + DT_DATE2JULIAN(S.DATE))
       ENDIF
       SAVE,FILENAME=EDITFILE,S
       SAVE_2CSV,EDITFILE
    ENDIF



;  *********************************************
;  ********* DO_LI1000_PLOT  *******************
;  *********************************************

    IF DO_LI1000_PLOT EQ 1 THEN BEGIN
    PRINT, 'Making PS files'
    !P.MULTI=[0,1,3]
    PSPRINT,FILENAME=psfile,/full,/color
    s=READALL(EDITFILE)
    julian = DT_DATE2JULIAN(S.DATE)
    LOCAL  = DT_LOCAL_GMT(JULIAN,/GMT2LOCAL)

    DA=DT_AXIS(LOCAL,/HOUR)
    OK = WHERE(S.PAR_M NE MISSINGS(S.PAR_M) AND S.PAR_M GT 1)

    YTITLE = 'PAR '+ UNITS('EMS')
    TITLE = 'PAR, RV Capt. Burt'

    PLOT, DA.DT[OK],S[OK].PAR_M,PSYM=1,COLOR=0,SYMSIZE=0.2,YTITLE=YTITLE,TITLE=TITLE,XTITLE='Time (Local)',$
    			XTICKS=DA.TICKS,XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,XTHICK=2,YTHICK=2,CHARSIZE=1.25,/NODATA
    OPLOT, DA.DT[OK],S[OK].PAR_M,PSYM=1,COLOR=23,SYMSIZE=0.5

    YTITLE = 'PAR Varibility per Minute (%)!C(High-Low)/Mean'


    PLOT, DA.DT[OK], 100*(S[OK].PAR_H - S[OK].PAR_L)/S(ok).PAR_M,PSYM=1,COLOR=0,SYMSIZE=0.1,YTITLE=YTITLE,TITLE=TITLE,XTITLE='Time (Local)',$,
          YRANGE=[0.1,200],/YSTYLE,/YLOG,XTICKS=DA.TICKS,XTICKV=DA.TICKV,XTICKNAME=DA.TICKNAME,XTHICK=2,YTHICK=2,CHARSIZE=1.25,/NODATA
    OPLOT, DA.DT[OK], 100*(S[OK].PAR_H - S[OK].PAR_L)/S(ok).PAR_M,PSYM=1,COLOR=23,SYMSIZE=0.5



    HISTPLOT, 100*(S[OK].PAR_H - S[OK].PAR_L)/S(ok).PAR_M,BINSIZE=2,PARAMS=[0,1,2,3,4],XRANGE=[0,200],STATS_CHARSIZE=0.8,XTITLE = 'Varibility per Minute (%)!C(High-Low)/Mean',TITLE='PAR Variability (1 minute)',$
              BAR_COLOR=21,XTHICK=2,YTHICK=2,CHARSIZE=1.25,XTICKS=20,STATS_POS = [0.6,.7],DECIMALS=2,CUM_THICK=3

    CAPTION,"J.O'Reilly (NOAA) "

	  PSPRINT





    ENDIF



ENDFOR ; FOR _DIR = 0L,N_ELEMENTS(DIRS)-1L DO BEGIN



END; #####################  End of Routine ################################

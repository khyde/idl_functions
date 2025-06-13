; $ID:	FTP_BATCH_SATFILES.PRO,	2020-06-30-17,	USER-KJWH	$
;+
; This Program
; SYNTAX:
; FTP_BATCH_SATFILES,

; HISTORY:
;   Aug 13,2002 Written by: T.Ducas and J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;   Aug 14,2002 _extra
;   Oct 3, 2002, automate getting nec seawifs from gso
;   Oct 4, 2002, jor, changed hours for auto ftp
;   Oct 21,2002, add elements to data_types,get elements.dat
;   Nov 13,2002, change inventory directory from d:\idl\data\ to d:\idl\inventory\
;   Jan 17,2003, jor, added email url component, ADDED URLs
;   Jan 30,2003 td, add auto for l3b
;   Oct 6, 2003 td, check _data_types for 'ELEMENTS'
;		Nov 23,2004 td, add DO_AGAIN for L3B_AUTO step
;
;-
; *************************************************************************

PRO FTP_BATCH_SATFILES ,DATA_TYPES=data_types, AUTO=auto,  EMAIL=email, _EXTRA=_extra,PS=ps
  ROUTINE_NAME='FTP_BATCH_SATFILES'
   computer = GET_COMPUTER()
   ;IF N_ELEMENTS(DATA_TYPES) EQ 0 THEN DATA_TYPES = ['L1A']   ; 'S*.all.nec.Z

   IF N_ELEMENTS(DATA_TYPES) EQ 0 THEN DATA_TYPES = ['L1A','L3B_DAY','ELEMENTS']    ;  use auto ftp for GSO_NEC
    IF N_ELEMENTS(DATA_TYPES) EQ 0 THEN DATA_TYPES = ['L3B_DAY']    ;  use auto ftp for GSO_NEC
    _DATA_TYPES=DATA_TYPES


  IF N_ELEMENTS(PS) EQ 0 THEN _PS=0 ELSE _PS=ps

  L1A_LOCAL      = 'G:\'
  L3B_DAY_LOCAL  = 'G:\'

  IF COMPUTER EQ 'SEAROBIN' THEN L1A_LOCAL ='E:\'
  IF COMPUTER EQ 'SANDEEL' THEN L3B_DAY_LOCAL ='D:\'
  GSO_NEC_LOCAL  = L1A_LOCAL + 'SEAWIFS_NEC_GSO'

  FTP_PATH=''
  AT_PERIOD='DAILY'
  AT_TIME =['5:15','11:15','18:15','23:15']
  AT_TIME = INDGEN(24)
  OVERWRITE_AT = 0
  KILL_AT    = 1
  ELEMENTS_DAYS = 8


; ************ S W I T C H E S     ******************************************
; ********* For automatically getting the GSO Seawifs nec files with AT chron
  DO_SEAWIFS_NEC_GSO_AT           = 0   ; only need to run this once to register the bat file with the AT chron
  DO_AUTO_FTP_GET_SEAWIFS_NEC_GSO = 0 ; keep this off

  DO_SEAWIFS_L3B_AT               = 0
  DO_AUTO_FTP_GET_SEAWIFS_L3B     = 1; keep this on
  DO_EMAIL                        = 0

  DO_SPECIAL_AT                   = 0
  DO_AUTO_SPECIAL                 = 0
; ****************************************************************************


; *********************************************
  IF DO_EMAIL EQ 1 THEN     EMAIL = 1  ; set email to use in ifs below
; =====> IF KEYWORD_SET(EMAIL) THEN GET THE DATA_TYPES AND URLS TO PROCESS SUBSEQUENTLY
  IF KEYWORD_SET(EMAIL) THEN BEGIN
    FTP_EMAIL_EXTRACT, DATA_TYPES=data_types, URLS=urls

    ; =====> ADD ELEMENTS TO DATA_TYPE
    OK= WHERE(_DATA_TYPES EQ 'ELEMENTS',COUNT)
    IF COUNT EQ 1 THEN BEGIN
      URLS       = [URLS,'']
      DATA_TYPES = [DATA_TYPES,'ELEMENTS']
    ENDIF
  ENDIF


; *********************************************

;  S=SORT(DATA_TYPES) & U=UNIQ(DATA_TYPES(S)) & DATA_TYPES = DATA_TYPES(U)

; *********************************************
  IF DO_SEAWIFS_NEC_GSO_AT EQ 1 THEN BEGIN ;
; *********************************************
    PRINT, 'S T E P:    DO_SEAWIFS_NEC_GSO_AT'
    AUTO=1
    AT_IDL, ROUTINE_NAME, TIME=AT_TIME, PERIOD=AT_PERIOD, AUTO=AUTO, OVERWRITE= OVERWRITE_AT ,KILL=KILL_AT
    IF KEYWORD_SET(AUTO) THEN GOTO, DONE
  ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||

; *********************************************
  IF DO_SEAWIFS_L3B_AT EQ 1 THEN BEGIN ;
; *********************************************
    PRINT, 'S T E P:    DO_SEAWIFS_L3B_AT'
    AUTO=1
 ;   TIME= STRTRIM(INDGEN(24),2) +':20'
    TIME= STRTRIM(INDGEN(24),2) +':20'
 ;   TIME = SUBSAMPLE(TIME,2)
    AT_IDL, ROUTINE_NAME, TIME= TIME, PERIOD='DAILY', AUTO=AUTO, OVERWRITE= OVERWRITE_AT ,KILL=KILL_AT
    IF KEYWORD_SET(AUTO) THEN GOTO, DONE
  ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||

; *********************************************
  IF DO_SPECIAL_AT EQ 1 THEN BEGIN ;
; *********************************************
    PRINT, 'S T E P:    DO_SPECIAL_AT'
    AUTO=1
 ;   TIME= STRTRIM(INDGEN(24),2) +':20'
    TIME= STRTRIM(INDGEN(24),2) +':20'
 ;   TIME = SUBSAMPLE(TIME,2)
    AT_IDL, ROUTINE_NAME, TIME= TIME, PERIOD='DAILY', AUTO=AUTO, OVERWRITE= OVERWRITE_AT ,KILL=KILL_AT
    IF KEYWORD_SET(AUTO) THEN GOTO, DONE
  ENDIF
; |||||||||||||||||||||||||||||||||||||||||||||||||


	IF DO_AUTO_FTP_GET_SEAWIFS_L3B THEN GOTO, GET_SEAWIFS_L3B   ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	IF DO_AUTO_SPECIAL THEN GOTO, GET_SPECIAL   ; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  IF KEYWORD_SET(AUTO) OR KEYWORD_SET(EMAIL) THEN BEGIN
; LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
  FOR _DATA_TYPE = 0,N_ELEMENTS(DATA_TYPES)-1 DO BEGIN
    A_DATA_TYPE = DATA_TYPES(_DATA_TYPE)

    IF A_DATA_TYPE EQ 'L1A' THEN BEGIN
      IF KEYWORD_SET(EMAIL) THEN FTP_PATH = URLS(_DATA_TYPE) ELSE $
      READ,FTP_PATH,PROMPT='ENTER FTP PATH FOR L1A AND ANCILLARY FILES'

      IF FTP_PATH EQ '' THEN CONTINUE
      POS=STRPOS(FTP_PATH,'eosdata')
      ftp_site=STRMID(FTP_PATH,POS,21)
      PRINT, FTP_SITE
      dir_remote = STRMID(FTP_PATH,POS+22)
      TYPES = ['L1A','NCEP','EPTOMS','TOVS']

;     LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
      FOR _TYPE = 0,N_ELEMENTS(TYPES)-1 DO BEGIN
        ATYPE = TYPES(_TYPE)
        PRINT, ATYPE
        targets=''

        IF ATYPE EQ 'L1A' THEN BEGIN
          INVENTORY     = 'd:\idl\inventory\inventory_SEAWIFS_L1A.CSV'
          DIR_LOCAL = L1A_LOCAL + 'SEAWIFS_L1A_NEW'
          HOURS = ['153','154','155','16','17','180','181','182','183']
          FOR nth=0,N_ELEMENTS(HOURS)-1 DO BEGIN
            targets =[targets ,'S???????'+HOURS[NTH]+'*.L1A_*.Z' ]
          ENDFOR
        ENDIF

        IF ATYPE EQ 'NCEP' THEN BEGIN
          INVENTORY     = 'd:\idl\inventory\inventory_ANCILLARY_NCEP.CSV'
          DIR_LOCAL = L1A_LOCAL + 'SEAWIFS_L1A_NEW'
          targets = [TARGETS,'S*NCEP.MET.Z']
        ENDIF

        IF ATYPE EQ 'TOVS' THEN BEGIN
          INVENTORY     = 'd:\idl\inventory\inventory_ANCILLARY_TOVS.CSV'
          DIR_LOCAL = L1A_LOCAL + 'SEAWIFS_L1A_NEW'
          targets = [TARGETS,'S*TOVS.OZONE.Z']
        ENDIF

        IF ATYPE EQ 'EPTOMS' THEN BEGIN
          INVENTORY     = 'd:\idl\inventory\inventory_ANCILLARY_EPTOMS.CSV'
          DIR_LOCAL = L1A_LOCAL + 'SEAWIFS_L1A_NEW'
          targets = [TARGETS,'S*EPTOMS.OZONE.Z']
        ENDIF

        TARGETS=TARGETS(1:*)
        LIST,TARGETS


        ftp_batch, ftp_site=FTP_SITE,ACCOUNT='anonymous',PASSWORD='oreilly@fish1.gso.uri.edu',$
                     n_files=10,files=targets,DIR_REMOTE=DIR_REMOTE,DIR_LOCAL=dir_local,INVENTORY=INVENTORY,$
                    _EXTRA=_extra,PS=_PS
;                    /UPDATE,_EXTRA=_extra,PS=_PS
      ENDFOR ; TYPES
    ENDIF ;IF A_DATA_TYPE EQ 'L1A' THEN BEGIN


    IF A_DATA_TYPE EQ 'ELEMENTS' THEN BEGIN
      elements=''
      IF KEYWORD_SET(EMAIL) THEN ELEMENTS = 'Y' ELSE $
      READ,elements,PROMPT='ENTER  Y TO GET ELEMENTS.DAT FILE, LEAVE BLANK TO SKIP '
      IF STRUPCASE(elements) EQ 'Y' THEN BEGIN
        ; seadas needs ELEMENTS.DAT to process L0 to L1A
        PRINT, 'GETTING elements.dat file from ftp://eosdata.gsfc.nasa.gov/.ops/dist/51130/R179020_12113.20291.3480/'
        FTP_PATH = 'samoa.gsfc.nasa.gov'
        DIR_REMOTE='pub/gps-elements/'
        DIR_LOCAL_ELEMENTS=L1A_LOCAL + 'SEAWIFS_L1A_NEW'

        fa=FILE_ALL(DIR_LOCAL_ELEMENTS + DELIMITER(/PATH)+ 'elements.dat')
        julian_elements = dt_mtime2julian(fa.mtime)
;       ===> Get present gmt as a julian
        JULIAN_NOW = DT_DATE2JULIAN(DATE_NOW(/GMT))

        IF (julian_now - julian_elements) GE ELEMENTS_DAYS THEN BEGIN
          targets= 'elements.dat'
          LIST, TARGETS
          ftp_batch, ftp_site=FTP_PATH,ACCOUNT='anonymous',PASSWORD='oreilly@fish1.gso.uri.edu',$
                     files=targets,DIR_REMOTE=DIR_REMOTE,DIR_LOCAL=dir_local_elements,OVERWRITE=1,$
                     _EXTRA=_extra,PS=_PS
          ENDIF ;IF (julian_now - julian_elements) GE ELEMENTS_DAYS THEN BEGIN
      ENDIF ;IF STRUPCASE(elements) EQ 'Y' THEN BEGIN
    ENDIF ;IF A_DATA_TYPE EQ 'ELEMENTS' THEN BEGIN


    IF A_DATA_TYPE EQ 'GSO_NEC' THEN BEGIN
        FTP_SITE = 'po.gso.uri.edu'
        PRINT, FTP_SITE
        dir_remote = 'pub/downloads/ses/nec/'
        targets=''
        INVENTORY     = 'd:\idl\inventory\inventory_SEAWIFS_NEC_GSO.CSV'
        DIR_LOCAL = GSO_NEC_LOCAL

        HOURS = ['153','154','155','16','17','180','181','182','183']
        FOR nth=0,N_ELEMENTS(HOURS)-1 DO BEGIN
          targets =[targets ,'S???????'+HOURS[NTH]+'*.all.nec.Z' ]
        ENDFOR
        targets=targets(1:*)
        LIST,targets
        ftp_batch, ftp_site=FTP_SITE,ACCOUNT='anonymous',PASSWORD='teresa@narwhal.gso.uri.edu',$
                    files=targets,DIR_REMOTE=DIR_REMOTE,DIR_LOCAL=dir_local,INVENTORY=INVENTORY,$
                    _EXTRA=_extra,PS=_PS
      ENDIF ;A_DATA_TYPE EQ 'GSO_NEC' THEN BEGIN


    IF A_DATA_TYPE EQ 'L3B_DAY' THEN BEGIN
      IF KEYWORD_SET(EMAIL) THEN FTP_PATH = URLS(_DATA_TYPE) ELSE $
      READ,FTP_PATH,PROMPT='ENTER FTP PATH FOR L3B_DAY FILES'
        IF FTP_PATH EQ '' THEN CONTINUE
        POS=STRPOS(FTP_PATH,'eosdata')
        ftp_site=STRMID(FTP_PATH,POS,21)
        PRINT, FTP_SITE
        dir_remote = STRMID(FTP_PATH,POS+22)
        targets=''
        INVENTORY     = 'd:\idl\inventory\inventory_SEAWIFS_L3B_DAY.CSV'
        DIR_LOCAL = L3B_DAY_LOCAL + 'SEAWIFS_L3B_DAY_NEW'
        targets = [TARGETS,'S*.L3b_DAY.*.Z','S*.L3_BRS_DAY*']
        targets=targets(1:*)
        LIST,targets
        ftp_batch, ftp_site=FTP_SITE,ACCOUNT='anonymous',PASSWORD='oreilly@fish1.gso.uri.edu',$
      ;             files=targets,DIR_REMOTE=DIR_REMOTE,DIR_LOCAL=dir_local,INVENTORY=INVENTORY,$
          n_files=7,files=targets,DIR_REMOTE=DIR_REMOTE,DIR_LOCAL=dir_local,INVENTORY=INVENTORY,$
                    _EXTRA=_extra,PS=_PS
      ENDIF ;IF A_DATA_TYPE EQ 'L3B_DAY' THEN BEGIN


    IF A_DATA_TYPE EQ 'L2_LAC' THEN BEGIN
      IF KEYWORD_SET(EMAIL) THEN FTP_PATH = URLS(_DATA_TYPE) ELSE $
      READ,FTP_PATH,PROMPT='ENTER FTP PATH FOR L3B_DAY FILES'
        IF FTP_PATH EQ '' THEN CONTINUE
        POS=STRPOS(FTP_PATH,'oceans.gsfc.nasa.gov')
        ftp_site=STRMID(FTP_PATH,POS,20)
        PRINT, FTP_SITE
        dir_remote = STRMID(FTP_PATH,27)
;				===> Add '\requested_files'
				dir_remote = dir_remote + '/requested_files'
        targets=''
        INVENTORY     = 'd:\idl\inventory\INVENTORY_MODIS_L2_LAC.CSV'
        DIR_LOCAL = 'I:\MODIS_AQUA\'
        targets = [TARGETS,'A*.L2_LAC.bz2']
        targets=targets(1:*)
        LIST,targets

;				===> Remove elements.dat

        ftp_batch, ftp_site=FTP_SITE,ACCOUNT='anonymous',PASSWORD='oreilly@fish1.gso.uri.edu',$
      ;             files=targets,DIR_REMOTE=DIR_REMOTE,DIR_LOCAL=dir_local,INVENTORY=INVENTORY,$
          n_files=2,files=targets,DIR_REMOTE=DIR_REMOTE,DIR_LOCAL=dir_local,INVENTORY=INVENTORY,$
                    _EXTRA=_extra,PS=_PS
      ENDIF ;IF A_DATA_TYPE EQ 'L3B_DAY' THEN BEGIN


  ENDFOR; DATA_TYPES

;   *********************************************
    IF  DO_AUTO_FTP_GET_SEAWIFS_NEC_GSO EQ 1 THEN BEGIN
      PRINT, 'S T E P:    DO_AUTO_FTP_GET_SEAWIFS_NEC_GSO'
      targets=''
      INVENTORY = 'd:\idl\inventory\inventory_SEAWIFS_NEC_GSO.CSV'
      HOURS = ['153','154','155','16','17','180','181','182','183']
      FOR nth=0,N_ELEMENTS(HOURS)-1 DO BEGIN
        targets =[targets ,'S???????'+HOURS[NTH]+'*.all.nec.Z' ]
      ENDFOR
      targets=targets(1:*)
      targets=[targets,'*log*','*LOG*']
      LIST,targets
      ftp_batch, ftp_site='po.gso.uri.edu',ACCOUNT='anonymous',PASSWORD = 'teresa@narwhal.gso.uri.edu',$
                 files = targets, DIR_REMOTE='pub/downloads/ses/nec/', DIR_LOCAL = GSO_NEC_LOCAL,INVENTORY=INVENTORY,$
                 /KEEP_FTP,PS=_PS
    ENDIF ; IF  DO_AUTO_FTP_GET_SEAWIFS_NEC_GSO EQ 1 THEN BEGIN

GET_SEAWIFS_L3B:
    IF DO_AUTO_FTP_GET_SEAWIFS_L3B GE 1 THEN BEGIN
    	UPDATE=0
    	DELAY=30
    	DO_AGAIN_L3B:

      ; this will get l3b data including PAR from samoa
      PRINT, 'GETTING global files from ftp://samoa.gsfc.nasa.gov/pub/sdps/V4/L3BIN/Daily/'
      FTP_PATH = 'samoa.gsfc.nasa.gov'
      DIR_REMOTE='pub/sdps/V4/L3BIN/Daily/'
      DIR_LOCAL=L3B_DAY_LOCAL+'seawifs_l3b_day_new'

      targets = ['S2004*.L3b_DAY.*.Z','S2004*.L3b_DAY_PAR.*.Z']
     ; targets = ['S20042*.L3b_DAY_PAR.*.Z']
      INVENTORY     = 'd:\idl\inventory\inventory_SEAWIFS_L3B_DAY.csv'
      LIST, TARGETS
      _n_files=2


stop

update=1
dir_local='I:\seawifs_l3b_day_z_backup\'
      ftp_batch, ftp_site=FTP_PATH,ACCOUNT='anonymous',PASSWORD='oreilly@fish1.gso.uri.edu',$
                n_files=_n_files,files=targets,DIR_REMOTE=DIR_REMOTE,DIR_LOCAL=dir_local,INVENTORY=INVENTORY,$
;                files=targets,DIR_REMOTE=DIR_REMOTE,DIR_LOCAL=dir_local,INVENTORY=INVENTORY,$
                          _EXTRA=_extra,PS=_PS,UPDATE=UPDATE
;                          _EXTRA=_extra,/PS,/update
			PRINT,'DOWNLOADED ',_n_files,' FILES. WAITING ',NUM2STR(60.*DELAY),'  SECONS BEFORE GETTING MORE FILES'
			WAIT, 60.*DELAY
			IF DO_AUTO_FTP_GET_SEAWIFS_L3B EQ 3 THEN GOTO,DO_AGAIN_L3B
    ENDIF ;IF DO_AUTO_FTP_GET_SEAWIFS_L3B EQ 1 THEN BEGIN



  GET_SPECIAL:
    IF DO_AUTO_SPECIAL EQ 1 THEN BEGIN

      PRINT, 'GETTING Special files from  ftp://ocdist2.sci.gsfc.nasa.gov/JGW0000000000001'
      FTP_PATH = 'ocdist2.sci.gsfc.nasa.gov'
      DIR_REMOTE='JGW0000000000001/requested_files'
      ;DIR_REMOTE='JGW0000000000001/requested_files'
      DIR_LOCAL='E:\seawifs_L1A_new'
      targets =  'S20041*.*'
      INVENTORY     = 'd:\idl\inventory\inventory_SPECIAL.csv'
      LIST, TARGETS

      ftp_batch, ftp_site=FTP_PATH,ACCOUNT='anonymous',PASSWORD='oreilly@narwhal.gso.uri.edu',$
                n_files=7,files=targets,DIR_REMOTE=DIR_REMOTE,DIR_LOCAL=dir_local,INVENTORY=INVENTORY,$
;                files=targets,DIR_REMOTE=DIR_REMOTE,DIR_LOCAL=dir_local,INVENTORY=INVENTORY,$
                          _EXTRA=_extra,PS=_PS
;                          _EXTRA=_extra,/PS,/update
    ENDIF ;IF DO_AUTO_FTP_GET_SEAWIFS_L3B EQ 1 THEN BEGIN

; ENDIF ;IF KEYWORD_SET(AUTO) THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||
  GOTO,DONE
 ENDIF ;IF KEYWORD_SET(AUTO) THEN BEGIN
; |||||||||||||||||||||||||||||||||||||||||||||||||



DONE:
END; #####################  End of Routine ################################

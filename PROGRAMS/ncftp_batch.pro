; $ID:	NCFTP_BATCH.PRO,	2020-06-30-17,	USER-KJWH	$
;+
; This Program Uses FTP to get files from a remote system.
;
; KEYWORDS:;
;         KEEP_FTP will not delete .txt file in d:\idl\programs\ created for the ftp session
; EXAMPLE:
; ftp_batch, ftp_site='samoa.gsfc.nasa.gov', files = ['S199820*.L3b_DAY_PAR*'], DIR_REMOTE='pub/sdps/V4/L3BIN/Daily', DIR_LOCAL = 'G:\z_l3b_PAR_S1997247_S2000210',/KEEP_FTP,N_FILES=2,/LOOK,INVENTORY='inventory_SEAWIFS_L3B_DAY_PAR.csv'
; ftp_batch, ftp_site='samoa.gsfc.nasa.gov', files = ['S200033*.L3b_DAY.main','S200033*.L3b_DAY_SWREP4.x07'], DIR_REMOTE='pub/sdps/V4/L3BIN/Daily', DIR_LOCAL = 'K:\SEAWIFS\Z',LOOP=2,/KEEP_FTP
; ftp_batch, ftp_site='samoa.gsfc.nasa.gov', files = ['S1998*.L3b_DAY.x*'], DIR_REMOTE='pub/sdps/V4/L3BIN/Daily', DIR_LOCAL = 'H:\Z_L3B',INVENTORY='D:\inventory\inventory_SEAWIFS_REPRO4_NASA_L3B_DAY.csv',/UPDATE
; ftp_batch, ftp_site='samoa.gsfc.nasa.gov', files = ['S*.L3b_DAY.x05'], DIR_REMOTE='pub/sdps/V4/L3BIN/Daily', DIR_LOCAL = '/lin2/seawifs_l3b_more',/KEEP_FTP
; ftp_batch, ftp_site='burrfish.gso.uri.edu', files = ['*.pro','*.JAY'], DIR_REMOTE='sub/sub2', DIR_LOCAL = 'G:/FTP_TEST',CHECK='G:\FTP_TEST',ACCOUNT='JJJ',PASSWORD='JJJ212121',LOOP=2
; ftp_batch, ftp_site='po.gso.uri.edu', files = ['S*all.nec.Z'], DIR_REMOTE='pub\downloads\ses\nec\', DIR_LOCAL = 'F:\SEAWIFS_NEC_GSO',INVENTORY='D:\inventory\inventory_SEAWIFS_NEC_GSO.csv',/UPDATE
; ncftp_batch, ftp_site='', files = ['S*L1A*.Z'], DIR_REMOTE='', DIR_LOCAL = 'H:\seawifs_l1a_S2001151_S2001215',INVENTORY='D:\inventory\inventory_SEAWIFS_L1A.csv',/UPDATE,/look
; AVHRR:
; ncftp_batch, ftp_site='saa.noaa.gov', files = ['*.cwf'], DIR_REMOTE='ncaas/fluently', DIR_LOCAL = 'F:/AVHRR/AVHRR', /KEEP_FTP
; ncftp_batch, ftp_site='saa.noaa.gov', files = ['*c1*.cwf','*c2*.cwf'], DIR_REMOTE='ncaas/fluently', DIR_LOCAL = 'F:/AVHRR/C1_2'

; GOES:
; ncftp_batch, ftp_site = 'saasp1.saa.noaa.gov', files =  'sst3*' , DIR_REMOTE='goessst/GOES200201', DIR_LOCAL='F:/GOES/GOES_SST/' , INVENTORY='D:\IDL\inventory\inventory_GOES_SST.csv'
; ncftp_batch, ftp_site = 'saasp1.saa.noaa.gov', files =  'sst3*' , DIR_REMOTE='goessst/GOES200202', DIR_LOCAL='F:/GOES/GOES_SST/' , INVENTORY='D:\IDL\inventory\inventory_GOES_SST.csv'
; ncftp_batch, ftp_site = 'saasp1.saa.noaa.gov', files =  'sst3*' , DIR_REMOTE='goessst/GOES200203', DIR_LOCAL='F:/GOES/GOES_SST/' , INVENTORY='D:\IDL\inventory\inventory_GOES_SST.csv'
; ncftp_batch, ftp_site = 'saasp1.saa.noaa.gov', files =  'sst3*' , DIR_REMOTE='goessst/GOES200204', DIR_LOCAL='F:/GOES/GOES_SST/' , INVENTORY='D:\IDL\inventory\inventory_GOES_SST.csv'


; CATEGORY:
; NOTES:
; HISTORY:
;   July 17, 2002 Written by: J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;   July 18, 2002 td, work with LINUX
;   July 19, 2002 jor removed CHECK and added keyword OVERWRITE
;   July 24, 2002 td, add KEEP_FTP
;   July 25, 2002,td, add LOOK,check for .Z, .gz
;   July 30, 2002,td, add INVENTORY
;   Aug   1, 2002 td, add UPDATE
;   Oct 4,2002  jor,  added MIN_SIZE ; DEFAULT IS 1 BYTE UNLESS MIN_SIZE IS SPECIFIED,
;                     IF MIN_SIZE AND UPDATE ARE SPECIFIED THEN INVENTORY IS EDITED TO CONTAIN ONLY EXISTING FILES ON LOCAL DIR
;   Oct 21,2002 td, add n_files,sat_date_plot
;   Nov 15, 2002 jor, ;     IF _DIR_LOCAL IS 2 OR MORE DIRECTORIES THEN USE FILE_SEARCH ELSE USE FASTER FILELIST
;   Nov 18, 2002 td, add PS keyword
;   Mar 18, 2003 jor,td, add use of strmatch & dup programs to narrow down remote_files to get
;		May 6, 2003 jor, now using WHERE_IN
;   Oct 6, 2003 td, make a -COPY of inventory file
;   Apr 8, 2004 td, remove 0 length files from inventory
;		Jan 27,2006 JOR RENAME SCRIPT_FILE with calling program name to avoid conflicts when having multiple ncftp_batch sessions on a single computer
;		Jan 27, 2006 JOR We now keep the ftp_script .txt files  Eliminated KEEP_FTP keyword
;-
; *************************************************************************

  PRO ncftp_batch, FTP_SITE=FTP_SITE, ACCOUNT=account, PASSWORD=password, DIR_REMOTE=DIR_REMOTE,FILES=files,$
                 N_FILES=n_files,DIR_LOCAL=DIR_LOCAL ,INVENTORY=INVENTORY,USE_CASE = use_case,LOOP=loop,SKIP_LS=skip_ls,$
                 LOOK=look,UPDATE=UPDATE,OVERWRITE=overwrite,MIN_SIZE=min_size,PS=ps, SORT_REVERSE=sort_reverse

  ROUTINE_NAME='ncftp_batch'

	COMPUTER=GET_COMPUTER()

	HELP,CALLS=CALLS

;	===> Determine the calling routine (to add to script_file name)
	CALLING_ROUTINE = CALLER(2)
	DIR_IDL='d:\IDL\PROGRAMS\'


  ;IF N_ELEMENTS(FTP_SITE) NE 1 THEN STOP

  IF N_ELEMENTS(ACCOUNT) NE 1 THEN ACCOUNT = 'anonymous'
  ;IF N_ELEMENTS(PASSWORD) NE 1 THEN PASSWORD = 'teresa@narwhal.gso.uri.edu'
  IF N_ELEMENTS(PASSWORD) NE 1 THEN PASSWORD = 'oreilly@narwhal.gso.uri.edu'

  IF N_ELEMENTS(FILES) LT 1 THEN STOP
  IF N_ELEMENTS(DIR_LOCAL) LT 1 THEN STOP
  IF N_ELEMENTS(OVERWRITE) LT 1 THEN _OVERWRITE = 0 ELSE _OVERWRITE=OVERWRITE
  IF N_ELEMENTS(UPDATE) LT 1 THEN UPDATE = 0
  IF N_ELEMENTS(LOOP) EQ 0 THEN LOOP = 1
  IF N_ELEMENTS(MIN_SIZE) NE 1 THEN _MIN_SIZE = 1 ELSE _MIN_SIZE = MIN_SIZE
  IF N_ELEMENTS(N_FILES) LT 1 THEN N_FILES = 0
 	IF N_ELEMENTS(SKIP_LS) LT 1 THEN SKIP_LS = 0
  _DIR_LOCAL 	= REMOVE_LAST_SLASH(DIR_LOCAL)
  _DIR_REMOTE = REMOVE_LAST_SLASH(DIR_REMOTE)

  IF KEYWORD_SET(UPDATE) THEN GOTO, UPDATE_

  FOR _LOOP = 1L,LOOP DO BEGIN
		IF NOT KEYWORD_SET(SKIP_LS) THEN BEGIN

 			IF STRUPCASE(!VERSION.OS) EQ 'WIN32' THEN BEGIN
	      FTP_OUTPUT_file = 'ncftp_batch_ls-'+CALLING_ROUTINE+'.txt'
	      cmd = 'ncftpls -1 '+_dir_remote+'/'
	    ENDIF ;IF STRUPCASE(!VERSION.OS) EQ 'WIN32' THEN BEGIN


	    IF STRUPCASE(!VERSION.OS) EQ 'LINUX' THEN BEGIN
	      script_file = 'ncftp_batch_ls-'+CALLING_ROUTINE+'.txt'
	      txt ='#!/usr/bin/sh'
	      txt = [txt,'ftp -n << EOF']
	      txt = [txt,'verbose']
	      txt = [txt,'open '+ftp_site]
	      txt = [txt,'user '+ACCOUNT+' '+PASSWORD]
	      txt = [txt, 'prompt']
	      txt = [txt, 'verbose']
	      txt = [txt, 'binary']
	      txt = [txt, 'lcd '+_DIR_LOCAL]
	      txt = [txt, 'cd ' + _DIR_REMOTE]
	      FOR n = 0L,N_ELEMENTS(FILES)-1L DO BEGIN
	        txt = [txt,'ls ' + FILES(n)]
	      ENDFOR
	      txt = [txt,'close']
	      txt = [txt, 'EOF']
	      WRITE_TXT,SCRIPT_FILE,TXT
	      CMD =  '. '+script_file
	    ENDIF ;IF STRUPCASE(!VERSION.OS) EQ 'LINUX' THEN BEGIN

			PRINT,CMD
	    SPAWN, CMD, file_list
	    IF N_ELEMENTS(FILE_LIST) LT 1 THEN CONTINUE

	  ;  IF KEYWORD_SET(LOOK) THEN STOP

	    IF STRUPCASE(!VERSION.OS) EQ 'WIN32' THEN BEGIN

	      IF FILE_LIST[0] NE '' THEN BEGIN
	        FILES_REMOTE = FILE_LIST
	      ENDIF ELSE BEGIN
	      	FILES_REMOTE=''
	    		PRINT,'NO FILES FOUND ON DIR_REMOTE: '+ _DIR_REMOTE
	        GOTO, UPDATE_
	      ENDELSE

	    ENDIF ;IF STRUPCASE(!VERSION.OS) EQ 'WIN32' THEN BEGIN


	    IF STRUPCASE(!VERSION.OS) EQ 'LINUX' THEN BEGIN
	      TXT_START='Local directory now '+_DIR_LOCAL
	      OK_FIRST = WHERE(STRPOS(file_LIST,TXT_START) GE 0,COUNT_FIRST)
	      IF OK_FIRST[0] EQ -1 THEN BEGIN
	        PRINT,'ERROR: CAN NOT LOG ON TO REMOTE SYSTEM'
	        GOTO, UPDATE_
	      ENDIF
	      OK_LAST = N_ELEMENTS(FILE_LIST)-1L
	      FILES_REMOTE = ''
	      IF OK_LAST GT OK_FIRST THEN BEGIN
	        FILES_REMOTE = file_list(OK_FIRST+1:OK_LAST)
	        FOR N=0L,N_ELEMENTS(FILES_REMOTE)-1L DO BEGIN
	          TXT = STRCOMPRESS(FILES_REMOTE(N),/REMOVE_ALL)
	          TXTA = STRSPLIT(TXT,'/',/EXTRACT)
	          FILES_REMOTE(N)=LAST(TXTA)
	        ENDFOR
	      ENDIF
	    ENDIF ;IF STRUPCASE(!VERSION.OS) EQ 'LINUX' THEN BEGIN
		ENDIF ELSE BEGIN
			FILES_REMOTE=FILES
		ENDELSE ;IF NOT KEYWORD_SET(SKIP_LS) THEN BEGIN


;   =====> Make sure have files
    OK = WHERE(STRLEN(FILES_REMOTE) GE 1,COUNT)
    IF COUNT GE 1 THEN BEGIN
      FILES_REMOTE = FILES_REMOTE[OK]
     	PRINT,'FOUND '+NUM2STR(N_ELEMENTS(FILE_LIST))+' FILES IN FOLDER :'+ _DIR_REMOTE
    ENDIF ELSE BEGIN
      PRINT,'ERROR: NO FILES FOUND ON REMOTE SYSTEM'
      GOTO, UPDATE_
    ENDELSE

    OK= WHERE(STRPOS(FILES_REMOTE,'.MET') GE 0 OR STRPOS(FILES_REMOTE,'.OZONE') GE 0 OR STRPOS(FILES_REMOTE,'.L1A_MLAC') GE 0 $
    		OR STRPOS(FILES_REMOTE,'.L1A_LAC') GE 0 OR STRPOS(FILES_REMOTE, 'PM1') GE 0,COUNT)
    IF COUNT GT 0 THEN BEGIN
   		TARGETS_REMOTE = FILES_REMOTE
   		TARGETS=FILES
   	ENDIF ELSE BEGIN
	 		pos=strpos(files_remote,'.')+1
	 	  targets_remote=strmid(files_remote,pos[0])
	 		pos=strpos(files,'.')+1
	 	  targets=strmid(files,pos[0])
	 	ENDELSE


		ok=where_in(targets_remote,targets,count)
		IF COUNT GE 1 THEN BEGIN
      FILES_REMOTE = FILES_REMOTE[OK]
     	PRINT,'FOUND '+NUM2STR(N_ELEMENTS(FILE_LIST))+' FILES matching our targets IN FOLDER :'+ _DIR_REMOTE
    ENDIF ELSE BEGIN
      PRINT,'ERROR: NO FILES FOUND ON REMOTE SYSTEM'
      GOTO, UPDATE_
    ENDELSE


    _FILES_REMOTE=FILES_REMOTE
    _FILES_REMOTE=REPLACE(_FILES_REMOTE,'.gz','')
    _FILES_REMOTE=REPLACE(_FILES_REMOTE,'.z','')
    _FILES_REMOTE=REPLACE(_FILES_REMOTE,'.GZ','')
    _FILES_REMOTE=REPLACE(_FILES_REMOTE,'.Z','')
    _FILES_REMOTE=REPLACE(_FILES_REMOTE,'.bz2','')
  ;  IF KEYWORD_SET(LOOK) THEN STOP



;stop


;   *************** Default is NOT TO OVERWRITE FILES IF THEY AREADY EXIST ON LOCAL DRIVE
    IF NOT KEYWORD_SET(_OVERWRITE) THEN BEGIN
      COPY=FILES
      FILES_LOCAL = ''

;     IF _DIR_LOCAL IS 2 OR MORE DIRECTORIES THEN USE FILE_SEARCH ELSE USE FASTER FILELIST
      FOR N = 0L,N_ELEMENTS(FILES)-1L DO BEGIN
        IF N_ELEMENTS(_DIR_LOCAL) GE 2 THEN BEGIN
          FILES_LOCAL = [FILES_LOCAL, FILE_SEARCH(_DIR_LOCAL,FILES(N))]
        ENDIF ELSE BEGIN
          FILES_LOCAL = [FILES_LOCAL, FILELIST(_DIR_LOCAL+DELIMITER(/PATH)+FILES(N))]
        ENDELSE
      ENDFOR

;     =====> Check which Local files are gt 0 bytes
      FI = FILE_INFO(FILES_LOCAL)
      OK_LOCAL = WHERE(FI.SIZE GE _min_size AND STRLEN(FILES_LOCAL) GE 1,COUNT_LOCAL)

      IF COUNT_LOCAL GE 1 THEN BEGIN
        FILES_LOCAL=FILES_LOCAL(OK_LOCAL)
        _FILES_LOCAL=FILES_LOCAL
        _FILES_LOCAL=REPLACE(_FILES_LOCAL,'.gz','')
        _FILES_LOCAL=REPLACE(_FILES_LOCAL,'.z','')
        _FILES_LOCAL=REPLACE(_FILES_LOCAL,'.GZ','')
        _FILES_LOCAL=REPLACE(_FILES_LOCAL,'.Z','')
        _FILES_LOCAL=REPLACE(_FILES_LOCAL,'.bz2','')
         FN  = PARSE_IT(_FILES_LOCAL)
        _FILES_LOCAL = FN.NAME+FN.EXT_DELIM+FN.EXT
        PRINT
        PRINT,'FOUND ' + NUM2STR(COUNT_LOCAL) + ' FILES MATCHING SEARCH STRINGS ON HARD DRIVE OR IN INVENTORY'
        PRINT
      ENDIF

;     =====> Check if INVENTORY Exists or provided
      _csv_names=''
      IF N_ELEMENTS(INVENTORY) EQ 1 THEN BEGIN
        EXIST_CSV=FILE_INFO(INVENTORY)
        IF EXIST_CSV.EXISTS EQ 1 THEN BEGIN
          EXIST_CSV_COPY=FILE_INFO(INVENTORY+'-COPY')
          IF EXIST_CSV_COPY.SIZE LT EXIST_CSV.SIZE THEN BEGIN
            FILE_COPY,INVENTORY,INVENTORY+'-COPY',/OVERWRITE
          ENDIF

;					===> GET SIMILAR INVENTORIES (FROM DIFFERENT COMPUTERS)
          FN=FILE_PARSE(INVENTORY)
          INVENTORIES= REPLACE(INVENTORY,COMPUTER,'*')
          INVENTORIES= FILELIST(INVENTORIES)
          CSV_NAMES=''
          FOR _INV = 0,N_ELEMENTS(INVENTORIES)-1 DO BEGIN
          	 CSV_LIST = READ_CSV(INVENTORIES(_INV))
          	 CSV_NAMES=[CSV_NAMES,CSV_LIST.NAME_EXT]
          ENDFOR

          CSV_NAMES=CSV_NAMES(1:*)

         ; FN_CSV=PARSE_IT(CSV_NAMES)
         ; CSV_NAMES=FN_CSV.NAME

          FOR n = 0L,N_ELEMENTS(FILES)-1L DO BEGIN
            txt_match=FILES(n)
            _txt_match=txt_match
            _txt_match=REPLACE(_txt_match,'.gz','')
            _txt_match=REPLACE(_txt_match,'.z','')
            _txt_match=REPLACE(_txt_match,'.GZ','')
            _txt_match=REPLACE(_txt_match,'.Z','')
            _txt_match=REPLACE(_txt_match,'.bz2','')
            OK_MATCH = WHERE(STRMATCH(CSV_NAMES, _txt_match, /FOLD_CASE) EQ 1,COUNT_MATCH)
            IF COUNT_MATCH GE 1 THEN _csv_names = [_csv_names,csv_names(ok_match)]
          ENDFOR
          IF N_ELEMENTS(_csv_names) GT 1 THEN BEGIN
            _csv_names = _csv_names(1:*)
            IF N_ELEMENTS(_FILES_LOCAL) GE 1 THEN _FILES_LOCAL = [_FILES_LOCAL, _CSV_NAMES] ELSE _FILES_LOCAL = _CSV_NAMES ;;
            COUNT_LOCAL = N_ELEMENTS(_FILES_LOCAL)
          ENDIF
        ENDIF ; IF EXIST_CSV EQ 1 THEN BEGIN
      ENDIF



;     =====> IF COUNT_LOCAL IS ZERO THEN NO NEED TO COMPARE FILES_LOCAL WITH FILES_REMOTE
      IF COUNT_LOCAL EQ 0 THEN GOTO,GET_REMOTE_FILES

;     =====> COMPARE FILES_LOCAL WITH FILES_REMOTE
;     =====> Remove Duplicate names from _FILES_LOCAL (local (disk) and Local (from CSV))
      temp = _FILES_LOCAL
      srt = SORT(temp) & _FILES_LOCAL=_FILES_LOCAL(srt) & u=UNIQ(_FILES_LOCAL) & _FILES_LOCAL=_FILES_LOCAL(u) ;;

;     =====> Now Compare Local names with Remote Names To Determine Which Remote Files to Get
			OK = WHERE_IN(_FILES_REMOTE, _FILES_LOCAL ,Count,NCOMPLEMENT=ncomplement,COMPLEMENT=complement)

      IF NCOMPLEMENT GE 1 THEN BEGIN
        FILES_REMOTE = FILES_REMOTE(COMPLEMENT)
      ENDIF ELSE BEGIN
        PRINT
        PRINT,'ALL FILES ON REMOTE SYSTEM ARE PRESENT ON LOCAL SYSTEM'
        PRINT
        GOTO,UPDATE_
      ENDELSE
    ENDIF ;IF NOT KEYWORD_SET(_OVERWRITE) THEN BEGIN


;   ***************************************
    GET_REMOTE_FILES:
;   ***************************************
    IF N_ELEMENTS(FILES_REMOTE) GE 1 THEN BEGIN
;     FILES_REMOTE = DUP[OK].SET
;      IF KEYWORD_SET(LOOK) THEN STOP

;     =====> If the user only wants N_FILES downloaded at this time then subset the FILES_REMOTE
      IF N_FILES GT 0 THEN BEGIN
      	IF KEYWORD_SET(SORT_REVERSE) THEN FILES_REMOTE = REVERSE(FILES_REMOTE)
        _LAST = (N_FILES-1L) < (N_ELEMENTS(FILES_REMOTE)-1L)
        FILES_REMOTE = FILES_REMOTE(0:_LAST)
      ENDIF
      PRINT
      PRINT,'Getting ' + NUM2STR(N_ELEMENTS(FILES_REMOTE)) + ' FILES FROM REMOTE SYSTEM'
      PRINT

;     ENDIF  ;IF N_ELEMENTS(FILES_REMOTE) GE 1 THEN
    ENDIF ELSE BEGIN
      PRINT
      PRINT,'ALL FILES ON REMOTE SYSTEM ARE PRESENT ON LOCAL SYSTEM'
      PRINT
      GOTO,UPDATE_
    ENDELSE

    IF STRUPCASE(!VERSION.OS) EQ 'WIN32' THEN BEGIN

;STOP
;			cmd='cd,'+DIR_LOCAL
;			PRINT,CMD
;			SPAWN,CMD
;
      FOR N=0L,N_ELEMENTS(FILES_REMOTE)-1L DO BEGIN
        cmd = 'ncftpget  '+_DIR_REMOTE+'/'+FILES_REMOTE(N)
				PRINT, CMD
 				IF KEYWORD_SET(LOOK) THEN BEGIN
    			LOOK=FILES_REMOTE
    		ENDIF ELSE BEGIN
    			SPAWN, CMD, result
  				;MOVE  file to dir_z
					z_FILES = FILE_SEARCH('d:\idl\programs\'+FILES_REMOTE(N))
					FN=PARSE_IT(Z_files)
					ok=where(FN.NAME NE '',count)
					IF count GE 1 THEN BEGIN
						FN = FN[OK]
						FOR _FILE=0,N_ELEMENTS(FN)-1 DO BEGIN
							mlac_file=FN(_FILE).FULLNAME
							dir_z_file=DIR_LOCAL+FN(_FILE).NAME+'.'+FN(_FILE).EXT
							exist_mlac=FILE_TEST(mlac_file)

							IF EXIST_MLAC EQ 1 THEN BEGIN
								FILE_MOVE,MLAC_FILE,DIR_Z_FILE
							ENDIF
						ENDFOR;	FOR _FILE=0,N_ELEMENTS(Z_FILES)-1 DO BEGIN
					ENDIF ELSE BEGIN
						CONTINUE
					ENDELSE
    		ENDELSE
      ENDFOR
;      cmd='cd,'+DIR_IDL
;			PRINT,CMD
;			SPAWN,CMD
;
;stop
    ENDIF; IF STRUPCASE(!VERSION.OS) EQ 'WIN32' THEN BEGIN


    IF STRUPCASE(!VERSION.OS) EQ 'LINUX' THEN BEGIN
      script_file = 'ncftp_batch_get-'+CALLING_ROUTINE+'.txt'
      txt ='#!/usr/bin/sh'
      txt = [txt,'ftp -n << EOF']
      txt = [txt,'verbose']
      txt = [txt,'open '+ftp_site]
      txt = [txt,'user '+ACCOUNT+' '+PASSWORD]
      txt = [txt, 'prompt']
      txt = [txt, 'verbose']
      txt = [txt, 'binary']
      txt = [txt, 'lcd '+_DIR_LOCAL]
      txt = [txt, 'cd ' + _DIR_REMOTE]
      FOR N=0L,N_ELEMENTS(FILES_REMOTE)-1L DO BEGIN
        txt = [txt,'get ' + FILES_REMOTE(N)]
      ENDFOR
      txt = [txt,'close']
      txt = [txt, 'EOF']
      WRITE_TXT,SCRIPT_FILE,TXT
      CMD =  '. '+script_file
      IF KEYWORD_SET(LOOK) THEN BEGIN
    		LOOK=FILES_REMOTE
    	ENDIF ELSE BEGIN
    		SPAWN, CMD, result
    	ENDELSE
    ENDIF ;IF STRUPCASE(!VERSION.OS) EQ 'LINUX' THEN BEGIN



  ENDFOR ; LOOP


; ****************************************
    UPDATE_:
; ****************************************
; if remote_files are in dir_local and file sizes are GE _MIN_SIZE then add to INVENTORY.CSV
; IF a local file size is smaller than MIN_SIZE and its name is in the INVENTORY, then remove it from the INVENTORY
  IF N_ELEMENTS(INVENTORY) LT 1 THEN GOTO,DONE
  IF KEYWORD_SET(LOOK) THEN STOP

  FILES_LOCAL = ''
  FOR N = 0L,N_ELEMENTS(FILES)-1L DO BEGIN
    FILES_LOCAL = [FILES_LOCAL, FILE_SEARCH(_DIR_LOCAL,FILES(N))]
  ENDFOR
  OK = WHERE(STRLEN(FILES_LOCAL) GE 1,COUNT)
  IF COUNT GE 1 THEN FILES_LOCAL = FILES_LOCAL[OK] ELSE GOTO, DONE
  _FILES_LOCAL=FILES_LOCAL
  _FILES_LOCAL=REPLACE(_FILES_LOCAL,'.gz','')
  _FILES_LOCAL=REPLACE(_FILES_LOCAL,'.z','')
  _FILES_LOCAL=REPLACE(_FILES_LOCAL,'.GZ','')
  _FILES_LOCAL=REPLACE(_FILES_LOCAL,'.Z','')
  _FILES_LOCAL=REPLACE(_FILES_LOCAL,'.bz2','')
  FN  = PARSE_IT(_FILES_LOCAL)
  _FILES_LOCAL = FN.NAME+FN.EXT_DELIM+FN.EXT

; =====> Check which Local files are gt 0 bytes
  FI = FILE_INFO(FILES_LOCAL)

  OK_LOCAL = WHERE(FI.SIZE GE _min_size AND STRLEN(FILES_LOCAL) GE 1,$
                        COUNT_LOCAL,NCOMPLEMENT=COUNT_BAD,COMPLEMENT=OK_BAD)
  IF COUNT_BAD GE 1 THEN BEGIN
    PRINT, 'Removing the Following Names from the Inventory: '+INVENTORY
    PRINT, 'Because Their Size is Smaller Than: '+NUM2STR(_MIN_SIZE)
    BAD_FILES_CSV =  _FILES_LOCAL(OK_BAD)
    BAD_FILES_LOCAL= FILES_LOCAL(OK_BAD)

    LIST, BAD_FILES_LOCAL
    EXIST_CSV=FILE_TEST(INVENTORY)
    IF EXIST_CSV EQ 1 THEN BEGIN
      CSV=READ_CSV(INVENTORY)
  ;   ==============> Remove any bad file names from csv
      FOR _BAD = 0,N_ELEMENTS(BAD_FILES_CSV)-1 DO BEGIN
        ABAD = BAD_FILES_CSV(_BAD)
        OK_BAD = WHERE(CSV.NAME_EXT EQ ABAD,COUNT)
        IF COUNT GE 1 THEN BEGIN
          PRINT, 'REMOVING: '+ABAD+' From INVENTORY'
          CSV = REMOVE(CSV,OK_BAD)
        ENDIF
      ENDFOR
      STRUCT_2CSV,INVENTORY,CSV
    ENDIF ;IF EXIST_CSV EQ 1 THEN BEGIN

    FOR _BAD = 0,N_ELEMENTS(BAD_FILES_LOCAL)-1 DO BEGIN
       PRINT, 'REMOVING: '+BAD_FILES_LOCAL(_BAD)
        FILE_DELETE,BAD_FILES_LOCAL(_BAD),/QUIET
    ENDFOR
  ENDIF  ;IF COUNT_BAD GE 1 THEN BEGIN
  IF COUNT_LOCAL LT 1L THEN BEGIN
    PRINT, 'NO NEW FILES TO BE ADDED TO INVENTORY* CSV FILE'
    GOTO, DONE
  ENDIF

  IF COUNT_LOCAL GE 1 THEN BEGIN
    FILES_LOCAL=FILES_LOCAL(OK_LOCAL)
    FI=FI(OK_LOCAL)
    _FILES_LOCAL=_FILES_LOCAL(OK_LOCAL)
    PRINT
    PRINT,'FOUND ' + NUM2STR(COUNT_LOCAL) + ' FILES MATCHING SEARCH STRINGS IN FOLDER: '+_DIR_LOCAL
    PRINT
    FILES_ALL=_FILES_LOCAL
    DATE = STRARR(N_ELEMENTS(_FILES_LOCAL))
    DATE(*)=DATE_NOW()
    COMPUTERS = REPLICATE(GET_COMPUTER(),N_ELEMENTS(_FILES_LOCAL))
    FILE_SIZE = NUM2STR(FI.SIZE)
    EXIST_CSV=FILE_TEST(INVENTORY)

    IF EXIST_CSV EQ 1 THEN BEGIN
      CSV=READ_CSV(INVENTORY)
      FILES_CSV=CSV.NAME_EXT
      DATE_CSV=CSV.DATE
      FILE_SIZE_CSV=CSV.SIZE
      COMPUTER_CSV=CSV.COMPUTER

      FILES_ALL=[FILES_ALL,FILES_CSV]
      DATE=[DATE,DATE_CSV]
      FILE_SIZE = [FILE_SIZE,FILE_SIZE_CSV]
      COMPUTERS = [COMPUTERS,COMPUTER_CSV]
    ENDIF
  ENDIF ;IF COUNT_LOCAL GE 1 THEN BEGIN



  IF N_ELEMENTS(INVENTORY) EQ 1 THEN BEGIN

    FILES_DATE=FILES_ALL+STRTRIM(DATE)
    _FILES_DATE=FILES_DATE
    S = SORT(_FILES_DATE)
    FILES_DATE=FILES_DATE(S)
    FILES_ALL=FILES_ALL(S)
    DATE=DATE(S)
    FILE_SIZE=FILE_SIZE(S)
    COMPUTERS=COMPUTERS(S)

    U=UNIQ(FILES_ALL)

    FILES_ALL=FILES_ALL(U)
    DATE=DATE(U)
    FILE_SIZE=FILE_SIZE(U)
    COMPUTERS=COMPUTERS(U)
    temp   = CREATE_STRUCT('NAME_EXT','','DATE','','SIZE','','COMPUTER','') & temp=REPLICATE(temp,N_ELEMENTS(FILES_ALL))
    temp.NAME_EXT= FILES_ALL
    temp.DATE=DATE
    temp.SIZE=FILE_SIZE
    temp.COMPUTER=COMPUTERS
    STRUCT_2CSV,INVENTORY,TEMP
    TEMP = ''
  ENDIF
  IF KEYWORD_SET(PS) AND N_ELEMENTS(INVENTORY) EQ 1 THEN BEGIN
    label=inventory
    fn=parse_it(inventory)
    SAT_DATE_PLOT,FILES=files_ALL,DIR=fn.dir,label=fn.name,/PS
  ENDIF

  DONE:



END; #####################  End of Routine ################################

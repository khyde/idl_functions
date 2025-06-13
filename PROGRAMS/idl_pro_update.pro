; $ID:	IDL_PRO_UPDATE.PRO,	2020-06-26-15,	USER-KJWH	$
;+
;	This Program:
;					 0) Changes any lower case programs to UPPER Case
;					 1) Copies 		 IDL Program Files from D TO Z  if not present on Z
;					 2) Copies 		 IDL Program Files from Z TO D  if not present on D
;					 3) Overwrites IDL Program Files on Z with Newer files on D
;					 4) Overwrites IDL Program Files on D with Newer files on Z
;

; HISTORY:
;		May 8, 2003 jor,td Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882

;-
; *************************************************************************

PRO IDL_PRO_UPDATE
  ROUTINE_NAME='IDL_PRO_UPDATE'



; =====> 0) Changes any lower case programs to UPPER Case on D and Z Drives
 	FD = FILE_SEARCH('D:\IDL\PROGRAMS\*.PRO')
 	FN = PARSE_IT(FD)

 	OK = WHERE(FN.NAME NE STRUPCASE(FN.NAME),COUNT)
 	IF COUNT GE 1 THEN BEGIN
      D = FD[OK]
;			FILE_COPY, D,D
    	FOR N=0L,N_ELEMENTS(D)-1L DO BEGIN
    		CMD = 'COPY '+ D(N) + ' ' + 'D:\IDL\PROGRAMS\__________JUNK__________.PRO
    		SPAWN, CMD
    		PRINT, CMD
    		CMD = 'MOVE '+ 'D:\IDL\PROGRAMS\__________JUNK__________.PRO' + ' ' + STRUPCASE(D(N))
    		PRINT, CMD
       	SPAWN, CMD
    	ENDFOR
 	ENDIF ELSE BEGIN
 		PRINT, 'All Program Files on D are Upper Case'
 	ENDELSE


; Z DRIVE
	FZ = FILE_SEARCH('Z:\PROGRAMS\*.PRO')
 	FN = PARSE_IT(FZ)

 	OK = WHERE(FN.NAME NE STRUPCASE(FN.NAME),COUNT)
 	IF COUNT GE 1 THEN BEGIN
      Z = FZ[OK]
;			FILE_COPY, Z,Z
    	FOR N=0L,N_ELEMENTS(Z)-1L DO BEGIN
    		CMD = 'COPY '+ Z(N) + ' ' + 'Z:\PROGRAMS\__________JUNK__________.PRO
    		SPAWN, CMD
    		PRINT, CMD
    		CMD = 'MOVE '+ 'Z:\PROGRAMS\__________JUNK__________.PRO'+ ' ' + STRUPCASE(Z(N))
    		PRINT, CMD
       	SPAWN, CMD
    	ENDFOR
 	ENDIF ELSE BEGIN
 		PRINT, 'All Program Files on Z are Upper Case'
 	ENDELSE


; =====>1) Copies 		 IDL Program Files from D TO Z  if not present on Z
  FD = FILE_SEARCH('D:\IDL\PROGRAMS\*.PRO')
  FZ = FILE_SEARCH(		'Z:\PROGRAMS\*.PRO')
  FD = PARSE_IT(FD)
  FZ = PARSE_IT(FZ)
  FD.FIRST_NAME = STRUPCASE(FD.FIRST_NAME)
  FZ.FIRST_NAME = STRUPCASE(FZ.FIRST_NAME)
	ok = WHEREIN(FD.FIRST_NAME, FZ.FIRST_NAME,Count,NCOMPLEMENT=ncomplement,COMPLEMENT=complement)
  IF ncomplement GE 1 THEN BEGIN
  	D = FD(complement).FULLNAME   & Z = 'Z:\PROGRAMS\'+FD(complement).FIRST_NAME+'.PRO'
  ;	FILE_COPY, D,Z
    FOR N=0L,N_ELEMENTS(D)-1L DO BEGIN
    	CMD = 'COPY '+ D(N) + ' ' + Z(N)
    	PRINT, CMD
      SPAWN, CMD
    ENDFOR
  ENDIF ELSE BEGIN
  	PRINT, 'ALL FILES ON D ARE PRESENT ON Z'
  ENDELSE

; =====>2) Copies 		 IDL Program Files from Z TO D  if not present on D
	FD = FILE_SEARCH('D:\IDL\PROGRAMS\*.PRO')
  FZ = FILE_SEARCH(		'Z:\PROGRAMS\*.PRO')
  FD = PARSE_IT(FD)
  FZ = PARSE_IT(FZ)
  FD.FIRST_NAME = STRUPCASE(FD.FIRST_NAME)
  FZ.FIRST_NAME = STRUPCASE(FZ.FIRST_NAME)
	ok = WHEREIN(FZ.FIRST_NAME, FD.FIRST_NAME,Count,NCOMPLEMENT=ncomplement,COMPLEMENT=complement)
  IF ncomplement GE 1 THEN BEGIN
  	Z = FZ(complement).FULLNAME   & D = 'D:\IDL\PROGRAMS\'+FZ(complement).FIRST_NAME+'.PRO'
  ;	FILE_COPY, Z,D
    FOR N=0L,N_ELEMENTS(Z)-1L DO BEGIN
    	CMD = 'COPY '+ Z(N) + ' ' + D(N)
    	PRINT, CMD
      SPAWN, CMD
    ENDFOR
  ENDIF ELSE BEGIN
  	PRINT, 'ALL FILES ON Z ARE PRESENT ON D'
  ENDELSE

STEP_3:
; =====>3) Overwrites IDL Program Files on Z with Newer files on D
	FD = FILE_SEARCH('D:\IDL\PROGRAMS\*.PRO')
  FZ = FILE_SEARCH(		'Z:\PROGRAMS\*.PRO')
  FD = PARSE_IT(FD)
  FZ = PARSE_IT(FZ)
  FD.FIRST_NAME = STRUPCASE(FD.FIRST_NAME)
  FZ.FIRST_NAME = STRUPCASE(FZ.FIRST_NAME)
  S=SORT(FD.FIRST_NAME) & FD = FD(S)
  S=SORT(FZ.FIRST_NAME) & FZ = FZ(S)
	ok = WHEREIN(FD.FIRST_NAME, FZ.FIRST_NAME,Count,NCOMPLEMENT=ncomplement,COMPLEMENT=complement)
	IF count GE 1 THEN BEGIN
	  FD=FD[OK] ; RESORTS IN ORDER OF FZ
	  S=SORT(FD.FIRST_NAME) & FD=FD(S) & U=UNIQ(FD.FIRST_NAME) & FD=FD(U)
	  S=SORT(FZ.FIRST_NAME) & FZ=FZ(S) & U=UNIQ(FZ.FIRST_NAME) & FZ=FZ(U)
	  mismatch = WHERE(FD.FIRST_NAME NE FZ.FIRST_NAME,count_mismatch)
	  IF count_mismatch GE 1 THEN STOP
;		=====> Now find Newer D dates
 		FID = FILE_INFO(FD.FULLNAME)
  	FIZ = FILE_INFO(FZ.FULLNAME)
    ok = WHERE(FID.MTIME GT FIZ.MTIME,COUNT)
    IF COUNT GE 1 THEN BEGIN
      D = FD[OK].FULLNAME   & Z = 'Z:\PROGRAMS\'+FD[OK].FIRST_NAME+'.PRO'
;			FILE_COPY, D,Z
    	FOR N=0L,N_ELEMENTS(D)-1L DO BEGIN
    		CMD = 'COPY '+ D(N) + ' ' + Z(N)
    		PRINT, CMD
      	SPAWN, CMD
    	ENDFOR
  	ENDIF ELSE BEGIN
  		PRINT, 'Z FILES ARE ALREADY UPDATED'
  	ENDELSE ; IF COUNT GE 1 THEN BEGIN
  ENDIF	; IF count GE 1 THEN BEGIN



STEP_4:
	; =====>4) Overwrites IDL Program Files on D with Newer files on Z
	FD = FILE_SEARCH('D:\IDL\PROGRAMS\*.PRO')
  FZ = FILE_SEARCH(		'Z:\PROGRAMS\*.PRO')
  FD = PARSE_IT(FD)
  FZ = PARSE_IT(FZ)
  FD.FIRST_NAME = STRUPCASE(FD.FIRST_NAME)
  FZ.FIRST_NAME = STRUPCASE(FZ.FIRST_NAME)
  S=SORT(FD.FIRST_NAME) & FD = FD(S)
  S=SORT(FZ.FIRST_NAME) & FZ = FZ(S)
	ok = WHEREIN(FZ.FIRST_NAME, FD.FIRST_NAME,Count,NCOMPLEMENT=ncomplement,COMPLEMENT=complement)
	IF count GE 1 THEN BEGIN
	  FZ=FZ[OK] ; RESORTS IN ORDER OF FD
	  S=SORT(FD.FIRST_NAME) & FD=FD(S) & U=UNIQ(FD.FIRST_NAME) & FD=FD(U)
	  S=SORT(FZ.FIRST_NAME) & FZ=FZ(S) & U=UNIQ(FZ.FIRST_NAME) & FZ=FZ(U)
	  mismatch = WHERE(FZ.FIRST_NAME NE FD.FIRST_NAME,count_mismatch)
	  IF count_mismatch GE 1 THEN STOP
;		=====> Now find Newer Z dates
		FID = FILE_INFO(FD.FULLNAME)
  	FIZ = FILE_INFO(FZ.FULLNAME)
    ok = WHERE(FIZ.MTIME GT FID.MTIME,COUNT)
    IF COUNT GE 1 THEN BEGIN
      Z = FZ[OK].FULLNAME   & D = 'D:\IDL\PROGRAMS\'+FZ[OK].FIRST_NAME+'.PRO'
;			FILE_COPY, Z,D
    	FOR N=0L,N_ELEMENTS(Z)-1L DO BEGIN
    		CMD = 'COPY '+ Z(N) + ' ' + D(N)
    		PRINT, CMD
      	SPAWN, CMD
    	ENDFOR
  	ENDIF ELSE BEGIN
  		PRINT, 'D FILES ARE ALREADY UPDATED'
  	ENDELSE ; IF COUNT GE 1 THEN BEGIN
  ENDIF	; IF count GE 1 THEN BEGIN
END; #####################  End of Routine ################################

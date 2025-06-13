; $Id:	idl_system.pro,	April 25 2011	$
;+
;	This Program Establishes a System Variable (!S) for the IDL Session.
; The System Variable (!S) Contains frequently used constants and expressions in our IDL programs

; HISTORY:
;		Sept 4, 2003 Written by:	J.E. O'Reilly, NOAA, 28 Tarzwell Drive, Narragansett, RI 02882
;-
; *************************************************************************

PRO IDL_SYSTEM
  ROUTINE_NAME='IDL_SYSTEM'
  computer=GET_COMPUTER()

  OS =  STRUPCASE(!VERSION.OS_FAMILY)
  PATH=DELIMITER(/PATH)
  
  IF OS EQ 'UNIX'         THEN DIR_IDL = PATH + 'nadata' + PATH + 'IDL' + PATH ; note, LINUX directories are case sensitive
  IF OS EQ 'WINDOWS'      THEN DIR_IDL = 'D:'            + PATH + 'IDL' + PATH
  IF COMPUTER EQ 'LOLIGO' THEN DIR_IDL = 'C:'            + PATH + 'IDL' + PATH                         
  
  DIR_BACKUP    = DIR_IDL      +'BACKUP'   +PATH
  DIR_PROGRAMS  = DIR_IDL      +'PROGRAMS' +PATH
  DIR_DATA      = DIR_IDL      +'DATA'     +PATH
  DIR_IMAGES    = DIR_IDL      +'IMAGES'   +PATH
  DIR_INVENTORY = DIR_IDL      +'INVENTORY'+PATH
  DIR_EXCLUDE   = DIR_IDL      +'EXCLUDE'  +PATH
  DIR_BACKUP    = DIR_IDL      +'BACKUP'   +PATH
  DIR_TEST      = DIR_IDL      +'TEST'     +PATH
  DIR_FORT      = DIR_IDL      +'FORT'     +PATH  
  DIR_BATHY     = DIR_IDL      +'BATHY'+PATH+'SRTM30PLUS'+PATH+'SAVE'+PATH
  
  IF OS EQ 'UNIX' THEN DIR_DATASETS = PATH+'nadata'+PATH+'DATASETS'+PATH
  IF OS EQ 'UNIX' THEN DIR_PROJECTS = PATH+'nadata'+PATH+'PROJECTS'+PATH
  IF OS EQ 'WINDOWS' THEN BEGIN
    DIR_DATASETS = 'T:'+PATH+'DATASETS'+PATH
    DIR_PROJECTS = 'T:'+PATH+'PROJECTS'+PATH
    CASE COMPUTER OF
      'HALIBUT': BEGIN & DIR_DATASETS = 'D:'+PATH+'DATASETS'+PATH & DIR_PROJECTS = 'D:'+PATH+'PROJECTS'+PATH & END
      'LOLIGO' : BEGIN & DIR_DATASETS = 'C:'+PATH+'DATASETS'+PATH & DIR_PROJECTS = 'C:'+PATH+'PROJECTS'+PATH & END
      ELSE:      BEGIN & DIR_DATASETS = 'T:'+PATH+'DATASETS'+PATH & DIR_PROJECTS = 'T:'+PATH+'PROJECTS'+PATH & END 
    ENDCASE     
  ENDIF
  
      

;	===> Create the structure for the system variable
  S=CREATE_STRUCT('COMPUTER',COMPUTER,'OS',OS,'DIR_PROJECTS',DIR_PROJECTS,$
  	'DIR_DATASETS',DIR_DATASETS,'DIR_IDL',DIR_IDL,'DIR_PROGRAMS',DIR_PROGRAMS,'DIR_DATA',DIR_DATA,'DIR_IMAGES',DIR_IMAGES,$
  	'DIR_BATHY',DIR_BATHY,'DIR_INVENTORY',DIR_INVENTORY,'DIR_EXCLUDE',DIR_EXCLUDE,'DIR_BACKUP',DIR_BACKUP,'DIR_TEST',DIR_TEST,'DIR_FORT',DIR_FORT)
 

;	===> Check if System Variable !S exists if so then do not remake it
  DEFSYSV, '!S', EXISTS = exists

	IF exists EQ 0 THEN BEGIN
	  DEFSYSV, '!S', S

;		===> Store idl's system variables into copies
		DEFSYSV, '!P_', !P
		DEFSYSV, '!X_', !X
		DEFSYSV, '!Y_', !Y
		DEFSYSV, '!Z_', !Z
	ENDIF

	IF exists EQ 1 THEN BEGIN
		!S = S
		!P= !P_
		!X= !X_
		!Y= !Y_
		!Z= !Z_
	ENDIF





END; #####################  End of Routine ################################

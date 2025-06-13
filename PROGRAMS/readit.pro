; $ID:	READIT.PRO,	2017-02-21,	USER-KJWH	$
;##########################################################################################################
  FUNCTION READIT, FILE, $                ; INPUT FILE
                   TYPE=TYPE, $           ; TYPE OF FILE/IMAGE
                   RED=RED,GREEN=GREEN,BLUE=BLUE,$          ; PALETTE DATA
                   HEAD=HEAD,TAIL=TAIL,$  ; ADDITIONAL IMAGE FILE DATA
                   PX=PX,PY=PY ,$         ; X,Y, DIMENSIONS OF ARRAY
                   DEFAULT=DEFAULT ,$     ; THE IMAGE TYPE IF ALL ELSE FAILS
                   QUIET=QUIET,$
                   STRUCT=STRUCT,$        ; OUTPUT STRUCTURE
                   _EXTRA=_EXTRA

;#######################################################################################
;+
; NAME:
;       READIT
;
; PURPOSE:
;        READS VARIOUS TYPES OF DATA FILES AND  2-DIMENSIONAL IMAGE ARRAYS
;       
; CATEGORY:
;       READ
;
; CALLING SEQUENCE:
;       RESULT = READIT(FILE)
;       RESULT = READIT(FILE,TYPE=DSP)
;       RESULT = READIT(FILE,R=R,G=G,B=B,TYPE=GIF)
;
; INPUTS:
;       A FILE, USUALLY AN IMAGE, AND WITH IMPLIED 2 DIMENSIONS
;       CAN ALSO READ OTHER ARRAYS SUCH AS BYTE, INTEGER, LONG, FLOAT, AND DOUBLE ARRAYS
;
; KEYWORD PARAMETERS:
;
;       TYPE:   TYPE OF FILE:  PNG,DSP,PCX,BMP,JPG,JPEG,DBF,CSV
;       FOR IMAGE FILES
;
;       DEFAULT: THE DEFAULT TYPE OF IMAGE WHEN THE EXTENSION IS NOT AS EXPECTED
;       RED:   RED PALETTE (AS IN READ_PNG.PRO)
;       GREEN: GREEN
;       BLUE:  BLUE
;
;
;
;      OPTIONAL FOR ARRAYS
;      PX:   X SIZE OF ARRAY IN PIXELS
;      PY:   Y SIZE OF ARRAY IN PIXELS
;
;
; OUTPUTS:
;       RETURNS A [] IF PROGRAM CAN NOT READ THE FILE
;
;       AN ARRAY MATCHING THE TYPE IN THE FILE
;       PX, PY  (X,Y DIMENSIONS OF THE ARRAY)
;
; SIDE EFFECTS:
;       NONE.
;
; RESTRICTIONS:
;      
;
; PROCEDURE:
;       PASS ANY .
;
; MODIFICATION HISTORY:
;       WRITTEN BY:  J.E.O'REILLY, DEC 28, 2014 [AFTER READALL]
;                    NOTE THAT ONLY COMMON TYPES ARE  SUPPORTED
;      FEB 16, 2017 - JEOR: ADDED READ_NC
;      FEB 20, 2017 - JEOR: ADDED OUTPUT STRUCT
;      FEB 21, 2017 - KJWH: Moved the SPECIAL CASE .SAV and .NC read into the CASE statements because the program thought any non-.SAV file was a .NC file
;                           Added a check for TYPE and to create an ERROR if not found
;      FEB 23, 2017 - KJWH: Added IF TYPE EQ 'SAVE' THEN TYPE = 'SAV' ; Convert SAVE to SAV in order to be able to read old .SAVE files                     
;##########################################################################################################
;-
; ******************
  ROUTINE = 'READIT'
; ******************
;===>SET ARRAY TO NULL AND RETURN [] IF NO ARRAY CAN BE OPENED
  ARRAY=[]

;===> SET R,G,B TO -1
  RED = -1 & GREEN=-1 & BLUE=-1

;===> SET HEAD AND TAIL TO -1
  HEAD = -1 & TAIL = -1

;===> IF FILE NAME NOT PROVIDED THEN USE PICKFILE TO GET A FILE
  IF N_ELEMENTS(FILE) EQ 0 THEN $
           FILE = DIALOG_PICKFILE(TITLE='PICK A FILE',$
           FILTER='*.SAV; *.NC; *.SAVE; *.BMP;*.PNG;*.PCX;*.JPEG;*.JPG; *.DSP; *.DBF;*.AXD;*.CSV;*')
  STRUCT = CREATE_STRUCT('FILE',FILE)
  FP = PARSE_IT(FILE) 

  IF NONE(TYPE) THEN BEGIN
    TYPE = STRUPCASE(FP.EXT)
  ENDIF ELSE BEGIN
    TYPE = STRUPCASE(STRMID(TYPE,0,3))
  ENDELSE;IF NONE(TYPE) THEN BEGIN

  IF TYPE EQ '' THEN MESSAGE,'ERROR: If file TYPE can not be determined from the file name, MUST PROVIDE TYPE'
  IF TYPE EQ 'SAVE' THEN TYPE = 'SAV' ; Convert SAVE to SAV in order to be able to read old .SAVE files         

;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;############################################################################################
  CASE (TYPE) OF
    'PCX': BEGIN
    READ_PCX, FILE, ARRAY, RED, GREEN, BLUE
    END;'PCX'
    
    'BMP': BEGIN
     ARRAY = READ_BMP(FILE,RED,GREEN,BLUE,HEAD)
    END;'BMP'
  
    'PNG': BEGIN
     ARRAY = READ_PNG(FILE,RED,GREEN,BLUE)
    END;'PNG'
    
    'GIF': BEGIN
      READ_GIF, FILE, ARRAY,RED,GREEN,BLUE
    END;'GIF'
    
    'JPG': BEGIN
      READ_JPEG,FILE,ARRAY,COLORS
      RED=COLORS(*,0) & GREEN=COLORS(*,1) & BLUE=COLORS(*,2)
    END;'JPG'
    
    'JPEG': BEGIN
      READ_JPEG,FILE,ARRAY,COLORS
      RED=COLORS(*,0) & GREEN=COLORS(*,1) & BLUE=COLORS(*,2)
    END;'JPEG'
    
    'DSP': BEGIN
      READ_DSP,FILE=FILE,IMAGE=ARRAY,HEAD=HEAD,TAIL=TAIL,$
               PX=PX,PY=PY,/ROTATE,/QUIET
    END;'DSP'
    
    'CSV': BEGIN
     ARRAY = CSV_READ(FILE,_EXTRA=_EXTRA)
    END;'CSV'
    
    'TXT': BEGIN
      ARRAY = READ_TXT(FILE,_EXTRA=_EXTRA)
    END;'TXT'
    
    'MAT': BEGIN
      ARRAY = READ_MATFILE(FILE,_EXTRA=_EXTRA)
    END;'MAT'
    
    'HDF': BEGIN
      ARRAY = READHDF(FILE,_EXTRA=_EXTRA)
    END;'HHF'
    
    'DBF': BEGIN
     ARRAY = READ_DB(FILE,QUIET=QUIET)
    END;'DBF'
    
    'ARR': BEGIN
      ARRAY = READ_ARR(FILE,_EXTRA=_EXTRA)
    END;'ARR'
    
    'AXD': BEGIN
       ARRAY=READ_AXD(FILE,_EXTRA=_EXTRA)
    END;'AXD'
  
    'SAV': BEGIN
      ARRAY = STRUCT_READ(FILE,_EXTRA=_EXTRA,STRUCT=STR)
      STRUCT = CREATE_STRUCT(STRUCT,STR)
      NAME = FP.NAME
      AMAP = VALIDS('MAPS',NAME)
      IF HAS(AMAP,'L3B') THEN BEGIN
        TP = STRUCT_READ(FILE,STRUCT=TMP)
        IF IDLTYPE(TMP) EQ 'STRUCT' THEN BEGIN
          IF HAS(TMP,'N_BINS') THEN BEGIN
            N_BINS = TMP.N_BINS
            LEVEL = 'L3'
          ENDIF ELSE BEGIN
            IF HAS(TMP,'NBINS') THEN N_BINS = TMP.NBINS ELSE N_BINS = 0
            LEVEL = ''
          ENDELSE;IF HAS(TMP,'N_BINS') THEN BEGIN
          STRUCT = CREATE_STRUCT(STRUCT,'LEVEL',LEVEL,'N_BINS',N_BINS)
        ENDIF ; IDLTYPE(TMP_
      ENDIF ; HAS(AMAP,'L3B')
      PROD = VALIDS('PRODS',NAME)
      FILE_LABEL=FILE_LABEL_MAKE(FILE)
      STRUCT = CREATE_STRUCT(STRUCT,'PROD',PROD,'FILE_LABEL',FILE_LABEL)
    END;'SAV'
   
    'NC': BEGIN
      ARRAY=READ_NC(FILE,_EXTRA=_EXTRA)
      PROD = VALIDS('PRODS',FP.NAME)
      SI = SENSOR_INFO(FILE,PROD=PROD)
      IF ANY(SI) THEN STRUCT = CREATE_STRUCT(STRUCT,'SENSOR_INFO',SI)
      IF SI.LEVEL EQ 'L3' THEN BEGIN
        N_BINS = SI.N_BINS
        LEVEL = 'L3'
      ENDIF ELSE LEVEL = ''
      NC_PROD = SI.NC_PROD
      TEST_PROD = READ_NC(FILE,/NAME,/HDF5)
      AMAP = SI.MAP                                                                                                                                                                                                                ; GET THE LEVEL
      FILE_LABEL = SI.FILELABEL + '-' + PROD
      STRUCT = CREATE_STRUCT(STRUCT,'PROD',PROD,'FILE_LABEL',FILE_LABEL)
      NAME = SI.INAME + '-' + PROD
      STRUCT = CREATE_STRUCT(STRUCT,'NAME',NAME,'AMAP',AMAP)
    END;'NC'
    
    ELSE: BEGIN
    ;===> DEFAULT >>  TRY IDL_RESTORE  
      ARRAY = IDL_RESTORE(FILE,_EXTRA=_EXTRA)
      IF (SIZEXYZ(ARRAY)).N_DIMENSIONS NE 2 THEN ARRAY = []
    END
  ENDCASE
;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

  SZ = SIZEXYZ(ARRAY)
  PX = SZ.PX & PY = SZ.PY
  

  DONE:
  RETURN, ARRAY

END; #####################  END OF ROUTINE ################################

; $ID:	SD_FLAGS_COMBO.PRO,	2016-06-29,	USER-KJWH	$

  FUNCTION SD_FLAGS_COMBO, FLAGIMAGE, FLAGBITS
;+
; NAME:
;       SD_FLAGS_COMBO
;
; PURPOSE:
;       Generate a COMBINED MASK FROM 1 OR MORE SEADAS FLAGS
;
; CATEGORY:
;       SEADAS
;
; CALLING SEQUENCE:
;
;        MASK = SD_FLAGS_COMBO()  ; WILL MERGE ALL
;        MASK = SD_FLAGS_COMBO(1) ; WILL MAKE MASK FROM LAND FLAG
;        MASK = SD_FLAGS_COMBO(FLAG,[1,3,4,8,9,12,14])
; INPUTS:
;       SEADAS FLAG IMAGE (THE 13TH BAND IS FLAG IMAGE

;
; KEYWORD PARAMETERS:
;      FLAGBITS:  (CAN BE 0,1,2,3 etc.) Starts at ZERO
;
; OUTPUTS:
;      Black and White Binary image with the flags = 1
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       None.
;
; PROCEDURE:
;       Calls BITS.PRO
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly, March 11,1999
;       Apr 17, 2010 - TD:   Added SEADAS 6.0 flag info
;       Jun 29, 2016 - KJWH: Update flag info for SeaDAS 7.3 Ocean color and SST
;-

; ===============>
; SEADAS 7.3 using FLAG_BITS = [0,1,2,3,4,5,8,9,10,12,14,15,16,25]
;
;      OCEAN COLOR FLAG BITS - http://oceancolor.gsfc.nasa.gov/cms/atbd/ocl2flags
;        Bit  Name       Short Description                           
;        00  ATMFAIL     Atmospheric correction failure              
;        01  LAND        Pixel is over land                          
;        02  PRODWARN    One or more product algorithms generated a warning
;        03  HIGLINT     Sunglint: reflectance exceeds threshold     
;        04  HILT        Observed radiance very high or saturated  
;        05  HISATZEN    Sensor view zenith angle exceeds threshold
;        06  COASTZ      Pixel is in shallow water
;        07  spare
;        08  STRAYLIGHT  Probable stray light contamination  
;        09  CLDICE      Probable cloud or ice contamination 
;        10  COCCOLITH   Coccolithophores detected  
;        11  TURBIDW     Turbid water detected
;        12  HISOLZEN    Solar zenith exceeds threshold 
;        13  spare
;        14  LOWLW       Very low water-leaving radiance
;        15  CHLFAIL     Chlorophyll algorithm failure  
;        16  NAVWARN     Navigation quality is suspect  
;        17  ABSAER      Absorbing Aerosols determined (disabled?)
;        18  spare
;        19  MAXAERITER  Maximum iterations reached for NIR iteration    
;        20  MODGLINT    Moderate sun glint contamination
;        21  CHLWARN     Chlorophyll out-of-bounds
;        22  ATMWARN     Atmospheric correction is suspect   
;        23  spare
;        24  SEAICE      Probable sea ice contamination
;        25  NAVFAIL     Navigation failure    
;        26  FILTER      Pixel rejected by user-defined filter OR Insufficient data for smoothing filter ?
;        27  spare       (used only for SST)
;        28  spare       (used only for SST)
;        29  HIPOL       High degree of polarization determined
;        30  PRODFAIL    Failure in any product
;        31  spare
;
;      SST FLAG BITS - http://oceancolor.gsfc.nasa.gov/cms/atbd/sst/doc/html/flag.html
;        Bit  Name       Description
;        00  ISMASKED    Pixel was already masked
;        01  BTBAD       Brightness temperatures are bad
;        02  BTRANGE     Brightness temperatures are out-of-range
;        03  BTDIFF      Brightness temperatures are too different
;        04  SSTRANGE    SST outside valid range
;        05  SSTREFDIFF  SST is too different from reference
;        06  SST4DIFF    Longwave SST is different from shortwave SST
;        07  SST4VDIFF   Longwave SST is very different from shortwave SST
;        08  BTNONUNIF   Brightness temperatures are spatially non-uniform
;        09  BTVNONUNIF  Brightness temperatures are very spatially non-uniform
;        10  BT4REFDIFF  Brightness temperatures differ from reference
;        11  REDNONUNIF  Red-band spatial non-uniformity or saturation
;        12  HISENZ      Sensor zenith angle high
;        13  VHISENZ     Sensor zenith angle very high
;        14  SSTREFVDIFF SST is too different from reference
;        15  SST_CLOUD   Pixel failed the cloud decision tree
;
; ================>
; FOR EACH OF THE INPUT SEADAS HDF FILES

  SZ=SIZE(FLAGIMAGE)
  IF SZ(0) NE 2 OR N_ELEMENTS(FLAGBITS) LE 0 THEN BEGIN
    PRINT,'ERROR, MUST PROVIDE FLAGIMAGE, AND FLAGBITS'
    RETURN, -1
  ENDIF
  IF MAX(FLAGBITS) GT 31 OR MIN(FLAGBITS) LT 0 THEN BEGIN
    PRINT,'ERROR, FLAGBITS MUST BE BETWEEN 0 AND 31'
    RETURN, -1
  ENDIF

; ==============>
; Make a byte copy of flagimage
  MASK = BYTE(FLAGIMAGE)
  MASK(*,*) = 0B

; ==============>
; For each of the requested bits (flagbits from 0 - 15)
  FOR _FLAG = 0, N_ELEMENTS(FLAGBITS)-1 DO BEGIN
    AFLAG = FLAGBITS(_FLAG)
    MASK =  MASK >  BITS(FLAGIMAGE,AFLAG) < 1 ;
  ENDFOR
  RETURN, MASK

 END ; end of program

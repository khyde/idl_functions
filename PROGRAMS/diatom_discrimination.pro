; $ID:	DIATOM_DISCRIMINATION.PRO,	2020-07-08-15,	USER-KJWH	$

	PRO DIATOM_DISCRIMINATION, CHLFILES, DIR_OUT=DIR_OUT, DIR_LUT=DIR_LUT, SAVE_LUT=SAVE_LUT, OVERWRITE=overwrite, ERROR=error

;+
; NAME:
;		DIATOM_DISCRIMINATION
;
; PURPOSE:;
;		This procedure uses Sathyendranath et al (2004) to distinguish diatoms from mixed populations using SeaWiFS.
;		  For a given chlorophyll concentration, a model is used to compute reflectances at the 6 SeaWiFS wavebands.
;		  Look-up tables are generated for matched pairs of chlorophyll concentrations and reflectances.
;		  The model assumes that reflectance at a given wavelength just below the sea-surface (z=0) is the sum of 
;		    reflectances associated with Raman and elastic scattering.
;
; CATEGORY:
;		PHYTOPLANKTON
;
; CALLING SEQUENCE:
;
;		DD = DIATOM_DISCRIMINATION(FILES, RRS_490=rrs_490, RRS_510=rrs_510, RRS_555=rrs_555, RRS_670=rrs_670)
;
; INPUTS:
;   FILES, RRS_490, RRS_510, RRS_555, RRS_670
;
; OUTPUTS:
;		This function returns either 'Diatom' or 'Mixed' for each input pixel
;
;	NOTES:
;	    Sathyendranath, S., Watts, L., Devred, E., Platt, T., Caverhill, C., Maass, H., 2004. 
;	      Discrimination of diatoms from other phytoplankton using ocean-colour data. 
;	      Marine Ecology Progress Series 272, 59-68.
;	    
;	    Sathyendranath, S., Cotas, G., Stuart, V., Maass, H., Platt, T., 2001. 
;	      Remote sensing of phytoplankton pigments: a comparison of empirical and theoretical approaches. 
;	      International Journal of Remote Sensing 22 (2&3), 249-273.
;
;
; MODIFICATION HISTORY:
;			Written Jan 6, 2010 by K.J.W.Hyde, 28 Tarzwell Drive, NMFS, NOAA 02882 (kimberly.hyde@noaa.gov)
;-
;	****************************************************************************************************
	ROUTINE_NAME = 'DIATOM_DISCRIMINATION'

;	===> Initialize ERROR to a null string. If errors are encountered ERROR will be set to a message.
;			 The calling routine can check error (e.g.IF ERROR NE 0 then there was a problem and do this or that)
	ERROR = ''

  ; For a given chlorophyll concentration, a model is used to compute reflectances at the 6 SeaWiFS wavebands.  
  ; Look-up tables are generated for matched pairs of chl concentrations and reflectances.
 
  
  IF N_ELEMENTS(CHLFILES) GE 1 THEN FILES = CHLFILES ELSE FILES = DIALOG_PICKFILE(filter='*.save')
  FP = PARSE_IT(CHLFILES[0])
  IF N_ELEMENTS(DIR_LUT) NE 1 THEN _DIR_LUT = 'D:\IDL\LUTS\' ELSE _DIR_LUT = DIR_LUT & IF FILE_TEST(_DIR_LUT) EQ 0 THEN FILE_MKDIR,_DIR_LUT 
  IF N_ELEMENTS(DIR_OUT) NE 1 THEN _DIR_OUT = FP.DIR         ELSE _DIR_OUT = DIR_OUT & IF FILE_TEST(_DIR_OUT) EQ 0 THEN FILE_MKDIR,_DIR_OUT
  
 

  FOR _FILE=0L, N_ELEMENTS(FILES)-1 DO BEGIN
    CHLOR_A = FINDGEN(40000)*.001 + 0.001
    FP = FILE_ALL(FILES(_FILE))
    IF FP.NAME EQ '' THEN CONTINUE
    FILE_490    = FP.DIR  + REPLACE(FP.NAME_EXT,'CHLOR_A-OC4','RRS_490')
    FILE_510    = FP.DIR  + REPLACE(FP.NAME_EXT,'CHLOR_A-OC4','RRS_510')
    FILE_555    = FP.DIR  + REPLACE(FP.NAME_EXT,'CHLOR_A-OC4','RRS_555')
    FILE_670    = FP.DIR  + REPLACE(FP.NAME_EXT,'CHLOR_A-OC4','RRS_670')
    DIATOM_FILE = DIR_OUT + REPLACE(FP.NAME_EXT,'CHLOR_A-OC4','DIATOM_DISC')
    
    IF TOTAL(FILE_TEST([FP.FULLNAME,FILE_490,FILE_510,FILE_555,FILE_670])) NE 5 THEN BEGIN
      PRINT, 'ERROR: Missing 1 or more RRS files'
      CONTINUE
    ENDIF  
    
    FD = FILE_ALL(DIATOM_FILE)
    PNGFILE     = DIR_OUT + FD.NAME + '.PNG'
    IF FD.MTIME GT FP.MTIME AND NOT KEYWORD_SET(OVERWRITE) THEN CONTINUE  
    
    DP   = DATE_PARSE(PERIOD_2DATE(FP.PERIOD))
    DOY  = DP.IDOY
    HR   = 17
    LUTFILE = _DIR_LUT+'DOY'+NUM2STR(DOY)+'-'+FP.MAP+'-DIATOM_DISCRIMINATION-LUT.SAVE'
    IF FILE_TEST(LUTFILE) EQ 1 AND NOT KEYWORD_SET(OVERWRITE)THEN GOTO, SKIP_LUT
       
    MAPINFO = MAPS_INFO(FP.MAP,/QUIET,/STRUCT)
    LON  = MAPINFO.MID_MID[0]
    LAT  = MAPINFO.MID_MID[1]
    ARRAY = CHLOR_A & ARRAY(*,*) = MISSINGS(0.0)    
    RADTRAN,LON=LON,LAT=LAT,DOY=DOY,HR=HR,STRUCT=RADSTRUCT,WAVELENGTHS=WAVELENGTHS,/QUIET
    ED  = CREATE_STRUCT('W362',ARRAY,'W386',ARRAY,'W412',ARRAY,'W421',ARRAY,'W435',ARRAY,'W443',ARRAY,'W468',ARRAY,'W490',ARRAY,'W510',ARRAY,'W547',ARRAY,'W555',ARRAY,'W670',ARRAY)
    WAVELENGTHS   = NUM2STR([362,386,412,421,443,435,490,468,510,547,555,670])    
    FOR WTH = 0L, N_ELEMENTS(WAVELENGTHS)-1 DO BEGIN  
      OK = WHERE(RADSTRUCT.WAVELENGTH EQ WAVELENGTHS(WTH))      
      ED.(WTH) = REPLICATE(RADSTRUCT.ED[OK],N_ELEMENTS(CHLOR_A))     
    ENDFOR  
    GONE, RADSTRUCT 
    
    LUT = DIATOM_DISCRIMINATION_LUT(CHLOR_A=CHLOR_A, ED=ED)
    IF KEYWORD_SET(SAVE_LUT) THEN SAVE,FILENAME=LUTFILE,LUT,/COMPRESS
    GONE, ED
    
    SKIP_LUT:
    
    IF N_ELEMENTS(LUT) EQ 0 THEN LUT = IDL_RESTORE(LUTFILE)
        
    CHLOR_A = STRUCT_SD_READ(FP.FULLNAME,STRUCT=STRUCT)
    RRS_490 = STRUCT_SD_READ(FILE_490,STRUCT=STRUCT_490,SUBS=SUBS_490)
    RRS_510 = STRUCT_SD_READ(FILE_510,STRUCT=STRUCT_510,SUBS=SUBS_510) 
    RRS_555 = STRUCT_SD_READ(FILE_555,STRUCT=STRUCT_555,SUBS=SUBS_555) 
    RRS_670 = STRUCT_SD_READ(FILE_670,STRUCT=STRUCT_670,SUBS=SUBS_670)  
    INFILES = [FP.FULLNAME,FILE_490,FILE_510,FILE_555,FILE_670]
    
    OK_CHL  = WHERE(CHLOR_A NE MISSINGS(0.0))
         
    OK_GOOD = WHERE(RRS_490 NE MISSINGS(RRS_490) AND RRS_490 GT 0.0 AND RRS_490 LT 10.0 AND $
                    RRS_510 NE MISSINGS(RRS_510) AND RRS_510 GT 0.0 AND RRS_510 LT 10.0 AND $
                    RRS_555 NE MISSINGS(RRS_555) AND RRS_555 GT 0.0 AND RRS_555 LT 10.0 AND $
                    RRS_670 NE MISSINGS(RRS_670) AND RRS_670 GT 0.0 AND RRS_670 LT 10.0,COUNT_GOOD,COMPLEMENT=COMPLEMENT)
    IF COUNT_GOOD EQ 0 THEN CONTINUE; RETURN, -1
        
    DCHL           = RRS_490 & DCHL(*) = MISSINGS(0.0)
    MCHL           = DCHL
    R510_555       = DCHL
    R490_670       = DCHL
    DCHL_510_555   = DCHL
    DCHL_490_670   = DCHL
    MCHL_510_555   = MCHL
    MCHL_490_670   = MCHL
    DIATOM         = BYTE(RRS_490)    
    DIATOM(*,*)    = 0   ; Initialize the output to be zero
    DIATOM(OK_CHL) = 3   ; Initialize the output to be 3 where there are valid chlorophyll pixels
    DIATOM(OK_GOOD)= 255 ; Initialize all valid RRS data to be 255
    R510_555       = FLOAT(ROUNDS(RRS_510/RRS_555,5))
    R490_670       = FLOAT(ROUNDS(RRS_490/RRS_670,5))    
    
    GONE, CHLOR_A
    GONE, RRS_490
    GONE, RRS_510 
    GONE, RRS_555
    GONE, RRS_670  
                  
;   Estimated chlorophyll using both the 510:555 and 490:670 ratios from the DIATOM_LUT and calculate the normalized difference between the 2 computed chlorophyll values
    
    OK = WHERE_MATCH(LUT.DIATOM_RR510_555,R510_555(OK_GOOD),VALID=VALID,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT,NINVALID=NINVALID,INVALID=INVALID) 
    DCHL_510_555(OK_GOOD(VALID))  = LUT.CHL_DIATOM_RR510_555[OK]
    OK = WHERE_MATCH(LUT.DIATOM_RR490_670,R490_670(OK_GOOD),VALID=VALID,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT,NINVALID=NINVALID,INVALID=INVALID) 
    DCHL_490_670(OK_GOOD(VALID))  = LUT.CHL_DIATOM_RR490_670[OK]  
    OK = WHERE(DCHL_510_555 NE MISSINGS(0.0) AND DCHL_490_670 NE MISSINGS(0.0),COUNT)
    IF COUNT GE 1 THEN DCHL[OK] = ALOG(DCHL_510_555[OK]) - ALOG(DCHL_490_670[OK]) ELSE CONTINUE
      
    OK  = WHERE_MATCH(LUT.MIXED_RR510_555,R510_555(OK_GOOD),VALID=VALID,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT,NINVALID=NINVALID,INVALID=INVALID)
    MCHL_510_555(OK_GOOD(VALID))  = LUT.CHL_MIXED_RR510_555[OK]
    OK = WHERE_MATCH(LUT.MIXED_RR490_670,R490_670(OK_GOOD),VALID=VALID,NCOMPLEMENT=NCOMPLEMENT,COMPLEMENT=COMPLEMENT,NINVALID=NINVALID,INVALID=INVALID)
    MCHL_490_670(OK_GOOD(VALID))  = LUT.CHL_MIXED_RR490_670[OK]
    OK = WHERE(MCHL_510_555 NE MISSINGS(0.0) AND MCHL_490_670 NE MISSINGS(0.0))
    MCHL[OK] = ALOG(MCHL_510_555[OK]) - ALOG(MCHL_490_670[OK])          

;   The correct model should yield smaller differences in the concentrations retrieved using 2 different waveband pairs than should the wrong model.  
    OK_DIATOM = WHERE(DCHL(OK_GOOD) LT MCHL(OK_GOOD) AND DCHL(OK_GOOD) NE MISSINGS(DCHL) AND MCHL(OK_GOOD) NE MISSINGS(MCHL), COUNT, COMPLEMENT=COMPLEMENT)
    IF COUNT GE 1 THEN DIATOM(OK_GOOD(COMPLEMENT)) = 1 ; Mixed Population
    IF COUNT GE 1 THEN DIATOM(OK_GOOD(OK_DIATOM))  = 2 ; Diatoms
    STRUCT_SD_WRITE, DIATOM_FILE,IMAGE=DIATOM,MISSING_CODE=0,PROD='DIATOM_DISC',DATA_UNITS='',$
          TRANSFORMATION='',PERIOD=STRUCT.PERIOD,SENSOR=STRUCT.SENSOR,SATELLITE=STRUCT.SATELLITE,  $
          ASTAT=STRUCT.STAT,METHOD=STRUCT.METHOD,SUITE=STRUCT.SUITE,MAP=STRUCT.MAP, $
          INFILE=INFILES,NOTES='Diatom Discrimination based on Sathyendranath et al., 2004'
    
    GONE, LUT
    GONE, R510_555
    GONE, R490_670
    GONE, DCHL_510_555
    GONE, DCHL_490_670
    GONE, MCHL_510_555
    GONE, MCHL_490_670
    GONE, DIATOM
    
  ENDFOR


END; #####################  End of Routine ################################

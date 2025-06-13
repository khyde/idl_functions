; $ID:	DWLD_ESA_OCCCI_SUBSET.PRO,	2023-09-21-13,	USER-KJWH	$
  PRO DWLD_ESA_OCCCI_SUBSET, YEARS=YEARS, PRODS=PRODS, VERSION=VERSION, PERIODS=PERIODS, RESOLUTION=RESOLUTION,$
                          NORTH=NORTH, WEST=WEST, EAST=EAST, SOUTH=SOUTH, MAP_SUBSET=MAP_SUBSET,  LOGLUN=LOGLUN, $
                          RECENT=RECENT

;+
; NAME:
;   DWLD_ESA_OCCCI_SUBSET
;
; PURPOSE:
;   $PURPOSE$
;
; CATEGORY:
;   DOWNLOAD_FUNCTIONS
;
; CALLING SEQUENCE:
;   DWLD_ESA_OCCCI_SUBSET
;
; REQUIRED INPUTS:
;   None 
;
; OPTIONAL INPUTS:
;   YEARS.......... The Year(s) of files to downloand
;   PRODS.......... The name of the products to download
;   VERSION........ Version of the files to download
;   PERIOD......... Indicates the period of the downloaded file (DAILY, MONTHLY, etc)
;   RESOLUTION...Indications the 1km or 4km product
;   LOGLUN......... The LUN for the logfile
;   NORTH.......... The northern latitude for the subset
;   WEST........... The western longitude for the subset
;   SOUTH.......... The southern latitude for the subset
;   EAST........... The eastern longitude for the subset
;   MAP_SUBSET..... The name of the map used for the subset coordinates
;
; KEYWORD PARAMETERS:
;   RECNET..... Just download files from the current and previous year
;
; OUTPUTS:
;   New files downloaded to !S.OC/OCCCI/[VERSION]/1KM
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   None
;
; SIDE EFFECTS:  
;   None
;
; RESTRICTIONS:  
;   Will need to be updated as new versions of the OCCCI data are released
;
; EXAMPLE:
;   DWLD_ESA_OCCCI_SUBSET, YEARS='2020', PRODS='CHLOR_A'
;
; NOTES:
;   https://climate.esa.int/en/projects/ocean-colour/
;   https://rsg.pml.ac.uk/thredds/ncss/grid/CCI_ALL-v5.0-1km-DAILY/dataset.html
;   
;   Sathyendranath, S, Brewin, RJW, Brockmann, C, Brotas, V, Calton, B, Chuprin, A, Cipollini, P, Couto, AB, Dingle, J, Doerffer, R, Donlon, C, Dowell, M, Farman, A, Grant, M, Groom, S, Horseman, A, Jackson, T, Krasemann, H, Lavender, S, Martinez-Vicente, V, Mazeran, C, Mélin, F, Moore, TS, Mu?ller, D, Regner, P, Roy, S, Steele, CJ, Steinmetz, F, Swinton, J, Taberner, M, Thompson, A, Valente, A, Zu?hlke, M, Brando, VE, Feng, H, Feldman, G, Franz, BA, Frouin, R, Gould, Jr., RW, Hooker, SB, Kahru, M, Kratzer, S, Mitchell, BG, Muller-Karger, F, Sosik, HM, Voss, KJ, Werdell, J, and Platt, T (2019) An ocean-colour time series for use in climate studies: the experience of the Ocean-Colour Climate Change Initiative (OC-CCI). Sensors: 19, 4285. doi:10.3390/s19194285
;   
; COPYRIGHT: 
; Copyright (C) 2021, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on November 08, 2021 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Nov 08, 2021 - KJWH: Initial code written
;   Mar 15, 2023 - KJWH: Changed name from DWLD_ESA_OCCCI_1KM to DWLD_ESA_OCCCI_SUBSET and adapted it to work with other "subset" requests
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'DWLD_ESA_OCCCI_SUBSET'
  COMPILE_OPT IDL2
  SL = PATH_SEP()
  
  DATASET = 'OCCCI'
  CURRENT_VERSION = '6.0'
  DP = DATE_PARSE(DATE_NOW())
  
  IF ~N_ELEMENTS(LOGLUN)  THEN LUN = [] ELSE LUN = LOGLUN
  IF ~N_ELEMENTS(VERSION) THEN VERSION = CURRENT_VERSION
  IF ~N_ELEMENTS(PRODS)     THEN PRODS = ['chlor_a'] ELSE PRODS = STRLOWCASE(PRODS) ;
  IF ~N_ELEMENTS(YEARS)     THEN YRS = YEAR_RANGE('1997',DP.YEAR,/STRING) ELSE YRS = STRING(YEARS)
  IF ~N_ELEMENTS(PERIODS) THEN PERIODS = ['DAILY','MONTHLY']
  IF ~N_ELEMENTS(RESOLUTION) THEN RESOLUTION = ['1KM']
  IF KEYWORD_SET(RECENT) THEN YRS = NUM2STR([DP.YEAR-1,DP.YEAR])
  MONTHS = MONTH_RANGE(/STRING)
  
  IF TOTAL([N_ELEMENTS(NORTH),N_ELEMENTS(EAST),N_ELEMENTS(SOUTH),N_ELEMENTS(WEST)]) GT 0 AND N_ELEMENTS(MAP_SUBSET) EQ 0 THEN MESSAGE, 'ERROR: If providing boundary coordinates, then also need to provide a MAP_SUBSET name'
  IF N_ELEMENTS(MAP_SUBSET) EQ 0 THEN MAP_SUBSET = 'NWA' 
  IF N_ELEMENTS(NORTH) EQ 0 THEN NORTH = 'north=48.5' ELSE NORTH = 'north='+NUM2STR(NORTH)
  IF N_ELEMENTS(EAST)  EQ 0 THEN EAST  = 'east=-51.5' ELSE EAST  = 'east=' +NUM2STR(EAST)
  IF N_ELEMENTS(SOUTH) EQ 0 THEN SOUTH = 'south=22.5' ELSE SOUTH = 'south='+NUM2STR(SOUTH)
  IF N_ELEMENTS(WEST)  EQ 0 THEN WEST  = 'west=-82.5' ELSE WEST  = 'west=' +NUM2STR(WEST)
  
  LOCATION = STRJOIN([NORTH,WEST,EAST,SOUTH],'&')
  SUBSET = 'disableLLSubset=on&disableProjSubset=on&horizStride=1'
  TIMESET = 'timeStride=1&addLatLon=true&accept=netcdf'
  WAVELENGTHS=['412','443','490','510','560','665']
  
  FOR PER=0, N_ELEMENTS(PERIODS)-1 DO BEGIN
    APER = PERIODS[PER]

    FOR RES=0, N_ELEMENTS(RESOLUTION) -1 DO BEGIN
      ARES = STRUPCASE(RESOLUTION[RES])
          
      CASE APER OF
        'DAILY': OPER = 'DD'
        'MONTHLY': BEGIN & OPER = 'M' & ARES = '4KM' & END  ; Monthly data are only available at 4km (for V6)
      ENDCASE
      
      CASE ARES OF
        '1KM': BEGIN & RES_LINK = '-1km' & SUBDIR = 'SOURCE_1KM' & END
        '4KM': BEGIN & RES_LINK = '' & SUBDIR = 'SOURCE_MONTHLY' & END
      ENDCASE
      
      CASE VERSION OF
        '5.0': LINK = 'https://rsg.pml.ac.uk/thredds/ncss/CCI_ALL-v5.0' + RES_LINK + '-' + APER
        '6.0': LINK = 'https://www.oceancolour.org/thredds/ncss/grid/CCI_ALL-v6.0' + RES_LINK + '-' + APER
      ENDCASE
      
      FOR V=0, N_ELEMENTS(PRODS)-1 DO BEGIN
        VAR = 'var='
        VARPROD = '?'
        CASE STRUPCASE(PRODS[V]) OF
          'CHLOR_A': BEGIN & OPROD='CHLOR_A-CCI' & VARPROD = VARPROD + VAR + 'chlor_a' & END
          'RRS': BEGIN & OPROD = 'RRS' &  VARPROD = '?' + STRJOIN('var=Rrs_' + WAVELENGTHS, '&')  & END
          'ATOT': BEGIN & OPROD = 'ATOT-QAA' & VARPROD = '?' + STRJOIN('var=atot_' + WAVELENGTHS, '&') & END
          'BBP': BEGIN & OPROD = 'BBP-QAA' &  VARPROD = '?' + STRJOIN('var=bbp_' + WAVELENGTHS, '&')  & END
          'IOP': BEGIN
            OPROD = 'IOP-QAA'
            IPRODS = ['adg','aph','atot','bbp']
            VARPROD = '?'
            FOR I=0, N_ELEMENTS(IPRODS)-1 DO VARPROD=VARPROD+STRJOIN('var='+IPRODS[I]+'_' + WAVELENGTHS, '&') +'&'
          END  
        ENDCASE  
        IF STRMID(VARPROD,0,1,/REVERSE_OFFSET) EQ '&' THEN VARPROD = STRMID(VARPROD,0,STRLEN(VARPROD)-1)
        
        DIROUT = !S.OCCCI + 'V'+VERSION + SL + SUBDIR + SL + 'NC' + SL + OPROD + SL & DIR_TEST, DIROUT
        LOGDIR = !S.LOGS + 'IDL_BATCH_DOWNLOADS' + SL + DATASET + SL & DIR_TEST, LOGDIR
        
        ; ===> Create and open the log file
        LOGFILE = LOGDIR + 'BATCH_DOWNLOADS-OCCCI-' + ARES + '-' + OPROD + '-' + DATE_NOW(/DATE_ONLY) + '.log'
        OPENW,LUN,LOGFILE,/APPEND,/GET_LUN,width=180
        PLUN,LUN,'*****************************************************************************************************',3
        PLUN,LUN,'WGET log file initializing on: ' + systime(),0
        PLUN,LUN,'Downloading files in ' + DATASET, 0
        
        CD, DIROUT
        FOR Y=0, N_ELEMENTS(YRS)-1 DO BEGIN
          YEAR = YRS[Y]
          IF YEAR EQ '1997' THEN YEARSTART = 'time_start=1997-09-04T00%3A00%3A00Z' ELSE YEARSTART = 'time_start='+YEAR+'-01-01'+'T00%3A00%3A00Z' + ' 
          YEAREND = 'time_end='+YEAR+'-12-31T00%3A00%3A00Z'
          FOR M=0, N_ELEMENTS(MONTHS)-1 DO BEGIN
            MONTH = MONTHS[M]
            DAYEND = DAYS_MONTH(MONTH, YEAR=YEAR, /STRING)
            STIME = 'time_start='+STRJOIN([YEAR,MONTH,'01'],'-')+'T00%3A00%3A00Z'
            ETIME = 'time_end='+STRJOIN([YEAR,MONTH,DAYEND],'-')+'T00%3A00%3A00Z'
            IF YEAR EQ '1997' AND MONTH LT '09' THEN CONTINUE   ; There are no files before September 10, 1997
            IF YEAR EQ '1997' AND MONTH EQ '09' THEN STIME = 'time_start='+STRJOIN([YEAR,MONTH,'10'],'-')+'T00%3A00%3A00Z'
            
            CASE APER OF 
              'DAILY': BEGIN
                OPER = 'DD_' + YEAR + MONTH + '01' + '_' + YEAR + MONTH + DAYS_MONTH(MONTH,YEAR=YEAR,/STRING)
                HTML = LINK + STRJOIN([VARPROD,LOCATION,SUBSET,STIME,ETIME,TIMESET],'&') 
              END  
              'MONTHLY': BEGIN
                IF YEAR EQ '1997' THEN OPER = 'MM_199709_199712' ELSE OPER = 'MM_' + YEAR + '01_' + YEAR + '12' 
                HTML = LINK + STRJOIN([VARPROD,LOCATION,SUBSET,YEARSTART,YEAREND,TIMESET],'&') 
              END  
            ENDCASE
            
            OUTFILE = OPER +'-OCCCI-V'+VERSION+'-' + ARES +'-GEQ-'+MAP_SUBSET+'_SUBSET-'+OPROD+'.nc'
            IF FILE_TEST(DIROUT+OUTFILE) AND ~KEYWORD_SET(OVERWRITE) THEN CONTINUE
            
            PLUN, LUN, 'Downloading ' + OUTFILE + '...'
            
            CMD = 'wget --progress=bar:force -c -N -O ' + OUTFILE + ' "' + HTML + '" -a ' + LOGFILE      
            SPAWN, CMD, LOG, ERR
            FI = FILE_INFO(OUTFILE)
            IF FILE_TEST(OUTFILE) AND FI.SIZE EQ 0 THEN FILE_DELETE, OUTFILE
             
           ; R =  WGET(HTML, FILENAME=OUTFILE, DIRECTORY=DIROUT)                                                     ; Download the file
          ENDFOR ; MONTHS  
        ENDFOR ; YEARS
        CD, !S.PROGRAMS
        PLUN, LUN, 'Finished downloading OCCCI SUBSET files for ' + OPROD + '.'
        PLUN, LUN, 'Closing WGET LOG FILE on: ' + systime(),0
        PLUN,LUN,'*****************************************************************************************************',3
        CLOSE, LUN & FREE_LUN, LUN
      ENDFOR ; PRODS  
    ENDFOR ; PERIODS  
  ENDFOR ; RESOLUTION  


END ; ***************** End of DWLD_ESA_OCCCI_SUBSET *****************

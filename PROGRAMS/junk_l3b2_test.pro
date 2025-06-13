; $ID:	JUNK_L3B2_TEST.PRO,	2020-04-14-13,	USER-KJWH	$
pro junk_l3b2_test

  SL = GET_PATH()


; Steps to remap a L3B2 file:
; 1) MAPS_REMAP - no changes needed
; 2) MAPS_L3B_2MAP
;   a) MAPS_READ
;   b) MAPS_SIZE - Need to update the MASTER with the new L3B2 bin size
;   c) MAPS_L3B_BINS - Gets the number of BINS in a L3B map
;   d) MAPS_L3B_NROWS - Gets the number of ROWS in a L3B/GS map
;   e) MAPS_L3B_LONLAT_2BIN - Gets the bin locations for input lons and lats (from the output map)
;     * Similar calculation as in MAPS_BIN2LL
;   
; 3) MAPS_L3B_2LONLAT - Calls MAPS_BIN2LL to get the lons and lats of the L3B file  
;   a) MAPS_BIN2LL - Calculates the lons and lats for each bin
;     * According to S. Bailey, need to remove the FLOAT() in the LATBIN calculation
;
;
;
; Temporarily make a new map - L3B2N for the new files with the different bin numbers
;
; Once working - will need to create new L3B/GS swap files (MAPS_L3BGS_SWAP).
 
  
  
;  m2=maps_bin2ll('L3B2',lons=lons,lats=lats)
;  mn=maps_bin2ll('L3B2N',lons=lonsn,lats=latsn)
;  
;  sm2 = maps_remap(lats,map_in='L3B2',MAP_OUT='SNEGRID')
;  smn = maps_remap(latsn,map_in='L3B2N',MAP_OUT='SNEGRID')
;
;
;  
;
;
;stop










  
  DIR_DEMO = !S.DEMO + 'L3B2_MAPPING_TEST' + SL & DIR_TEST, DIR_DEMO
  
;  F = FLS(!S.OC + 'MODISA/L3B2/NC/CHL/A201810*')
;  PRODS_2PNG, F, MAPP='NWA', DIR_OUT=DIR_DEMO+'SAMPLE_PNGS/', PROD='CHLOR_A'
;  
  DOY = '185'
 ; FILE_UPDATE, FLS(!S.OC + 'MODISA/L3B2/NC/CHL/A2010' + DOY + '*'), DIR_DEMO
;  
;  
;  F = FLS(!S.OC + 'MODISA/L2/NC/A2018' + DOY + '*')
; ; FILE_COPY, F, DIR_DEMO + 'L2/'
  
  
  F18 = FLS(DIR_DEMO + 'A2010' + DOY + '*_v2018*.nc') & P, F18
  F19 = FLS(DIR_DEMO + 'A2010' + DOY + '*_v2019*.nc') & P, F19
  
;  F19 = FLS(DIR_DEMO + 'A2014175' + '*.nc') & P, F19  
  
 ; PRODS_2PNG, F18, MAPP='MAB', DIR_OUT=DIR_DEMO, PROD='CHLOR_A',/OVERWRITE, ADD_LAND=0, ADD_COAST=1
 ; PRODS_2PNG, F19, MAPP='MAB', DIR_OUT=DIR_DEMO, PROD='CHLOR_A',/OVERWRITE, ADD_LAND=0, ADD_COAST=1

 ; D18 = READ_NC(F18) & ODAT = D18.SD.CHLOR_A.DATA & OBINS=D18.SD.CHLOR_A.BINS
  D19 = READ_NC(F19) & NDAT = D19.SD.CHLOR_A.DATA & NBINS=D19.SD.CHLOR_A.BINS
  
  M19 = MAPS_L3B_2MAP(NDAT, NBINS, MAP_IN='L3B2', MAP_OUT='MAB',init=0)
  G19 = MAPS_L3B_2MAP(NDAT, NBINS, MAP_IN='L3B2', MAP_OUT='GS2',init=0)
  L19 = MAPS_REMAP(G19, MAP_IN='GS2', MAP_OUT='L3B2')
  S19 = MAPS_REMAP(G19, MAP_IN='GS2',MAP_OUT='MAB')


  d = NDAT-L19  
  PMM, D
  STOP
  
  ; THE NUMBER OF DATA BINS IS DIFFERENT IN THE OLD AND NEW FILES
  
  ;NWA = MAPS_2LONLAT('NWA',LATS=NLATS,LONS=NLONS)

;  LBN = MAPS_L3B_2MAP(NDAT, NBINS, MAP_IN='L3B2N', MAP_OUT='SNEGRID',/init)
  LBO = MAPS_L3B_2MAP(ODAT, OBINS, MAP_IN='L3B2', MAP_OUT='SNEGRID',/init)
  
  IMGR, LBO, PNG=DIR_DEMO + 'A2018107.L3B2_DAY_CHL_v2018.png', MAP='SNEGRID', delay=2
;  IMGR, LBN, PNG=DIR_DEMO + 'A2018107.L3B2N_DAY_CHL_v2019.png',MAP='SNEGRID', delay=2
  
  PBN = PRODS_2BYTE(NDAT, PROD='CHLOR_A_0.1_20',MP='SENGRID',MAP='SNEGRID')
  PBO = PRODS_2BYTE(ODAT, PROD='CHLOR_A_O.1_20',MP='SNEGRID',MAP='SNEGRID')
  
  

  ;MAPS_L3B_LONLAT_2BIN('L3B2N', NLONS, NLATS, BASEBIN=BASEBIN, NUMBIN=NUMBIN, LATBIN=LATBIN, TOTBINS=TOTBINS)
  
  OK = WHERE(LBO NE LBN, COUNT) & P, COUNT
  
 ; Look at the L3BMAPGEN code to see how it is mapping the binned data
  
  stop

  
  
  ; test MAPS_L3B_LONLAT_2BIN with the FLOAT removed and various input lons and lats.
  ; based on the shift, it seems like the lons and lats from the original file are now assosciated with new bin numbers.
  
stop


end
